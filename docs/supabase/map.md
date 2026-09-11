# 지도 RPC 및 Trigger

## 1. `get_nearby_stores(...)`

현재 위치 주변의 상가를 검색하는 RPC다.

호출 위치:

- [`commercial_store_data_source_impl.dart`](../../lib/core/data/data_source/commercial_store/commercial_store_data_source_impl.dart)

### 입력값

- `p_lat`: 현재 위치 위도
- `p_lon`: 현재 위치 경도
- `p_radius_m`: 검색 반경(미터)
- `p_inds_lcls_cds`: 대분류 업종 코드 배열
- `p_inds_mcls_cds`: 중분류 업종 코드 배열
- `p_inds_scls_cds`: 소분류 업종 코드 배열

### 수행 흐름

```text
현재 위치 조회
    ↓
get_nearby_stores(lat, lon, radius, category codes)
    ↓
PostGIS ST_DWithin으로 반경 내 상가 필터
    ↓
대·중·소 업종 조건 적용
    ↓
ST_Distance로 거리 계산
    ↓
가까운 순으로 정렬
    ↓
지도 상가 목록 반환
```

반환 데이터에는 상가 ID·이름·지점명·좌표·업종·주소·거리(`dist_m`)가 포함된다.

정의:

- [`002_create_get_nearby_stores_rpc.sql`](../../supabase/migrations/002_create_get_nearby_stores_rpc.sql)

## 2. `update_commercial_store_location()`

RPC가 아니라 `commercial_stores` 테이블의 좌표 변경 시 자동으로 실행되는 Trigger 함수다.

```text
commercial_stores INSERT 또는 lat/lon UPDATE
    ↓
update_commercial_store_location()
    ↓
위도·경도를 PostGIS geography(Point, 4326)로 변환
    ↓
location 컬럼 저장
```

정의:

- [`001_create_commercial_stores.sql`](../../supabase/migrations/001_create_commercial_stores.sql)
