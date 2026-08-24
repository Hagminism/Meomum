-- 1. post_likes 테이블에 provider 컬럼 추가
ALTER TABLE public.post_likes ADD COLUMN IF NOT EXISTS provider TEXT NOT NULL DEFAULT 'google';

-- 2. 기존 기본키 및 외래키 제약조건 재설정
ALTER TABLE public.post_likes DROP CONSTRAINT IF EXISTS post_likes_pkey CASCADE;
ALTER TABLE public.post_likes DROP CONSTRAINT IF EXISTS post_likes_user_id_fkey CASCADE;
ALTER TABLE public.post_likes DROP CONSTRAINT IF EXISTS post_likes_profile_fkey CASCADE;

-- (user_id, provider, post_id) 복합 기본키 설정
ALTER TABLE public.post_likes ADD PRIMARY KEY (user_id, provider, post_id);

-- profiles 테이블과의 외래키 연결
ALTER TABLE public.post_likes
  ADD CONSTRAINT post_likes_profile_fkey
  FOREIGN KEY (user_id, provider)
  REFERENCES public.profiles(user_id, provider)
  ON DELETE CASCADE;

-- 3. RLS 정책 업데이트
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Likes are viewable by authenticated users." ON public.post_likes;
DROP POLICY IF EXISTS "Users can insert own likes." ON public.post_likes;
DROP POLICY IF EXISTS "Users can delete own likes." ON public.post_likes;

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
