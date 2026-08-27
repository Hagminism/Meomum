-- Auth0 migration: this project has no production community/auth data yet.
-- Keep commercial_stores and all PostGIS objects intact; replace only the
-- Supabase Auth-coupled community schema with the internal accounts model.

-- The old trigger is tied to auth.users and must not create profiles anymore.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- These tables only contain incomplete pre-release data. Do not use this
-- migration for a production database with community data; use an
-- expand/migrate/verify/contract migration instead.
DROP TABLE IF EXISTS public.post_likes CASCADE;
DROP TABLE IF EXISTS public.posts CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

CREATE TABLE public.accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_issuer TEXT NOT NULL,
  auth_subject TEXT NOT NULL,
  auth_connection TEXT,
  email TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT accounts_auth_identity_key UNIQUE (auth_issuer, auth_subject)
);

CREATE TABLE public.profiles (
  account_id UUID PRIMARY KEY REFERENCES public.accounts(id) ON DELETE CASCADE,
  nickname TEXT NOT NULL DEFAULT '',
  profile_image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES public.profiles(account_id) ON DELETE CASCADE,
  upper_region TEXT NOT NULL,
  lower_region TEXT NOT NULL,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  image_urls TEXT[] NOT NULL DEFAULT '{}',
  like_count INT NOT NULL DEFAULT 0,
  comment_count INT NOT NULL DEFAULT 0,
  place_name TEXT,
  place_latitude DOUBLE PRECISION,
  place_longitude DOUBLE PRECISION,
  place_address TEXT,
  place_road_address TEXT,
  place_category TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_posts_region ON public.posts(upper_region, lower_region);
CREATE INDEX idx_posts_created_at ON public.posts(created_at DESC);

CREATE TABLE public.post_likes (
  account_id UUID NOT NULL REFERENCES public.profiles(account_id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (account_id, post_id)
);

CREATE INDEX idx_post_likes_post_id ON public.post_likes(post_id);

-- Reads the verified third-party JWT only on the server. Clients never pass an
-- Auth0 subject or an account id to establish their identity.
CREATE OR REPLACE FUNCTION public.current_account_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id
  FROM public.accounts
  WHERE auth_issuer = auth.jwt() ->> 'iss'
    AND auth_subject = auth.jwt() ->> 'sub'
$$;

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

GRANT EXECUTE ON FUNCTION public.current_account_id() TO authenticated;
GRANT EXECUTE ON FUNCTION public.ensure_account() TO authenticated;

ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Accounts are readable by their owner"
  ON public.accounts FOR SELECT TO authenticated
  USING (id = public.current_account_id());

CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles FOR SELECT USING (true);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE TO authenticated
  USING (account_id = public.current_account_id())
  WITH CHECK (account_id = public.current_account_id());

CREATE POLICY "Posts are viewable by authenticated users"
  ON public.posts FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can create own posts"
  ON public.posts FOR INSERT TO authenticated
  WITH CHECK (author_id = public.current_account_id());

CREATE POLICY "Users can update own posts"
  ON public.posts FOR UPDATE TO authenticated
  USING (author_id = public.current_account_id())
  WITH CHECK (author_id = public.current_account_id());

CREATE POLICY "Users can delete own posts"
  ON public.posts FOR DELETE TO authenticated
  USING (author_id = public.current_account_id());

CREATE POLICY "Likes are viewable by authenticated users"
  ON public.post_likes FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can insert own likes"
  ON public.post_likes FOR INSERT TO authenticated
  WITH CHECK (account_id = public.current_account_id());

CREATE POLICY "Users can delete own likes"
  ON public.post_likes FOR DELETE TO authenticated
  USING (account_id = public.current_account_id());

INSERT INTO storage.buckets (id, name, public)
VALUES ('community-images', 'community-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Community images are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload community images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own community images" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload own community images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own community images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own community images" ON storage.objects;

CREATE POLICY "Community images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'community-images');

CREATE POLICY "Users can upload own community images"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'community-images'
    AND (storage.foldername(name))[1] = 'accounts'
    AND (storage.foldername(name))[2] = public.current_account_id()::text
  );

CREATE POLICY "Users can update own community images"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'community-images'
    AND (storage.foldername(name))[1] = 'accounts'
    AND (storage.foldername(name))[2] = public.current_account_id()::text
  )
  WITH CHECK (
    bucket_id = 'community-images'
    AND (storage.foldername(name))[1] = 'accounts'
    AND (storage.foldername(name))[2] = public.current_account_id()::text
  );

CREATE POLICY "Users can delete own community images"
  ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'community-images'
    AND (storage.foldername(name))[1] = 'accounts'
    AND (storage.foldername(name))[2] = public.current_account_id()::text
  );
