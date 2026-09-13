-- 게시글과 연결된 이미지 정리 대상을 기록한 뒤 게시글을 영구 삭제합니다.
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
    ARRAY_AGG(pi.storage_path ORDER BY pi.sort_order),
    ARRAY[]::TEXT[]
  )
  INTO v_storage_paths
  FROM public.post_images AS pi
  WHERE pi.post_id = v_post_id;

  IF CARDINALITY(v_storage_paths) > 0 THEN
    INSERT INTO public.community_image_cleanup_queue (
      account_id,
      storage_path,
      next_retry_at
    )
    SELECT DISTINCT
      v_account_id,
      storage_path,
      now()
    FROM UNNEST(v_storage_paths) AS paths(storage_path)
    ON CONFLICT (account_id, storage_path) DO UPDATE
      SET attempt_count = 0,
          last_error = NULL,
          next_retry_at = now();
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

-- 삭제는 이미지 정리 큐를 거치는 RPC만 사용하도록 직접 DELETE 권한은 부여하지 않습니다.
REVOKE DELETE ON public.posts FROM authenticated;
