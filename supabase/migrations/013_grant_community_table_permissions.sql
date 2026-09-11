-- RLS 정책과 별도로 Data API 역할의 테이블 권한을 명시한다.
-- 익명 사용자(anon)에게는 커뮤니티 테이블 권한을 부여하지 않는다.
GRANT USAGE ON SCHEMA public TO authenticated;

GRANT SELECT, UPDATE ON public.posts TO authenticated;
GRANT SELECT ON public.profiles TO authenticated;
GRANT SELECT ON public.post_images TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.post_likes TO authenticated;
