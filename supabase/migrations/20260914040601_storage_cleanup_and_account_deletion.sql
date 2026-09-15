-- 커뮤니티 전용 이미지 큐를 모든 Storage 버킷에서 사용하는 공통 큐로 전환합니다.
ALTER TABLE public.community_image_cleanup_queue
  RENAME TO storage_cleanup_queue;

ALTER TABLE public.storage_cleanup_queue
  DROP CONSTRAINT IF EXISTS community_image_cleanup_queue_account_path_key;

ALTER TABLE public.storage_cleanup_queue
  DROP CONSTRAINT IF EXISTS community_image_cleanup_queue_account_id_fkey;

ALTER TABLE public.storage_cleanup_queue
  ALTER COLUMN account_id DROP NOT NULL;

ALTER TABLE public.storage_cleanup_queue
  ADD COLUMN IF NOT EXISTS bucket_id TEXT NOT NULL DEFAULT 'community-images';

ALTER TABLE public.storage_cleanup_queue
  ADD COLUMN IF NOT EXISTS lease_until TIMESTAMPTZ;

ALTER TABLE public.storage_cleanup_queue
  ADD CONSTRAINT storage_cleanup_queue_account_id_fkey
  FOREIGN KEY (account_id)
  REFERENCES public.accounts(id)
  ON DELETE SET NULL;

ALTER TABLE public.storage_cleanup_queue
  ADD CONSTRAINT storage_cleanup_queue_owner_bucket_path_key
  UNIQUE (account_id, bucket_id, storage_path);

ALTER TABLE public.storage_cleanup_queue
  RENAME CONSTRAINT community_image_cleanup_queue_attempt_count_check
  TO storage_cleanup_queue_attempt_count_check;

ALTER INDEX IF EXISTS public.idx_community_image_cleanup_queue_retry
  RENAME TO idx_storage_cleanup_queue_owner_retry;

CREATE INDEX IF NOT EXISTS idx_storage_cleanup_queue_ready
  ON public.storage_cleanup_queue(next_retry_at, lease_until);

ALTER TABLE public.storage_cleanup_queue ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own community image cleanup queue"
  ON public.storage_cleanup_queue;
DROP POLICY IF EXISTS "Users can delete own community image cleanup queue"
  ON public.storage_cleanup_queue;

-- 클라이언트는 큐를 직접 조회·수정하지 않고, RPC로 등록만 합니다.
REVOKE ALL ON public.storage_cleanup_queue FROM anon, authenticated;
GRANT SELECT, UPDATE, DELETE ON public.storage_cleanup_queue TO service_role;

-- Auth0 사용자 삭제 작업은 Storage 파일 정리와 대상·처리 방식이 다르므로
-- 별도의 큐에서 관리합니다. completed_at이 있는 행은 삭제 완료된 Auth0
-- 식별자의 tombstone 역할도 하여, 아직 유효한 예전 JWT로 계정이 재생성되지
-- 않도록 합니다.
CREATE TABLE IF NOT EXISTS public.auth0_user_deletion_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID REFERENCES public.accounts(id) ON DELETE SET NULL,
  auth_issuer TEXT NOT NULL,
  auth_subject TEXT NOT NULL,
  attempt_count INTEGER NOT NULL DEFAULT 0,
  last_error TEXT,
  next_retry_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  lease_until TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT auth0_user_deletion_queue_identity_key
    UNIQUE (auth_issuer, auth_subject),
  CONSTRAINT auth0_user_deletion_queue_attempt_count_check
    CHECK (attempt_count >= 0)
);

CREATE INDEX IF NOT EXISTS idx_auth0_user_deletion_queue_ready
  ON public.auth0_user_deletion_queue(next_retry_at, lease_until)
  WHERE completed_at IS NULL;

ALTER TABLE public.auth0_user_deletion_queue ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.auth0_user_deletion_queue FROM anon, authenticated;
GRANT SELECT, UPDATE, DELETE ON public.auth0_user_deletion_queue TO service_role;

