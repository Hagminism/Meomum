-- COALESCE로 인해 trigram 인덱스가 사용되지 않던 지점명·주소 검색 조건을 보정합니다.
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
        AND cs.brch_nm IS NOT NULL
        AND cs.brch_nm ILIKE '%' || normalized.query || '%'
      ORDER BY cs.brch_nm <-> normalized.query
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
        AND cs.address IS NOT NULL
        AND cs.address ILIKE '%' || normalized.query || '%'
      ORDER BY cs.address <-> normalized.query
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
