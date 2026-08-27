-- 1. user_provider_profiles 테이블 생성 (user_id + provider 복합 기본키)
CREATE TABLE IF NOT EXISTS public.user_provider_profiles (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  provider TEXT NOT NULL, -- 'google', 'kakao', 'naver'
  nickname TEXT NOT NULL DEFAULT '',
  profile_image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, provider)
);

-- 2. 기존 profiles 및 auth.users 메타데이터로부터 user_provider_profiles로 데이터 마이그레이션
-- 2-1) 구글 유저
INSERT INTO public.user_provider_profiles (user_id, provider, nickname, profile_image_url)
SELECT 
  id,
  'google',
  COALESCE(raw_user_meta_data->>'full_name', raw_user_meta_data->>'name', raw_user_meta_data->>'nickname', '사용자'),
  COALESCE(raw_user_meta_data->>'picture', raw_user_meta_data->>'avatar_url', NULL)
FROM auth.users
WHERE raw_user_meta_data->>'iss' LIKE '%google%' OR raw_app_meta_data->>'provider' = 'google'
ON CONFLICT (user_id, provider) DO UPDATE 
SET nickname = EXCLUDED.nickname, profile_image_url = EXCLUDED.profile_image_url;

-- 2-2) 카카오 유저
INSERT INTO public.user_provider_profiles (user_id, provider, nickname, profile_image_url)
SELECT 
  id,
  'kakao',
  COALESCE(raw_user_meta_data->>'full_name', raw_user_meta_data->>'name', raw_user_meta_data->>'nickname', '사용자'),
  COALESCE(raw_user_meta_data->>'avatar_url', raw_user_meta_data->>'profile_image', NULL)
FROM auth.users
WHERE raw_user_meta_data->>'iss' LIKE '%kakao%' OR raw_app_meta_data->>'provider' = 'kakao'
ON CONFLICT (user_id, provider) DO UPDATE 
SET nickname = EXCLUDED.nickname, profile_image_url = EXCLUDED.profile_image_url;

-- 2-3) 네이버 유저
INSERT INTO public.user_provider_profiles (user_id, provider, nickname, profile_image_url)
SELECT 
  id,
  'naver',
  COALESCE(raw_user_meta_data->>'name', raw_user_meta_data->>'nickname', raw_user_meta_data->>'full_name', '사용자'),
  COALESCE(raw_user_meta_data->>'picture', raw_user_meta_data->>'profile_image', NULL)
FROM auth.users
WHERE raw_user_meta_data->>'picture' LIKE '%pstatic%' OR raw_app_meta_data->>'provider' IN ('naver', 'custom:naver')
ON CONFLICT (user_id, provider) DO UPDATE 
SET nickname = EXCLUDED.nickname, profile_image_url = EXCLUDED.profile_image_url;

-- 3. posts 테이블에 author_provider 컬럼 추가
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS author_provider TEXT NOT NULL DEFAULT 'google';

-- posts와 user_provider_profiles 외래키 제약조건 설정
ALTER TABLE public.posts DROP CONSTRAINT IF EXISTS posts_author_id_fkey;
ALTER TABLE public.posts DROP CONSTRAINT IF EXISTS posts_author_profile_fkey;

ALTER TABLE public.posts 
  ADD CONSTRAINT posts_author_profile_fkey 
  FOREIGN KEY (author_id, author_provider) 
  REFERENCES public.user_provider_profiles(user_id, provider) 
  ON DELETE CASCADE;

-- 4. RLS 정책 설정
ALTER TABLE public.user_provider_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public provider profiles are viewable by everyone." 
  ON public.user_provider_profiles FOR SELECT 
  USING (true);

CREATE POLICY "Users can insert own provider profile." 
  ON public.user_provider_profiles FOR INSERT 
  TO authenticated 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own provider profile." 
  ON public.user_provider_profiles FOR UPDATE 
  TO authenticated 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own provider profile." 
  ON public.user_provider_profiles FOR DELETE 
  TO authenticated 
  USING (auth.uid() = user_id);