-- Auth0 삭제 Worker가 중복 실행으로 같은 사용자를 동시에 삭제하지 않도록
-- 만료된 lease가 있는 작업만 선점합니다.
CREATE OR REPLACE FUNCTION public.claim_auth0_user_deletion_items(
  p_limit INTEGER DEFAULT 25
)
RETURNS TABLE (
  id UUID,
  auth_issuer TEXT,
  auth_subject TEXT
)
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  WITH candidates AS (
    SELECT queue.id
    FROM public.auth0_user_deletion_queue AS queue
    WHERE queue.completed_at IS NULL
      AND queue.next_retry_at <= now()
      AND (
        queue.lease_until IS NULL
        OR queue.lease_until < now()
      )
    ORDER BY queue.next_retry_at, queue.created_at
    FOR UPDATE SKIP LOCKED
    LIMIT GREATEST(1, LEAST(COALESCE(p_limit, 25), 50))
  )
  UPDATE public.auth0_user_deletion_queue AS queue
  SET attempt_count = queue.attempt_count + 1,
      lease_until = now() + INTERVAL '10 minutes'
  FROM candidates
  WHERE queue.id = candidates.id
  RETURNING queue.id, queue.auth_issuer, queue.auth_subject;
$$;

CREATE OR REPLACE FUNCTION public.complete_auth0_user_deletion_items(
  p_ids UUID[]
)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  UPDATE public.auth0_user_deletion_queue
  SET completed_at = COALESCE(completed_at, now()),
      last_error = NULL,
      lease_until = NULL
  WHERE id = ANY(p_ids)
    AND completed_at IS NULL;
  SELECT TRUE;
$$;

CREATE OR REPLACE FUNCTION public.fail_auth0_user_deletion_items(
  p_ids UUID[],
  p_message TEXT
)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  UPDATE public.auth0_user_deletion_queue
  SET last_error = LEFT(COALESCE(p_message, ''), 1000),
      next_retry_at = now() + CASE
        WHEN attempt_count <= 1 THEN INTERVAL '1 minute'
        WHEN attempt_count = 2 THEN INTERVAL '10 minutes'
        WHEN attempt_count = 3 THEN INTERVAL '1 hour'
        ELSE INTERVAL '24 hours'
      END,
      lease_until = NULL
  WHERE id = ANY(p_ids)
    AND completed_at IS NULL;
  SELECT TRUE;
$$;

REVOKE EXECUTE ON FUNCTION public.claim_auth0_user_deletion_items(INTEGER)
  FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.complete_auth0_user_deletion_items(UUID[])
  FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.fail_auth0_user_deletion_items(UUID[], TEXT)
  FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.claim_auth0_user_deletion_items(INTEGER)
  TO service_role;
GRANT EXECUTE ON FUNCTION public.complete_auth0_user_deletion_items(UUID[])
  TO service_role;
GRANT EXECUTE ON FUNCTION public.fail_auth0_user_deletion_items(UUID[], TEXT)
  TO service_role;

-- 삭제 완료된 Auth0 식별자는 tombstone으로 남겨 재사용을 차단합니다.
-- 앱에서 사용하는 개인정보와 계정 레코드는 저장하지 않습니다.
CREATE OR REPLACE FUNCTION public.ensure_account()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  claims JSONB := auth.jwt();
  issuer TEXT := claims ->> 'iss';
  subject TEXT := claims ->> 'sub';
  v_account_id UUID;
  v_email TEXT;
  v_connection TEXT;
  v_name TEXT;
  v_profile_name TEXT;
BEGIN
  IF issuer IS NULL OR issuer = '' OR subject IS NULL OR subject = '' THEN
    RAISE EXCEPTION 'Authenticated JWT must include iss and sub claims';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.auth0_user_deletion_queue AS queue
    WHERE queue.auth_issuer = issuer
      AND queue.auth_subject = subject
  ) THEN
    RAISE EXCEPTION 'This Auth0 account has been deleted';
  END IF;

  v_email := NULLIF(claims ->> 'email', '');
  v_connection := NULLIF(claims ->> 'https://meomum.app/connection', '');
  v_name := NULLIF(claims ->> 'name', '');
  v_profile_name := COALESCE(
    NULLIF(claims ->> 'https://meomum.app/profile_name', ''),
    NULLIF(claims ->> 'nickname', ''),
    CASE
      WHEN v_name IS NOT NULL
        AND LOWER(v_name) IS DISTINCT FROM LOWER(v_email)
        THEN v_name
    END,
    NULLIF(claims ->> 'given_name', ''),
    '사용자'
  );

  INSERT INTO public.accounts (
    auth_issuer,
    auth_subject,
    auth_connection,
    email
  )
  VALUES (issuer, subject, v_connection, v_email)
  ON CONFLICT (auth_issuer, auth_subject) DO UPDATE
    SET auth_connection = COALESCE(
          EXCLUDED.auth_connection,
          public.accounts.auth_connection
        ),
        email = COALESCE(EXCLUDED.email, public.accounts.email),
        updated_at = now()
  RETURNING id INTO v_account_id;

  INSERT INTO public.profiles (account_id, nickname, profile_image_url)
  VALUES (
    v_account_id,
    v_profile_name,
    NULLIF(claims ->> 'picture', '')
  )
  ON CONFLICT (account_id) DO UPDATE
    SET nickname = EXCLUDED.nickname,
        profile_image_url = COALESCE(
          public.profiles.profile_image_url,
          EXCLUDED.profile_image_url
        ),
        updated_at = now()
    WHERE public.profiles.nickname = ''
      OR public.profiles.nickname = '사용자'
      OR (
        v_email IS NOT NULL
        AND LOWER(public.profiles.nickname) = LOWER(v_email)
      );

  RETURN v_account_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.ensure_account() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.ensure_account() TO authenticated;

