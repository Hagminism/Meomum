CREATE OR REPLACE FUNCTION public.toggle_post_like(p_post_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_account_id UUID := public.current_account_id();
  v_current_count INTEGER;
  v_is_liked BOOLEAN;
BEGIN
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION 'Authenticated account is required';
  END IF;

  SELECT like_count
    INTO v_current_count
    FROM public.posts
   WHERE id = p_post_id
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Post not found';
  END IF;

  IF EXISTS (
    SELECT 1
      FROM public.post_likes
     WHERE account_id = v_account_id
       AND post_id = p_post_id
  ) THEN
    DELETE FROM public.post_likes
     WHERE account_id = v_account_id
       AND post_id = p_post_id;
    v_is_liked := FALSE;
    v_current_count := GREATEST(v_current_count - 1, 0);
  ELSE
    INSERT INTO public.post_likes (account_id, post_id)
    VALUES (v_account_id, p_post_id);
    v_is_liked := TRUE;
    v_current_count := v_current_count + 1;
  END IF;

  UPDATE public.posts
     SET like_count = v_current_count
   WHERE id = p_post_id;

  RETURN v_is_liked;
END;
$$;

REVOKE ALL ON FUNCTION public.toggle_post_like(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.toggle_post_like(UUID) FROM anon;
GRANT EXECUTE ON FUNCTION public.toggle_post_like(UUID) TO authenticated;
