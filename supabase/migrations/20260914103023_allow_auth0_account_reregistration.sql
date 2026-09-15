-- 삭제 완료된 Auth0 식별자의 tombstone은 유지하되, 탈퇴 이후 새로 발급된
-- 토큰으로는 같은 Auth0 identity가 다시 가입할 수 있게 합니다.
-- 탈퇴 작업이 진행 중이거나 탈퇴 완료 시각 이전에 발급된 토큰은 계속 차단합니다.
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
  v_token_issued_at TIMESTAMPTZ;
  v_deletion_completed_at TIMESTAMPTZ;
BEGIN
  IF issuer IS NULL OR issuer = '' OR subject IS NULL OR subject = '' THEN
    RAISE EXCEPTION 'Authenticated JWT must include iss and sub claims';
  END IF;

  IF jsonb_typeof(claims -> 'iat') = 'number' THEN
    v_token_issued_at := to_timestamp((claims ->> 'iat')::DOUBLE PRECISION);
  END IF;

  SELECT queue.completed_at
  INTO v_deletion_completed_at
  FROM public.auth0_user_deletion_queue AS queue
  WHERE queue.auth_issuer = issuer
    AND queue.auth_subject = subject;

  IF FOUND AND (
    v_deletion_completed_at IS NULL
    OR v_token_issued_at IS NULL
    OR v_token_issued_at <= v_deletion_completed_at
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
