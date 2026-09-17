-- 댓글과 댓글 좋아요를 게시글과 같은 Auth0 accounts 모델로 구성합니다.
CREATE TABLE public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES public.profiles(account_id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  storage_path TEXT,
  image_url TEXT,
  like_count INTEGER NOT NULL DEFAULT 0,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  CONSTRAINT comments_content_length_check
    CHECK (is_deleted OR char_length(trim(content)) BETWEEN 1 AND 1000),
  CONSTRAINT comments_image_pair_check
    CHECK ((storage_path IS NULL) = (image_url IS NULL)),
  CONSTRAINT comments_not_self_parent_check
    CHECK (parent_id IS NULL OR parent_id <> id)
);

CREATE INDEX idx_comments_post_created_at
  ON public.comments(post_id, created_at);
CREATE INDEX idx_comments_author_created_at
  ON public.comments(author_id, created_at DESC);
CREATE INDEX idx_comments_parent_id
  ON public.comments(parent_id);

CREATE TABLE public.comment_likes (
  account_id UUID NOT NULL REFERENCES public.profiles(account_id) ON DELETE CASCADE,
  comment_id UUID NOT NULL REFERENCES public.comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (account_id, comment_id)
);

CREATE INDEX idx_comment_likes_comment_id
  ON public.comment_likes(comment_id);

-- 대댓글은 본댓글에만 연결되도록 DB에서도 보장합니다.
CREATE OR REPLACE FUNCTION public.validate_comment_parent()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
DECLARE
  v_parent_post_id UUID;
  v_parent_id UUID;
BEGIN
  IF NEW.parent_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT post_id, parent_id
  INTO v_parent_post_id, v_parent_id
  FROM public.comments
  WHERE id = NEW.parent_id;

  IF v_parent_post_id IS NULL THEN
    RAISE EXCEPTION '대댓글 대상 댓글을 찾을 수 없습니다.';
  END IF;

  IF v_parent_post_id <> NEW.post_id OR v_parent_id IS NOT NULL THEN
    RAISE EXCEPTION '대댓글은 본댓글에만 작성할 수 있습니다.';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER comments_validate_parent_trigger
  BEFORE INSERT OR UPDATE OF post_id, parent_id ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.validate_comment_parent();

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comment_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view comments"
  ON public.comments FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can view comment likes"
  ON public.comment_likes FOR SELECT TO authenticated USING (true);

REVOKE ALL ON public.comments FROM anon, authenticated;
REVOKE ALL ON public.comment_likes FROM anon, authenticated;
GRANT SELECT ON public.comments TO authenticated;
GRANT SELECT ON public.comment_likes TO authenticated;

