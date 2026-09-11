-- Avoid a PL/pgSQL variable name collision with public.profiles.account_id.
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
BEGIN
  IF issuer IS NULL OR issuer = '' OR subject IS NULL OR subject = '' THEN
    RAISE EXCEPTION 'Authenticated JWT must include iss and sub claims';
  END IF;

  INSERT INTO public.accounts (auth_issuer, auth_subject, email)
  VALUES (issuer, subject, NULLIF(claims ->> 'email', ''))
  ON CONFLICT (auth_issuer, auth_subject) DO UPDATE
    SET email = COALESCE(EXCLUDED.email, public.accounts.email),
        updated_at = now()
  RETURNING id INTO v_account_id;

  INSERT INTO public.profiles (account_id, nickname, profile_image_url)
  VALUES (
    v_account_id,
    COALESCE(
      NULLIF(claims ->> 'nickname', ''),
      NULLIF(claims ->> 'name', ''),
      '사용자'
    ),
    NULLIF(claims ->> 'picture', '')
  )
  ON CONFLICT (account_id) DO NOTHING;

  RETURN v_account_id;
END;
$$;
