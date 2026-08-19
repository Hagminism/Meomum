-- CSV 임포트 스크립트
-- 1. Supabase 대시보드(Table Editor -> Import data via CSV)에서 CSV 파일을 _temp_csv_import 테이블로 업로드합니다.
-- 2. 아래 쿼리를 SQL Editor에서 실행하여 데이터를 commercial_stores 테이블로 이관합니다.
-- 3. 이관 후 _temp_csv_import 테이블은 자동으로 삭제됩니다.

INSERT INTO commercial_stores (
  bizes_id, bizes_nm, brch_nm,
  inds_lcls_cd, inds_lcls_nm, inds_mcls_cd, inds_mcls_nm,
  inds_scls_cd, inds_scls_nm, std_industry_cd, std_industry_nm,
  ctprvn_cd, ctprvn_nm, signgu_cd, signgu_nm,
  adong_cd, adong_nm, bdong_cd, bdong_nm,
  jibun_cd, plot_div_cd, plot_div_nm, main_lot_no, sub_lot_no, lno_adr,
  rdnm_cd, rdnm, bldg_main_no, bldg_sub_no, bldg_mgmt_no, bldg_nm, rdnm_adr,
  old_zip_cd, new_zip_cd, dong_info, floor_info, ho_info,
  lon, lat
)
SELECT
  "상가업소번호", "상호명", "지점명",
  "상권업종대분류코드", "상권업종대분류명", "상권업종중분류코드", "상권업종중분류명",
  "상권업종소분류코드", "상권업종소분류명", "표준산업분류코드", "표준산업분류명",
  "시도코드", "시도명", "시군구코드", "시군구명",
  "행정동코드", "행정동명", "법정동코드", "법정동명",
  "지번코드", "대지구분코드", "대지구분명", "지번본번지"::TEXT, "지번부번지"::TEXT, "지번주소",
  "도로명코드", "도로명", "건물본번지"::TEXT, "건물부번지"::TEXT, "건물관리번호", "건물명", "도로명주소",
  "구우편번호", "신우편번호", "동정보", "층정보", "호정보",
  "경도"::DOUBLE PRECISION, "위도"::DOUBLE PRECISION
FROM _temp_csv_import
WHERE "경도" IS NOT NULL AND "위도" IS NOT NULL
ON CONFLICT (bizes_id) DO UPDATE SET
  bizes_nm = EXCLUDED.bizes_nm,
  brch_nm = EXCLUDED.brch_nm,
  inds_lcls_cd = EXCLUDED.inds_lcls_cd,
  inds_lcls_nm = EXCLUDED.inds_lcls_nm,
  inds_mcls_cd = EXCLUDED.inds_mcls_cd,
  inds_mcls_nm = EXCLUDED.inds_mcls_nm,
  inds_scls_cd = EXCLUDED.inds_scls_cd,
  inds_scls_nm = EXCLUDED.inds_scls_nm,
  std_industry_cd = EXCLUDED.std_industry_cd,
  std_industry_nm = EXCLUDED.std_industry_nm,
  ctprvn_cd = EXCLUDED.ctprvn_cd,
  ctprvn_nm = EXCLUDED.ctprvn_nm,
  signgu_cd = EXCLUDED.signgu_cd,
  signgu_nm = EXCLUDED.signgu_nm,
  adong_cd = EXCLUDED.adong_cd,
  adong_nm = EXCLUDED.adong_nm,
  bdong_cd = EXCLUDED.bdong_cd,
  bdong_nm = EXCLUDED.bdong_nm,
  jibun_cd = EXCLUDED.jibun_cd,
  plot_div_cd = EXCLUDED.plot_div_cd,
  plot_div_nm = EXCLUDED.plot_div_nm,
  main_lot_no = EXCLUDED.main_lot_no,
  sub_lot_no = EXCLUDED.sub_lot_no,
  lno_adr = EXCLUDED.lno_adr,
  rdnm_cd = EXCLUDED.rdnm_cd,
  rdnm = EXCLUDED.rdnm,
  bldg_main_no = EXCLUDED.bldg_main_no,
  bldg_sub_no = EXCLUDED.bldg_sub_no,
  bldg_mgmt_no = EXCLUDED.bldg_mgmt_no,
  bldg_nm = EXCLUDED.bldg_nm,
  rdnm_adr = EXCLUDED.rdnm_adr,
  old_zip_cd = EXCLUDED.old_zip_cd,
  new_zip_cd = EXCLUDED.new_zip_cd,
  dong_info = EXCLUDED.dong_info,
  floor_info = EXCLUDED.floor_info,
  ho_info = EXCLUDED.ho_info,
  lon = EXCLUDED.lon,
  lat = EXCLUDED.lat;

-- 임시 테이블 정리
DROP TABLE IF EXISTS _temp_csv_import;
