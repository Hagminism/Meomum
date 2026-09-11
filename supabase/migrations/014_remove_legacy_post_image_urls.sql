-- 게시글 이미지의 단일 저장 경로를 post_images 테이블로 통합합니다.
-- 컬럼 삭제 전에 RPC가 더 이상 image_urls를 참조하지 않도록 갱신합니다.
CREATE OR REPLACE FUNCTION public.create_post_with_images(
  p_upper_region TEXT,
  p_lower_region TEXT,
  p_category TEXT,
  p_title TEXT,
  p_content TEXT,
  p_images JSONB DEFAULT '[]'::JSONB,
  p_place_name TEXT DEFAULT NULL,
  p_place_latitude DOUBLE PRECISION DEFAULT NULL,
  p_place_longitude DOUBLE PRECISION DEFAULT NULL,
  p_place_address TEXT DEFAULT NULL,
  p_place_road_address TEXT DEFAULT NULL,
  p_place_category TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_account_id UUID := public.current_account_id();
  v_post_id UUID;
  v_image JSONB;
  v_image_count INTEGER;
BEGIN
  IF v_account_id IS NULL THEN
    RAISE EXCEPTION 'Authenticated account is required';
  END IF;

  IF NULLIF(BTRIM(p_upper_region), '') IS NULL
    OR NULLIF(BTRIM(p_lower_region), '') IS NULL THEN
    RAISE EXCEPTION '게시 지역을 입력해주세요.';
  END IF;

  IF NULLIF(BTRIM(p_title), '') IS NULL THEN
    RAISE EXCEPTION '제목을 입력해주세요.';
  END IF;

  IF NULLIF(BTRIM(p_content), '') IS NULL THEN
    RAISE EXCEPTION '내용을 입력해주세요.';
  END IF;

  IF CHAR_LENGTH(BTRIM(p_title)) > 50 THEN
    RAISE EXCEPTION '제목은 50자 이내로 입력해주세요.';
  END IF;

  IF CHAR_LENGTH(BTRIM(p_content)) > 10000 THEN
    RAISE EXCEPTION '본문은 10,000자 이내로 입력해주세요.';
  END IF;

  IF JSONB_TYPEOF(p_images) <> 'array' THEN
    RAISE EXCEPTION '이미지 목록 형식이 올바르지 않습니다.';
  END IF;

  v_image_count := JSONB_ARRAY_LENGTH(p_images);
  IF v_image_count > 10 THEN
    RAISE EXCEPTION '이미지는 최대 10개까지 등록할 수 있습니다.';
  END IF;

  INSERT INTO public.posts (
    author_id,
    upper_region,
    lower_region,
    category,
    title,
    content,
    place_name,
    place_latitude,
    place_longitude,
    place_address,
    place_road_address,
    place_category
  )
  VALUES (
    v_account_id,
    BTRIM(p_upper_region),
    BTRIM(p_lower_region),
    BTRIM(p_category),
    BTRIM(p_title),
    BTRIM(p_content),
    NULLIF(BTRIM(p_place_name), ''),
    p_place_latitude,
    p_place_longitude,
    NULLIF(BTRIM(p_place_address), ''),
    NULLIF(BTRIM(p_place_road_address), ''),
    NULLIF(BTRIM(p_place_category), '')
  )
  RETURNING id INTO v_post_id;

  FOR v_image IN SELECT value FROM JSONB_ARRAY_ELEMENTS(p_images)
  LOOP
    IF NULLIF(BTRIM(v_image ->> 'storage_path'), '') IS NULL
      OR NULLIF(BTRIM(v_image ->> 'public_url'), '') IS NULL
      OR (v_image ->> 'sort_order')::INTEGER < 0 THEN
      RAISE EXCEPTION '이미지 정보가 올바르지 않습니다.';
    END IF;

    IF SPLIT_PART(v_image ->> 'storage_path', '/', 1) <> 'accounts'
      OR SPLIT_PART(v_image ->> 'storage_path', '/', 2) <> v_account_id::TEXT THEN
      RAISE EXCEPTION '이미지 저장 경로가 올바르지 않습니다.';
    END IF;

    INSERT INTO public.post_images (
      post_id,
      storage_path,
      public_url,
      sort_order
    )
    VALUES (
      v_post_id,
      BTRIM(v_image ->> 'storage_path'),
      BTRIM(v_image ->> 'public_url'),
      (v_image ->> 'sort_order')::INTEGER
    );
  END LOOP;

  RETURN v_post_id;
END;
$$;

ALTER TABLE public.posts
  DROP COLUMN IF EXISTS image_urls;

REVOKE EXECUTE ON FUNCTION public.create_post_with_images(
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  JSONB,
  TEXT,
  DOUBLE PRECISION,
  DOUBLE PRECISION,
  TEXT,
  TEXT,
  TEXT
) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.create_post_with_images(
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  JSONB,
  TEXT,
  DOUBLE PRECISION,
  DOUBLE PRECISION,
  TEXT,
  TEXT,
  TEXT
) TO authenticated;
