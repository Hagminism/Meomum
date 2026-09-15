-- PostgreSQL이 INSERT SELECT의 NULL 타입을 명확하게 추론하도록 보정합니다.
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
