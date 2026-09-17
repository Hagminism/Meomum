-- 삭제된 댓글과 대댓글을 포함한 전체 댓글 행 수로 기존 게시글 집계 값을 보정합니다.
UPDATE public.posts AS posts
SET comment_count = counts.total_count
FROM (
  SELECT post_id, COUNT(*)::INTEGER AS total_count
  FROM public.comments
  GROUP BY post_id
) AS counts
WHERE posts.id = counts.post_id;

UPDATE public.posts AS posts
SET comment_count = 0
WHERE NOT EXISTS (
  SELECT 1
  FROM public.comments
  WHERE comments.post_id = posts.id
);

-- 댓글 삭제는 soft-delete만 수행하고 게시글 댓글 수는 감소시키지 않습니다.
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
  v_storage_path TEXT;
BEGIN
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION '로그인이 필요합니다.';
  END IF;

  SELECT storage_path
  INTO v_storage_path
  FROM public.comments
  WHERE id = p_comment_id
    AND author_id = v_account_id
    AND is_deleted = false
  FOR UPDATE;

  IF NOT FOUND THEN
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

  IF v_storage_path IS NOT NULL THEN
    PERFORM public.enqueue_storage_cleanup(
      'community-images',
      ARRAY[v_storage_path]
    );
  END IF;

  RETURN TRUE;
END;
$$;
