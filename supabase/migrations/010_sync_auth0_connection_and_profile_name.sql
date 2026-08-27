-- Sync Auth0 metadata that is supplied by the Post Login Action.
-- The external connection is informational only; authorization continues to
-- rely exclusively on the verified issuer and subject pair.
CREATE OR REPLACE FUNCTION public.ensure_account()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
    -- Correct only generated placeholder or email nicknames. A user-selected
    -- nickname must never be overwritten during a later login.
    WHERE public.profiles.nickname = ''
      OR public.profiles.nickname = '사용자'
      OR (
        v_email IS NOT NULL
        AND LOWER(public.profiles.nickname) = LOWER(v_email)
      );

  RETURN v_account_id;
END;
$$;
