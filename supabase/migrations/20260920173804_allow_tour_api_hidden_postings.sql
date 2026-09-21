-- 관광인 API의 showYn=N 채용정보도 원본 상태를 보존한 채 게시판에서 조회할 수 있도록 합니다.

DROP POLICY IF EXISTS "Tour API job postings are viewable by authenticated users."
  ON public.tour_api_job_postings;

CREATE POLICY "Tour API job postings are viewable by authenticated users."
  ON public.tour_api_job_postings FOR SELECT
  TO authenticated
  USING (true);
