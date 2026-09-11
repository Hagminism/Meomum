-- 게시글 수정 중 Storage 정리 실패를 재시도하기 위한 작업 큐입니다.
CREATE TABLE IF NOT EXISTS public.community_image_cleanup_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  attempt_count INTEGER NOT NULL DEFAULT 0,
  last_error TEXT,
  next_retry_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT community_image_cleanup_queue_account_path_key
    UNIQUE (account_id, storage_path),
  CONSTRAINT community_image_cleanup_queue_attempt_count_check
    CHECK (attempt_count >= 0)
);

CREATE INDEX IF NOT EXISTS idx_community_image_cleanup_queue_retry
  ON public.community_image_cleanup_queue(account_id, next_retry_at);

ALTER TABLE public.community_image_cleanup_queue ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own community image cleanup queue"
  ON public.community_image_cleanup_queue;
DROP POLICY IF EXISTS "Users can delete own community image cleanup queue"
  ON public.community_image_cleanup_queue;

CREATE POLICY "Users can view own community image cleanup queue"
  ON public.community_image_cleanup_queue FOR SELECT
  TO authenticated
  USING (account_id = public.current_account_id());

CREATE POLICY "Users can delete own community image cleanup queue"
  ON public.community_image_cleanup_queue FOR DELETE
  TO authenticated
  USING (account_id = public.current_account_id());

GRANT SELECT, DELETE ON public.community_image_cleanup_queue TO authenticated;

-- 게시글과 이미지 메타데이터를 하나의 트랜잭션으로 수정합니다.
-- 삭제되는 기존 Storage 경로는 같은 트랜잭션 안에서 재시도 큐에 기록합니다.
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

  SELECT id
  INTO v_post_id
  FROM public.posts
  WHERE id = p_post_id
    AND author_id = v_account_id
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
    INSERT INTO public.community_image_cleanup_queue (
      account_id,
      storage_path,
      next_retry_at
    )
    SELECT
      v_account_id,
      storage_path,
      now()
    FROM UNNEST(v_removed_storage_paths) AS paths(storage_path)
    ON CONFLICT (account_id, storage_path) DO UPDATE
      SET attempt_count = 0,
          last_error = NULL,
          next_retry_at = now();
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

  DELETE FROM public.post_images
  WHERE post_id = v_post_id;

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

REVOKE EXECUTE ON FUNCTION public.update_post_with_images(
  UUID,
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  JSONB,
  TEXT,
  DOUBLE PRECISION,
  DOUBLE PRECISION,
  TEXT,
  TEXT,
  TEXT
) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.update_post_with_images(
  UUID,
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  JSONB,
  TEXT,
  DOUBLE PRECISION,
  DOUBLE PRECISION,
  TEXT,
  TEXT,
  TEXT
) TO authenticated;

-- 작성·수정 과정에서 Storage 보상 삭제에 실패한 경로를 큐에 등록합니다.
CREATE OR REPLACE FUNCTION public.enqueue_community_image_cleanup(
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

  INSERT INTO public.community_image_cleanup_queue (
    account_id,
    storage_path,
    next_retry_at
  )
  SELECT DISTINCT
    v_account_id,
    BTRIM(storage_path),
    now()
  FROM UNNEST(p_storage_paths) AS paths(storage_path)
  ON CONFLICT (account_id, storage_path) DO UPDATE
    SET attempt_count = 0,
        last_error = NULL,
        next_retry_at = now();

  RETURN TRUE;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.enqueue_community_image_cleanup(TEXT[])
  FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.enqueue_community_image_cleanup(TEXT[])
  TO authenticated;

-- Storage 삭제 실패 시 다음 재시도 시각을 지수 백오프로 갱신합니다.
CREATE OR REPLACE FUNCTION public.record_community_image_cleanup_failure(
  p_storage_paths TEXT[],
  p_message TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_account_id UUID := public.current_account_id();
BEGIN
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION 'Authenticated account is required';
  END IF;

  IF p_storage_paths IS NULL OR CARDINALITY(p_storage_paths) = 0 THEN
    RETURN TRUE;
  END IF;

  UPDATE public.community_image_cleanup_queue
  SET attempt_count = attempt_count + 1,
      last_error = LEFT(COALESCE(p_message, ''), 1000),
      next_retry_at = now() + CASE
        WHEN attempt_count = 0 THEN INTERVAL '1 minute'
        WHEN attempt_count = 1 THEN INTERVAL '10 minutes'
        WHEN attempt_count = 2 THEN INTERVAL '1 hour'
        ELSE INTERVAL '24 hours'
      END
  WHERE account_id = v_account_id
    AND storage_path = ANY(p_storage_paths);

  RETURN TRUE;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.record_community_image_cleanup_failure(
  TEXT[],
  TEXT
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.record_community_image_cleanup_failure(
  TEXT[],
  TEXT
) TO authenticated;
