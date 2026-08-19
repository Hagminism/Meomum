-- 1. PostGIS 확장 활성화
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. commercial_stores 테이블 생성 (경량화: 9개 핵심 컬럼만 유지)
CREATE TABLE IF NOT EXISTS commercial_stores (
  bizes_id TEXT PRIMARY KEY,
  bizes_nm TEXT NOT NULL,
  brch_nm TEXT,
  inds_lcls_cd TEXT NOT NULL,
  inds_lcls_nm TEXT,
  inds_mcls_cd TEXT,
  inds_scls_cd TEXT,
  address TEXT,
  lon DOUBLE PRECISION NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  location GEOGRAPHY(Point, 4326)
);

-- 3. lat, lon으로부터 location(geography) 자동 생성 트리거
CREATE OR REPLACE FUNCTION update_commercial_store_location()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.lon IS NOT NULL AND NEW.lat IS NOT NULL THEN
    NEW.location := ST_SetSRID(ST_MakePoint(NEW.lon, NEW.lat), 4326)::geography;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_commercial_store_location ON commercial_stores;
CREATE TRIGGER trg_update_commercial_store_location
BEFORE INSERT OR UPDATE OF lon, lat ON commercial_stores
FOR EACH ROW
EXECUTE FUNCTION update_commercial_store_location();

-- 4. 인덱스 생성 (공간 인덱스 및 업종 필터 인덱스)
CREATE INDEX IF NOT EXISTS idx_commercial_stores_location ON commercial_stores USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_commercial_stores_inds_lcls_cd ON commercial_stores (inds_lcls_cd);
CREATE INDEX IF NOT EXISTS idx_commercial_stores_inds_mcls_cd ON commercial_stores (inds_mcls_cd);
CREATE INDEX IF NOT EXISTS idx_commercial_stores_inds_scls_cd ON commercial_stores (inds_scls_cd);
