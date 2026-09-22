-- 대량 매장 데이터 검색 시 전체 검색 결과를 정렬하지 않도록 후보군을 제한합니다.
CREATE INDEX IF NOT EXISTS idx_commercial_stores_name_trgm_gist
  ON commercial_stores USING GIST (bizes_nm gist_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_commercial_stores_branch_name_trgm_gist
  ON commercial_stores USING GIST (brch_nm gist_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_commercial_stores_address_trgm_gist
  ON commercial_stores USING GIST (address gist_trgm_ops);

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
  WITH normalized AS (
    SELECT BTRIM(p_query) AS query
  ),
  ranked_candidates AS (
    (
      SELECT
        cs.*,
        normalized.query
      FROM commercial_stores AS cs
      CROSS JOIN normalized
      WHERE normalized.query <> ''
        AND cs.bizes_nm ILIKE '%' || normalized.query || '%'
      ORDER BY cs.bizes_nm <-> normalized.query
      LIMIT 200
    )
    UNION ALL
    (
      SELECT
        cs.*,
        normalized.query
      FROM commercial_stores AS cs
      CROSS JOIN normalized
      WHERE normalized.query <> ''
        AND COALESCE(cs.brch_nm, '') ILIKE '%' || normalized.query || '%'
      ORDER BY COALESCE(cs.brch_nm, '') <-> normalized.query
      LIMIT 200
    )
    UNION ALL
    (
      SELECT
        cs.*,
        normalized.query
      FROM commercial_stores AS cs
      CROSS JOIN normalized
      WHERE normalized.query <> ''
        AND COALESCE(cs.address, '') ILIKE '%' || normalized.query || '%'
      ORDER BY COALESCE(cs.address, '') <-> normalized.query
      LIMIT 200
    )
  ),
  deduplicated AS (
    SELECT DISTINCT ON (bizes_id)
      ranked_candidates.*
    FROM ranked_candidates
    ORDER BY
      bizes_id,
      GREATEST(
        similarity(bizes_nm, query),
        similarity(COALESCE(brch_nm, ''), query),
        similarity(COALESCE(address, ''), query)
      ) DESC
  )
  SELECT
    dc.bizes_id AS id,
    dc.bizes_nm AS name,
    dc.brch_nm AS "branchName",
    dc.lat AS latitude,
    dc.lon AS longitude,
    dc.inds_lcls_cd AS "industryLargeCode",
    dc.inds_lcls_nm AS "industryLargeName",
    dc.address
  FROM deduplicated AS dc
  ORDER BY
    GREATEST(
      similarity(dc.bizes_nm, dc.query),
      similarity(COALESCE(dc.brch_nm, ''), dc.query),
      similarity(COALESCE(dc.address, ''), dc.query)
    ) DESC,
    dc.bizes_nm,
    dc.brch_nm
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 50), 1), 50);
$$;
