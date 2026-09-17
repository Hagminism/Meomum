-- 좋아요 목록이 현재 인증 계정의 행만 반환하도록 조회 범위를 제한합니다.
DROP POLICY IF EXISTS "Likes are viewable by authenticated users"
  ON public.post_likes;

CREATE POLICY "Users can view own likes"
  ON public.post_likes
  FOR SELECT
  TO authenticated
  USING (account_id = public.current_account_id());
