-- 온보딩에서 사용하는 거주 지역을 프로필에 저장합니다.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS upper_region TEXT,
  ADD COLUMN IF NOT EXISTS lower_region TEXT;

-- 닉네임과 지역 데이터의 기본 무결성을 DB에서도 보장합니다.
ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_nickname_length_check,
  DROP CONSTRAINT IF EXISTS profiles_region_pair_check;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_nickname_length_check
    CHECK (CHAR_LENGTH(BTRIM(nickname)) BETWEEN 1 AND 20),
  ADD CONSTRAINT profiles_region_pair_check
    CHECK (
      (upper_region IS NULL AND lower_region IS NULL)
      OR (NULLIF(BTRIM(upper_region), '') IS NOT NULL
          AND NULLIF(BTRIM(lower_region), '') IS NOT NULL)
    );

-- profiles는 기존 migration에서 SELECT만 명시되어 있어 온보딩 저장 권한을 추가합니다.
GRANT UPDATE (nickname, profile_image_url, upper_region, lower_region)
  ON TABLE public.profiles TO authenticated;

-- 프로필 사진은 계정별 최신 1개만 저장하는 Public Storage 버킷을 사용합니다.
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Profile images are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own profile images" ON storage.objects;

CREATE POLICY "Profile images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile-images');

CREATE POLICY "Users can upload own profile images"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'profile-images'
    AND array_length(storage.foldername(name), 1) = 2
    AND name LIKE 'accounts/' || public.current_account_id()::text || '/profile.%'
  );

CREATE POLICY "Users can update own profile images"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'profile-images'
    AND array_length(storage.foldername(name), 1) = 2
    AND name LIKE 'accounts/' || public.current_account_id()::text || '/profile.%'
  )
  WITH CHECK (
    bucket_id = 'profile-images'
    AND array_length(storage.foldername(name), 1) = 2
    AND name LIKE 'accounts/' || public.current_account_id()::text || '/profile.%'
  );

CREATE POLICY "Users can delete own profile images"
  ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'profile-images'
    AND array_length(storage.foldername(name), 1) = 2
    AND name LIKE 'accounts/' || public.current_account_id()::text || '/profile.%'
  );