-- 현재 계정이 소유한 경로만 공통 정리 큐에 등록할 수 있게 합니다.
CREATE OR REPLACE FUNCTION public.enqueue_storage_cleanup(
  p_bucket_id TEXT,
  p_storage_paths TEXT[]
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_account_id UUID := public.current_account_id();
  v_storage_path TEXT;
BEGIN
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION 'Authenticated account is required';
  END IF;

  IF p_bucket_id NOT IN ('community-images', 'profile-images') THEN
    RAISE EXCEPTION 'Storage bucket is not allowed.';
  END IF;

  IF p_storage_paths IS NULL OR CARDINALITY(p_storage_paths) = 0 THEN
    RETURN TRUE;
  END IF;

  FOREACH v_storage_path IN ARRAY p_storage_paths
  LOOP
    IF NULLIF(BTRIM(v_storage_path), '') IS NULL
      OR SPLIT_PART(v_storage_path, '/', 1) <> 'accounts'
      OR SPLIT_PART(v_storage_path, '/', 2) <> v_account_id::TEXT THEN
      RAISE EXCEPTION '이미지 저장 경로가 올바르지 않습니다.';
    END IF;
  END LOOP;

  INSERT INTO public.storage_cleanup_queue (
    account_id,
    bucket_id,
    storage_path,
    next_retry_at,
    lease_until
  )
  SELECT DISTINCT
    v_account_id,
    p_bucket_id,
    BTRIM(storage_path),
    now(),
    NULL::TIMESTAMPTZ
  FROM UNNEST(p_storage_paths) AS paths(storage_path)
  ON CONFLICT (account_id, bucket_id, storage_path) DO UPDATE
    SET attempt_count = 0,
        last_error = NULL,
        next_retry_at = now(),
        lease_until = NULL;

  RETURN TRUE;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.enqueue_storage_cleanup(TEXT, TEXT[])
  FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.enqueue_storage_cleanup(TEXT, TEXT[])
  TO authenticated;

-- Edge Function이 중복으로 같은 파일을 삭제하지 않도록 만료된 작업을 선점합니다.
CREATE OR REPLACE FUNCTION public.claim_storage_cleanup_items(
  p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
  id UUID,
  bucket_id TEXT,
  storage_path TEXT
)
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  WITH candidates AS (
    SELECT queue.id
    FROM public.storage_cleanup_queue AS queue
    WHERE queue.next_retry_at <= now()
      AND (
        queue.lease_until IS NULL
        OR queue.lease_until < now()
      )
    ORDER BY queue.next_retry_at, queue.created_at
    FOR UPDATE SKIP LOCKED
    LIMIT GREATEST(1, LEAST(COALESCE(p_limit, 50), 100))
  )
  UPDATE public.storage_cleanup_queue AS queue
  SET attempt_count = queue.attempt_count + 1,
      lease_until = now() + INTERVAL '10 minutes'
  FROM candidates
  WHERE queue.id = candidates.id
  RETURNING queue.id, queue.bucket_id, queue.storage_path;
$$;

CREATE OR REPLACE FUNCTION public.complete_storage_cleanup_items(
  p_ids UUID[]
)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  DELETE FROM public.storage_cleanup_queue
  WHERE id = ANY(p_ids);
  SELECT TRUE;
$$;

CREATE OR REPLACE FUNCTION public.fail_storage_cleanup_items(
  p_ids UUID[],
  p_message TEXT
)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  UPDATE public.storage_cleanup_queue
  SET last_error = LEFT(COALESCE(p_message, ''), 1000),
      next_retry_at = now() + CASE
        WHEN attempt_count <= 1 THEN INTERVAL '1 minute'
        WHEN attempt_count = 2 THEN INTERVAL '10 minutes'
        WHEN attempt_count = 3 THEN INTERVAL '1 hour'
        ELSE INTERVAL '24 hours'
      END,
      lease_until = NULL
  WHERE id = ANY(p_ids);
  SELECT TRUE;
$$;

REVOKE EXECUTE ON FUNCTION public.claim_storage_cleanup_items(INTEGER)
  FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.complete_storage_cleanup_items(UUID[])
  FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.fail_storage_cleanup_items(UUID[], TEXT)
  FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.claim_storage_cleanup_items(INTEGER)
  TO service_role;
GRANT EXECUTE ON FUNCTION public.complete_storage_cleanup_items(UUID[])
  TO service_role;
GRANT EXECUTE ON FUNCTION public.fail_storage_cleanup_items(UUID[], TEXT)
  TO service_role;

-- 회원 탈퇴 전에 소유한 프로필·게시글 이미지를 큐에 등록한 뒤 계정을 삭제합니다.
-- 계정 삭제로 account_id가 NULL이 되어도 큐 항목은 보존됩니다.
CREATE OR REPLACE FUNCTION public.delete_account()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  claims JSONB := auth.jwt();
  v_issuer TEXT := claims ->> 'iss';
  v_subject TEXT := claims ->> 'sub';
  v_account_id UUID := public.current_account_id();
  v_profile_url TEXT;
  v_profile_path TEXT;
  v_profile_marker CONSTANT TEXT := '/storage/v1/object/public/profile-images/';
BEGIN
  IF v_issuer IS NULL OR v_issuer = ''
    OR v_subject IS NULL OR v_subject = '' THEN
    RAISE EXCEPTION 'Authenticated JWT must include iss and sub claims';
  END IF;

  IF v_account_id IS NULL AND EXISTS (
    SELECT 1
    FROM public.auth0_user_deletion_queue AS queue
    WHERE queue.auth_issuer = v_issuer
      AND queue.auth_subject = v_subject
  ) THEN
    RETURN TRUE;
  END IF;

  IF v_account_id IS NULL THEN
    RAISE EXCEPTION 'Authenticated account is required';
  END IF;

  INSERT INTO public.auth0_user_deletion_queue (
    account_id,
    auth_issuer,
    auth_subject,
    next_retry_at,
    lease_until,
    completed_at
  )
  VALUES (
    v_account_id,
    v_issuer,
    v_subject,
    now(),
    NULL,
    NULL
  )
  ON CONFLICT (auth_issuer, auth_subject) DO UPDATE
    SET account_id = EXCLUDED.account_id,
        last_error = NULL,
        next_retry_at = now(),
        lease_until = NULL,
        completed_at = NULL;

  INSERT INTO public.storage_cleanup_queue (
    account_id,
    bucket_id,
    storage_path,
    next_retry_at
  )
  SELECT
    v_account_id,
    'community-images',
    image.storage_path,
    now()
  FROM public.post_images AS image
  JOIN public.posts AS post ON post.id = image.post_id
  WHERE post.author_id = v_account_id
  ON CONFLICT (account_id, bucket_id, storage_path) DO UPDATE
    SET attempt_count = 0,
        last_error = NULL,
        next_retry_at = now(),
        lease_until = NULL;

  SELECT profile_image_url
  INTO v_profile_url
  FROM public.profiles
  WHERE account_id = v_account_id;

  IF v_profile_url IS NOT NULL
    AND POSITION(v_profile_marker IN v_profile_url) > 0 THEN
    v_profile_path := SUBSTRING(
      v_profile_url
      FROM POSITION(v_profile_marker IN v_profile_url) + CHAR_LENGTH(v_profile_marker)
    );

    IF SPLIT_PART(v_profile_path, '/', 1) = 'accounts'
      AND SPLIT_PART(v_profile_path, '/', 2) = v_account_id::TEXT THEN
      INSERT INTO public.storage_cleanup_queue (
        account_id,
        bucket_id,
        storage_path,
        next_retry_at
      )
      VALUES (
        v_account_id,
        'profile-images',
        v_profile_path,
        now()
      )
      ON CONFLICT (account_id, bucket_id, storage_path) DO UPDATE
        SET attempt_count = 0,
            last_error = NULL,
            next_retry_at = now(),
            lease_until = NULL;
    END IF;
  END IF;

  DELETE FROM public.accounts
  WHERE id = v_account_id;

  RETURN TRUE;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.delete_account()
  FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_account()
  TO authenticated;

-- 게시글 수정 RPC가 공통 큐에 커뮤니티 이미지 경로를 등록하도록 갱신합니다.
CREATE OR REPLACE FUNCTION public.update_post_with_images(
  p_post_id UUID,
  p_upper_region TEXT,
  p_lower_region TEXT,
  p_category TEXT,
  p_title TEXT,
  p_content TEXT,
  p_images JSONB DEFAULT '[]'::JSONB,
  p_place_name TEXT DEFAULT NULL,
  p_place_latitude DOUBLE PRECISION DEFAULT NULL,
  p_place_longitude DOUBLE PRECISION DEFAULT NULL,
  p_place_address TEXT DEFAULT NULL,
  p_place_road_address TEXT DEFAULT NULL,
  p_place_category TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_account_id UUID := public.current_account_id();
  v_post_id UUID;
  v_image JSONB;
  v_image_count INTEGER;
  v_removed_storage_paths TEXT[];
BEGIN
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION 'Authenticated account is required';
  END IF;

  IF p_images IS NULL OR JSONB_TYPEOF(p_images) <> 'array' THEN
    RAISE EXCEPTION '이미지 목록 형식이 올바르지 않습니다.';
  END IF;

  SELECT id INTO v_post_id
  FROM public.posts
  WHERE id = p_post_id AND author_id = v_account_id
  FOR UPDATE;

  IF v_post_id IS NULL THEN
    RAISE EXCEPTION '게시글을 수정할 권한이 없습니다.';
  END IF;

  IF NULLIF(BTRIM(p_upper_region), '') IS NULL
    OR NULLIF(BTRIM(p_lower_region), '') IS NULL THEN
    RAISE EXCEPTION '게시 지역을 입력해주세요.';
  END IF;

  IF NULLIF(BTRIM(p_title), '') IS NULL THEN
    RAISE EXCEPTION '제목을 입력해주세요.';
  END IF;

  IF NULLIF(BTRIM(p_content), '') IS NULL THEN
    RAISE EXCEPTION '내용을 입력해주세요.';
  END IF;

  IF CHAR_LENGTH(BTRIM(p_title)) > 50 THEN
    RAISE EXCEPTION '제목은 50자 이내로 입력해주세요.';
  END IF;

  IF CHAR_LENGTH(BTRIM(p_content)) > 10000 THEN
    RAISE EXCEPTION '본문은 10,000자 이내로 입력해주세요.';
  END IF;

  v_image_count := JSONB_ARRAY_LENGTH(p_images);
  IF v_image_count > 10 THEN
    RAISE EXCEPTION '이미지는 최대 10개까지 등록할 수 있습니다.';
  END IF;

  FOR v_image IN SELECT value FROM JSONB_ARRAY_ELEMENTS(p_images)
  LOOP
    IF JSONB_TYPEOF(v_image) <> 'object'
      OR NULLIF(BTRIM(v_image ->> 'storage_path'), '') IS NULL
      OR NULLIF(BTRIM(v_image ->> 'public_url'), '') IS NULL
      OR (v_image ->> 'sort_order') IS NULL
      OR (v_image ->> 'sort_order')::INTEGER < 0 THEN
      RAISE EXCEPTION '이미지 정보가 올바르지 않습니다.';
    END IF;

    IF SPLIT_PART(v_image ->> 'storage_path', '/', 1) <> 'accounts'
      OR SPLIT_PART(v_image ->> 'storage_path', '/', 2) <> v_account_id::TEXT THEN
      RAISE EXCEPTION '이미지 저장 경로가 올바르지 않습니다.';
    END IF;
  END LOOP;

  SELECT COALESCE(
    ARRAY_AGG(pi.storage_path ORDER BY pi.sort_order),
    ARRAY[]::TEXT[]
  )
  INTO v_removed_storage_paths
  FROM public.post_images pi
  WHERE pi.post_id = v_post_id
    AND NOT EXISTS (
      SELECT 1
      FROM JSONB_ARRAY_ELEMENTS(p_images) image
      WHERE image ->> 'storage_path' = pi.storage_path
    );

  IF COALESCE(ARRAY_LENGTH(v_removed_storage_paths, 1), 0) > 0 THEN
    INSERT INTO public.storage_cleanup_queue (
      account_id,
      bucket_id,
      storage_path,
      next_retry_at
    )
    SELECT
      v_account_id,
      'community-images',
      storage_path,
      now()
    FROM UNNEST(v_removed_storage_paths) AS paths(storage_path)
    ON CONFLICT (account_id, bucket_id, storage_path) DO UPDATE
      SET attempt_count = 0,
          last_error = NULL,
          next_retry_at = now(),
          lease_until = NULL;
  END IF;

  UPDATE public.posts
  SET upper_region = BTRIM(p_upper_region),
      lower_region = BTRIM(p_lower_region),
      category = BTRIM(p_category),
      title = BTRIM(p_title),
      content = BTRIM(p_content),
      place_name = NULLIF(BTRIM(p_place_name), ''),
      place_latitude = p_place_latitude,
      place_longitude = p_place_longitude,
      place_address = NULLIF(BTRIM(p_place_address), ''),
      place_road_address = NULLIF(BTRIM(p_place_road_address), ''),
      place_category = NULLIF(BTRIM(p_place_category), ''),
      updated_at = now()
  WHERE id = v_post_id;

  DELETE FROM public.post_images WHERE post_id = v_post_id;

  INSERT INTO public.post_images (
    post_id,
    storage_path,
    public_url,
    sort_order
  )
  SELECT
    v_post_id,
    BTRIM(image ->> 'storage_path'),
    BTRIM(image ->> 'public_url'),
    (image ->> 'sort_order')::INTEGER
  FROM JSONB_ARRAY_ELEMENTS(p_images) WITH ORDINALITY AS images(image, ordinal)
  ORDER BY ordinal;

  RETURN JSONB_BUILD_OBJECT(
    'post_id', v_post_id,
    'removed_storage_paths', TO_JSONB(v_removed_storage_paths)
  );
END;
$$;

-- 게시글 삭제 RPC도 공통 큐에 커뮤니티 이미지 경로를 등록하도록 갱신합니다.
CREATE OR REPLACE FUNCTION public.delete_post_with_images(
  p_post_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_account_id UUID := public.current_account_id();
  v_post_id UUID;
  v_storage_paths TEXT[];
BEGIN
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION 'Authenticated account is required';
  END IF;

  SELECT p.id INTO v_post_id
  FROM public.posts AS p
  WHERE p.id = p_post_id AND p.author_id = v_account_id
  FOR UPDATE;

  IF v_post_id IS NULL THEN
    RAISE EXCEPTION '게시글을 삭제할 권한이 없습니다.';
  END IF;

  SELECT COALESCE(
    ARRAY_AGG(pi.storage_path ORDER BY pi.sort_order),
    ARRAY[]::TEXT[]
  )
  INTO v_storage_paths
  FROM public.post_images AS pi
  WHERE pi.post_id = v_post_id;

  IF CARDINALITY(v_storage_paths) > 0 THEN
    INSERT INTO public.storage_cleanup_queue (
      account_id,
      bucket_id,
      storage_path,
      next_retry_at
    )
    SELECT DISTINCT
      v_account_id,
      'community-images',
      storage_path,
      now()
    FROM UNNEST(v_storage_paths) AS paths(storage_path)
    ON CONFLICT (account_id, bucket_id, storage_path) DO UPDATE
      SET attempt_count = 0,
          last_error = NULL,
          next_retry_at = now(),
          lease_until = NULL;
  END IF;

  DELETE FROM public.posts WHERE id = v_post_id;

  RETURN JSONB_BUILD_OBJECT(
    'post_id', v_post_id,
    'storage_paths', TO_JSONB(v_storage_paths)
  );
END;
$$;

DROP FUNCTION IF EXISTS public.enqueue_community_image_cleanup(TEXT[]);
DROP FUNCTION IF EXISTS public.record_community_image_cleanup_failure(TEXT[], TEXT);
