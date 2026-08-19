-- 반경 내 매장 검색 RPC 함수 (경량화 스키마 최적화)
CREATE OR REPLACE FUNCTION get_nearby_stores(
  p_lat DOUBLE PRECISION,
  p_lon DOUBLE PRECISION,
  p_radius_m INTEGER,
  p_inds_lcls_cds TEXT[] DEFAULT '{}',
  p_inds_mcls_cds TEXT[] DEFAULT '{}',
  p_inds_scls_cds TEXT[] DEFAULT '{}'
)
RETURNS TABLE (
  id TEXT,
  name TEXT,
  "branchName" TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  "industryLargeCode" TEXT,
  "industryLargeName" TEXT,
  address TEXT,
  dist_m DOUBLE PRECISION
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    cs.bizes_id AS id,
    cs.bizes_nm AS name,
    cs.brch_nm AS "branchName",
    cs.lat AS latitude,
    cs.lon AS longitude,
    cs.inds_lcls_cd AS "industryLargeCode",
    cs.inds_lcls_nm AS "industryLargeName",
    cs.address AS address,
    ST_Distance(cs.location, ST_SetSRID(ST_MakePoint(p_lon, p_lat), 4326)::geography) AS dist_m
  FROM commercial_stores cs
  WHERE
    ST_DWithin(cs.location, ST_SetSRID(ST_MakePoint(p_lon, p_lat), 4326)::geography, p_radius_m)
    AND (
      (cardinality(p_inds_lcls_cds) = 0 AND cardinality(p_inds_mcls_cds) = 0 AND cardinality(p_inds_scls_cds) = 0)
      OR (cardinality(p_inds_lcls_cds) > 0 AND cs.inds_lcls_cd = ANY(p_inds_lcls_cds))
      OR (cardinality(p_inds_mcls_cds) > 0 AND cs.inds_mcls_cd = ANY(p_inds_mcls_cds))
      OR (cardinality(p_inds_scls_cds) > 0 AND cs.inds_scls_cd = ANY(p_inds_scls_cds))
    )
  ORDER BY dist_m ASC;
$$;