-- 댓글 등록 전 Storage 경로가 현재 계정 소유인지 검증합니다.
CREATE OR REPLACE FUNCTION public.assert_comment_storage_path(
  p_storage_path TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
  IF p_storage_path IS NULL THEN
    RETURN;
  END IF;

  IF p_storage_path NOT LIKE 'accounts/' || public.current_account_id()::text || '/%' THEN
    RAISE EXCEPTION '댓글 이미지 경로가 현재 계정 소유가 아닙니다.';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.create_comment(
  p_post_id UUID,
  p_parent_id UUID,
  p_content TEXT,
  p_storage_path TEXT DEFAULT NULL,
  p_image_url TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_account_id UUID := public.current_account_id();
  v_comment_id UUID;
BEGIN
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION '로그인이 필요합니다.';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.posts WHERE id = p_post_id) THEN
    RAISE EXCEPTION '게시글을 찾을 수 없습니다.';
  END IF;

  IF p_content IS NULL OR char_length(trim(p_content)) = 0 THEN
    RAISE EXCEPTION '댓글 내용을 입력해주세요.';
  END IF;

  IF char_length(trim(p_content)) > 1000 THEN
    RAISE EXCEPTION '댓글은 1,000자 이하로 입력해주세요.';
  END IF;

  IF (p_storage_path IS NULL) <> (p_image_url IS NULL) THEN
    RAISE EXCEPTION '댓글 이미지 정보가 올바르지 않습니다.';
  END IF;

  PERFORM public.assert_comment_storage_path(p_storage_path);

  INSERT INTO public.comments (
    post_id,
    parent_id,
    author_id,
    content,
    storage_path,
    image_url
  )
  VALUES (
    p_post_id,
    p_parent_id,
    v_account_id,
    trim(p_content),
    p_storage_path,
    p_image_url
  )
  RETURNING id INTO v_comment_id;

  UPDATE public.posts
  SET comment_count = comment_count + 1,
      updated_at = now()
  WHERE id = p_post_id;

  RETURN v_comment_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_comment(
  p_comment_id UUID,
  p_content TEXT,
  p_storage_path TEXT DEFAULT NULL,
  p_image_url TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_account_id UUID := public.current_account_id();
  v_post_id UUID;
  v_old_storage_path TEXT;
BEGIN
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION '로그인이 필요합니다.';
  END IF;

  IF p_content IS NULL OR char_length(trim(p_content)) = 0 THEN
    RAISE EXCEPTION '댓글 내용을 입력해주세요.';
  END IF;

  IF char_length(trim(p_content)) > 1000 THEN
    RAISE EXCEPTION '댓글은 1,000자 이하로 입력해주세요.';
  END IF;

  IF (p_storage_path IS NULL) <> (p_image_url IS NULL) THEN
    RAISE EXCEPTION '댓글 이미지 정보가 올바르지 않습니다.';
  END IF;

  PERFORM public.assert_comment_storage_path(p_storage_path);

  SELECT post_id, storage_path
  INTO v_post_id, v_old_storage_path
  FROM public.comments
  WHERE id = p_comment_id
    AND author_id = v_account_id
    AND is_deleted = false
  FOR UPDATE;

  IF v_post_id IS NULL THEN
    RAISE EXCEPTION '댓글을 수정할 권한이 없습니다.';
  END IF;

  UPDATE public.comments
  SET content = trim(p_content),
      storage_path = p_storage_path,
      image_url = p_image_url,
      updated_at = now()
  WHERE id = p_comment_id;

  IF v_old_storage_path IS NOT NULL
     AND v_old_storage_path IS DISTINCT FROM p_storage_path THEN
    PERFORM public.enqueue_storage_cleanup(
      'community-images',
      ARRAY[v_old_storage_path]
    );
  END IF;

  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION public.delete_comment(
  p_comment_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_account_id UUID := public.current_account_id();
  v_post_id UUID;
  v_storage_path TEXT;
BEGIN
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION '로그인이 필요합니다.';
  END IF;

  SELECT post_id, storage_path
  INTO v_post_id, v_storage_path
  FROM public.comments
  WHERE id = p_comment_id
    AND author_id = v_account_id
    AND is_deleted = false
  FOR UPDATE;

  IF v_post_id IS NULL THEN
    RAISE EXCEPTION '댓글을 삭제할 권한이 없습니다.';
  END IF;

  UPDATE public.comments
  SET is_deleted = true,
      content = '삭제된 댓글입니다.',
      storage_path = NULL,
      image_url = NULL,
      deleted_at = now(),
      updated_at = now()
  WHERE id = p_comment_id;

  UPDATE public.posts
  SET comment_count = GREATEST(comment_count - 1, 0),
      updated_at = now()
  WHERE id = v_post_id;

  IF v_storage_path IS NOT NULL THEN
    PERFORM public.enqueue_storage_cleanup(
      'community-images',
      ARRAY[v_storage_path]
    );
  END IF;

  RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION public.toggle_comment_like(
  p_comment_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_account_id UUID := public.current_account_id();
  v_is_liked BOOLEAN;
BEGIN
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION '로그인이 필요합니다.';
  END IF;

  PERFORM 1
  FROM public.comments
  WHERE id = p_comment_id
    AND is_deleted = false
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION '댓글을 찾을 수 없습니다.';
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM public.comment_likes
    WHERE account_id = v_account_id
      AND comment_id = p_comment_id
  ) INTO v_is_liked;

  IF v_is_liked THEN
    DELETE FROM public.comment_likes
    WHERE account_id = v_account_id
      AND comment_id = p_comment_id;
  ELSE
    INSERT INTO public.comment_likes (account_id, comment_id)
    VALUES (v_account_id, p_comment_id);
  END IF;

  UPDATE public.comments
  SET like_count = GREATEST(
        like_count + CASE WHEN v_is_liked THEN -1 ELSE 1 END,
        0
      )
  WHERE id = p_comment_id;

  RETURN NOT v_is_liked;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.assert_comment_storage_path(TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.create_comment(UUID, UUID, TEXT, TEXT, TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.update_comment(UUID, TEXT, TEXT, TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.delete_comment(UUID) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.toggle_comment_like(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.create_comment(UUID, UUID, TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_comment(UUID, TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_comment(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.toggle_comment_like(UUID) TO authenticated;

-- 게시글 삭제 시 게시글 이미지와 댓글 이미지를 같은 정리 큐에 등록합니다.
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

  SELECT p.id
  INTO v_post_id
  FROM public.posts AS p
  WHERE p.id = p_post_id
    AND p.author_id = v_account_id
  FOR UPDATE;

  IF v_post_id IS NULL THEN
    RAISE EXCEPTION '게시글을 삭제할 권한이 없습니다.';
  END IF;

  SELECT COALESCE(
    ARRAY_AGG(paths.storage_path ORDER BY paths.storage_path),
    ARRAY[]::TEXT[]
  )
  INTO v_storage_paths
  FROM (
    SELECT pi.storage_path
    FROM public.post_images AS pi
    WHERE pi.post_id = v_post_id
    UNION
    SELECT c.storage_path
    FROM public.comments AS c
    WHERE c.post_id = v_post_id
      AND c.storage_path IS NOT NULL
  ) AS paths;

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
      paths.storage_path,
      now()
    FROM UNNEST(v_storage_paths) AS paths(storage_path)
    ON CONFLICT (account_id, bucket_id, storage_path) DO UPDATE
      SET attempt_count = 0,
          last_error = NULL,
          next_retry_at = now(),
          lease_until = NULL;
  END IF;

  DELETE FROM public.posts
  WHERE id = v_post_id;

  RETURN JSONB_BUILD_OBJECT(
    'post_id', v_post_id,
    'storage_paths', TO_JSONB(v_storage_paths)
  );
END;
$$;

REVOKE EXECUTE ON FUNCTION public.delete_post_with_images(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_post_with_images(UUID) TO authenticated;
