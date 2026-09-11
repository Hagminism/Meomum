-- 1. profiles 테이블 생성
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname TEXT NOT NULL DEFAULT '',
  profile_image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. 기존 auth.users 데이터가 있다면 profiles로 마이그레이션
INSERT INTO public.profiles (id, nickname, profile_image_url)
SELECT 
  id,
  COALESCE(raw_user_meta_data->>'full_name', raw_user_meta_data->>'name', raw_user_meta_data->>'nickname', '사용자'),
  COALESCE(raw_user_meta_data->>'avatar_url', raw_user_meta_data->>'picture', raw_user_meta_data->>'profile_image', NULL)
FROM auth.users
ON CONFLICT (id) DO NOTHING;

-- 3. 신규 가입 유저 자동 프로필 생성 트리거
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nickname, profile_image_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'nickname', '사용자'),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'picture', NEW.raw_user_meta_data->>'profile_image', NULL)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. posts 테이블 생성
CREATE TABLE IF NOT EXISTS public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
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

CREATE INDEX IF NOT EXISTS idx_posts_region ON public.posts(upper_region, lower_region);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON public.posts(created_at DESC);

-- 5. post_likes 테이블 생성
CREATE TABLE IF NOT EXISTS public.post_likes (
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, post_id)
);

CREATE INDEX IF NOT EXISTS idx_post_likes_post_id ON public.post_likes(post_id);

-- 6. RLS (Row Level Security) 활성화 및 정책 설정
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;

-- profiles 정책
CREATE POLICY "Public profiles are viewable by everyone." 
  ON public.profiles FOR SELECT 
  USING (true);

CREATE POLICY "Users can update own profile." 
  ON public.profiles FOR UPDATE 
  USING (auth.uid() = id);

-- posts 정책
CREATE POLICY "Posts are viewable by authenticated users." 
  ON public.posts FOR SELECT 
  TO authenticated 
  USING (true);

CREATE POLICY "Authenticated users can create posts." 
  ON public.posts FOR INSERT 
  TO authenticated 
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can update own posts." 
  ON public.posts FOR UPDATE 
  TO authenticated 
  USING (auth.uid() = author_id);

CREATE POLICY "Users can delete own posts." 
  ON public.posts FOR DELETE 
  TO authenticated 
  USING (auth.uid() = author_id);

-- post_likes 정책
CREATE POLICY "Likes are viewable by authenticated users." 
  ON public.post_likes FOR SELECT 
  TO authenticated 
  USING (true);

CREATE POLICY "Users can insert own likes." 
  ON public.post_likes FOR INSERT 
  TO authenticated 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own likes." 
  ON public.post_likes FOR DELETE 
  TO authenticated 
  USING (auth.uid() = user_id);

-- 7. Supabase Storage: 'community-images' 버킷 생성 및 RLS 정책
-- 버킷 생성 (Dashboard 또는 SQL)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('community-images', 'community-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage 정책
CREATE POLICY "Community images are publicly accessible."
  ON storage.objects FOR SELECT
  USING (bucket_id = 'community-images');

CREATE POLICY "Authenticated users can upload community images."
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'community-images');

CREATE POLICY "Users can delete own community images."
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'community-images' AND auth.uid()::text = (storage.foldername(name))[1]);
