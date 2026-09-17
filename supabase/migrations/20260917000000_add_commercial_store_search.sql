-- 상호명, 지점명, 주소의 전국 매장 검색을 위한 trigram 검색 지원
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX IF NOT EXISTS idx_commercial_stores_name_trgm
  ON commercial_stores USING GIN (bizes_nm gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_commercial_stores_branch_name_trgm
  ON commercial_stores USING GIN (brch_nm gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_commercial_stores_address_trgm
  ON commercial_stores USING GIN (address gin_trgm_ops);

CREATE OR REPLACE FUNCTION search_commercial_stores(
  p_query TEXT,
  p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
  id TEXT,
  name TEXT,
  "branchName" TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  "industryLargeCode" TEXT,
  "industryLargeName" TEXT,
  address TEXT
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
    cs.address
  FROM commercial_stores AS cs
  WHERE NULLIF(BTRIM(p_query), '') IS NOT NULL
    AND (
      cs.bizes_nm ILIKE '%' || BTRIM(p_query) || '%'
      OR COALESCE(cs.brch_nm, '') ILIKE '%' || BTRIM(p_query) || '%'
      OR COALESCE(cs.address, '') ILIKE '%' || BTRIM(p_query) || '%'
    )
  ORDER BY
    GREATEST(
      similarity(cs.bizes_nm, BTRIM(p_query)),
      similarity(COALESCE(cs.brch_nm, ''), BTRIM(p_query)),
      similarity(COALESCE(cs.address, ''), BTRIM(p_query))
    ) DESC,
    cs.bizes_nm,
    cs.brch_nm
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 50), 1), 50);
$$;
