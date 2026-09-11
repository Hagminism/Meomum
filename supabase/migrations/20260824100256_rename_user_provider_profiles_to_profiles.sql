-- 1. post_likes의 외래키가 레거시 profiles를 보고 있다면 auth.users(id)를 참조하도록 변경
ALTER TABLE public.post_likes DROP CONSTRAINT IF EXISTS post_likes_user_id_fkey;

ALTER TABLE public.post_likes
  ADD CONSTRAINT post_likes_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES auth.users(id)
  ON DELETE CASCADE;

-- 2. posts의 기존 외래키 제약조건 제거
ALTER TABLE public.posts DROP CONSTRAINT IF EXISTS posts_author_id_fkey;
ALTER TABLE public.posts DROP CONSTRAINT IF EXISTS posts_author_profile_fkey;

-- 3. 레거시 profiles 테이블 삭제
DROP TABLE IF EXISTS public.profiles CASCADE;

-- 4. user_provider_profiles 테이블을 profiles로 이름 변경
ALTER TABLE public.user_provider_profiles RENAME TO profiles;

-- 5. posts 테이블과 새로 변경된 profiles 테이블 간 외래키 연결
ALTER TABLE public.posts
  ADD CONSTRAINT posts_author_profile_fkey
  FOREIGN KEY (author_id, author_provider)
  REFERENCES public.profiles(user_id, provider)
  ON DELETE CASCADE;

-- 6. profiles RLS 정책 확인 및 재설정
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public provider profiles are viewable by everyone." ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own provider profile." ON public.profiles;
DROP POLICY IF EXISTS "Users can update own provider profile." ON public.profiles;
DROP POLICY IF EXISTS "Users can delete own provider profile." ON public.profiles;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile." ON public.profiles;

CREATE POLICY "Public profiles are viewable by everyone."
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert own profile."
  ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile."
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own profile."
  ON public.profiles FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
