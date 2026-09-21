import { createClient } from 'npm:@supabase/supabase-js@2.57.4';

const DEFAULT_API_BASE_URL = 'https://apis.data.go.kr/B551011/tursmService';
const PAGE_SIZE = 100;

type ApiRecord = Record<string, unknown>;
type RegionMapping = {
  upper_region: string;
  lower_region: string;
  regn_cd: string;
  signgu_cd: string;
};

function jsonResponse(
  status: number,
  body: Record<string, unknown>,
): Response {
  return Response.json(body, {
    status,
    headers: { 'Cache-Control': 'no-store' },
  });
}

function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`${name} is not configured`);
  return value;
}

function normalizeServiceKey(serviceKey: string): string {
  const trimmed = serviceKey.trim();
  try {
    return decodeURIComponent(trimmed);
  } catch (_) {
    return trimmed;
  }
}

function serviceRoleKey(): string {
  const directKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (directKey) return directKey;

  const secretKeys = Deno.env.get('SUPABASE_SECRET_KEYS');
  if (secretKeys) {
    try {
      const parsed = JSON.parse(secretKeys) as Record<string, string>;
      if (parsed.default) return parsed.default;
    } catch (_) {
      // 구형/잘못된 Secret Keys 값은 아래의 명확한 오류로 처리합니다.
    }
  }

  throw new Error('Supabase service key is not configured');
}

function scalar(record: ApiRecord, keys: string[]): string | null {
  for (const key of keys) {
    const value = record[key];
    if (value === null || value === undefined) continue;
    const text = String(value).trim();
    if (text) return text;
  }
  return null;
}

function booleanValue(value: string | null): boolean {
  return value?.toUpperCase() === 'Y' || value === '1' || value === 'true';
}

function dateValue(value: string | null): string | null {
  if (!value) return null;
  const compact = value.replace(/[^0-9]/g, '');
  if (compact.length === 8) {
    return `${compact.slice(0, 4)}-${compact.slice(4, 6)}-${compact.slice(6, 8)}`;
  }

  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed.toISOString();
}

function itemList(payload: unknown): ApiRecord[] {
  if (!payload || typeof payload !== 'object') return [];
  const root = payload as ApiRecord;
  const response = (root.response ?? root.body ?? root) as ApiRecord;
  const body = (response.body ?? response) as ApiRecord;
  const items = (body.items ?? body.item ?? body.data) as unknown;

  if (Array.isArray(items)) return items.filter(isRecord);
  if (items && typeof items === 'object') {
    const item = (items as ApiRecord).item;
    if (Array.isArray(item)) return item.filter(isRecord);
    if (isRecord(item)) return [item];
  }
  return isRecord(items) ? [items] : [];
}

function isRecord(value: unknown): value is ApiRecord {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value);
}

function canonicalUpper(value: string): string {
  const aliases: Record<string, string> = {
    서울특별시: '서울',
    부산광역시: '부산',
    대구광역시: '대구',
    인천광역시: '인천',
    광주광역시: '광주',
    대전광역시: '대전',
    울산광역시: '울산',
    세종특별자치시: '세종',
    경기도: '경기',
    강원도: '강원',
    강원특별자치도: '강원',
    충청북도: '충북',
    충청남도: '충남',
    전라북도: '전북',
    전북특별자치도: '전북',
    전라남도: '전남',
    경상북도: '경북',
    경상남도: '경남',
    제주특별자치도: '제주',
  };
  return aliases[value.trim()] ?? value.trim();
}

function canonicalLower(value: string): string {
  return value.replace(/특별시|광역시|특별자치시|특별자치도/g, '').trim();
}

async function tourRequest(
  baseUrl: string,
  serviceKey: string,
  path: string,
  params: Record<string, string> = {},
): Promise<unknown> {
  const url = new URL(`${baseUrl.replace(/\/$/, '')}/${path}`);
  url.searchParams.set('serviceKey', normalizeServiceKey(serviceKey));
  url.searchParams.set('MobileOS', 'ETC');
  url.searchParams.set('MobileApp', 'Meomum');
  url.searchParams.set('_type', 'json');
  for (const [key, value] of Object.entries(params)) url.searchParams.set(key, value);

  const response = await fetch(url);
  if (!response.ok) {
    const responseBody = await response.text();
    throw new Error(
      `${path} request failed: ${response.status} ${providerError(responseBody)}`,
    );
  }
  return await response.json();
}

function providerError(responseBody: string): string {
  const compact = responseBody.replace(/\s+/g, ' ').trim();
  const authMessage = compact.match(/<returnAuthMsg>(.*?)<\/returnAuthMsg>/)?.[1];
  const reasonCode = compact.match(/<returnReasonCode>(.*?)<\/returnReasonCode>/)?.[1];
  if (authMessage || reasonCode) {
    return `[${reasonCode ?? 'unknown'}] ${authMessage ?? 'provider error'}`;
  }

  try {
    const parsed = JSON.parse(compact) as Record<string, unknown>;
    const message = parsed.msg ?? parsed.message ?? parsed.error;
    if (message) return String(message).slice(0, 300);
  } catch (_) {
    // 제공기관이 반환한 비JSON 오류는 축약된 원문으로 안내합니다.
  }

  return compact.slice(0, 300) || 'empty provider response';
}

async function syncRegionMappings(
  supabase: ReturnType<typeof createClient>,
  baseUrl: string,
  serviceKey: string,
): Promise<number> {
  const regionResponse = await tourRequest(baseUrl, serviceKey, 'code', {
    codeType: 'AREA',
    numOfRows: '100',
  });
  const regions = itemList(regionResponse);
  const mappings: RegionMapping[] = [];

  for (const region of regions) {
    const regnCd = scalar(region, ['regnCd', 'areaCode', 'code']);
    const upperName = scalar(region, ['regnNm', 'areaNm', 'codeNm', 'name']);
    if (!regnCd || !upperName) continue;

    const lowerResponse = await tourRequest(baseUrl, serviceKey, 'code', {
      codeType: 'AREA',
      code: regnCd,
      numOfRows: '100',
    });
    for (const lower of itemList(lowerResponse)) {
      const signguCd = scalar(lower, ['signguCd', 'sigunguCode', 'code']);
      const lowerName = scalar(lower, ['signguNm', 'sigunguNm', 'codeNm', 'name']);
      if (!signguCd || !lowerName) continue;
      mappings.push({
        upper_region: canonicalUpper(upperName),
        lower_region: canonicalLower(lowerName),
        regn_cd: regnCd,
        signgu_cd: signguCd,
      });
    }
  }

  if (mappings.length === 0) return 0;
  const { error } = await supabase
    .from('tour_api_region_mappings')
    .upsert(mappings, { onConflict: 'upper_region,lower_region' });
  if (error) throw error;
  return mappings.length;
}

function jobRow(
  item: ApiRecord,
  mapping: RegionMapping,
  codeNames: Map<string, string>,
): Record<string, unknown> | null {
  const empmnInfoNo = scalar(item, ['empmnInfoNo', 'empmn_info_no', 'seq']);
  const title = scalar(item, ['empmnTtl', 'empmnTitle', 'empmnNm', 'title', 'subject']);
  if (!empmnInfoNo || !title) return null;

  const registeredAt = dateValue(scalar(item, ['regDt', 'regDate', 'createdAt']));
  const modifiedAt = dateValue(scalar(item, ['modDt', 'modifiedAt', 'updatedAt']));
  const deadline = dateValue(scalar(item, ['rcptDdlnDe', 'empmnEndYmd', 'empmnEndDt', 'deadline', 'closeDt']));
  const always = booleanValue(
    scalar(item, ['ordtmEmpmnYn', 'alwaysRecruitingYn', 'alwaysYn']),
  );

  return {
    empmn_info_no: empmnInfoNo,
    upper_region: mapping.upper_region,
    lower_region: mapping.lower_region,
    regn_cd: mapping.regn_cd,
    signgu_cd: mapping.signgu_cd,
    company_name: scalar(item, ['corpoNm', 'corpNm', 'companyName', 'company']),
    title,
    workplace: scalar(item, ['wrkpAdres', 'workAddr', 'workplace', 'workLoc', 'address']),
    salary: formatSalary(scalar(item, ['wageAmt', 'salary', 'pay', 'sal'])),
    wage_type: codeName(codeNames, scalar(item, ['salStleCd', 'salTpNm', 'salaryType', 'wageType'])),
    employment_type: codeName(
      codeNames,
      scalar(item, ['eplmtStleN1Cd', 'eplmtStleCd', 'empmnTypeNm', 'employmentType', 'empType']),
    ),
    career_condition: codeName(codeNames, scalar(item, ['crrDivCd', 'career', 'careerCondition'])),
    recruitment_count: scalar(item, ['rcritPnum', 'rcritPsnCnt', 'recruitmentCount', 'count']),
    working_time: scalar(item, ['wrkTimeCn', 'labrTimeCn', 'workTime', 'workingTime']),
    recruitment_deadline: always ? null : deadline,
    is_always_recruiting: always,
    show_yn: !['N', '0', 'false'].includes(
      (scalar(item, ['showYn', 'displayYn', 'useYn']) ?? 'Y').toUpperCase(),
    ),
    registered_at: registeredAt,
    modified_at: modifiedAt,
    original_url: scalar(item, ['tursmEmpmnInfoURL', 'homepageUrl', 'empmnInfoUrl', 'url', 'link']),
    basic_payload: item,
    synced_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };
}

function codeName(codeNames: Map<string, string>, value: string | null): string | null {
  if (!value) return null;
  return codeNames.get(value) ?? value;
}

function formatSalary(value: string | null): string | null {
  if (!value) return null;
  const numericValue = Number(value.replace(/,/g, ''));
  if (!Number.isFinite(numericValue)) return value;
  return `${numericValue.toLocaleString('ko-KR')}원`;
}

async function loadCodeNames(
  baseUrl: string,
  serviceKey: string,
): Promise<Map<string, string>> {
  const codeNames = new Map<string, string>();
  for (const code of ['JC01', 'JC02', 'JC03', 'JC06', 'JC18']) {
    const response = await tourRequest(baseUrl, serviceKey, 'code', {
      codeType: 'COMM',
      code,
      numOfRows: '100',
    });
    for (const item of itemList(response)) {
      const itemCode = scalar(item, ['code']);
      const name = scalar(item, ['name']);
      if (itemCode && name) codeNames.set(itemCode, name);
    }
  }
  return codeNames;
}

async function syncList(
  supabase: ReturnType<typeof createClient>,
  baseUrl: string,
  serviceKey: string,
  mappings: RegionMapping[],
  codeNames: Map<string, string>,
): Promise<number> {
  const mappingByCode = new Map(
    mappings.map((mapping) => [`${mapping.regn_cd}:${mapping.signgu_cd}`, mapping]),
  );
  const rows: Record<string, unknown>[] = [];

  for (let page = 1; page <= 100; page += 1) {
    const response = await tourRequest(baseUrl, serviceKey, 'empmnInfoList', {
      pageNo: String(page),
      numOfRows: String(PAGE_SIZE),
    });
    const items = itemList(response);
    for (const item of items) {
      const regnCd = scalar(item, ['regnCd', 'areaCode']);
      const signguCd = scalar(item, ['signguCd', 'sigunguCode']);
      if (!regnCd || !signguCd) continue;
      const mapping = mappingByCode.get(`${regnCd}:${signguCd}`);
      if (!mapping) continue;
      const row = jobRow(item, mapping, codeNames);
      if (row) rows.push(row);
    }
    if (items.length < PAGE_SIZE) break;
  }

  if (rows.length === 0) return 0;
  const { error } = await supabase
    .from('tour_api_job_postings')
    .upsert(rows, { onConflict: 'empmn_info_no' });
  if (error) throw error;
  return rows.length;
}

async function syncSynchronizationList(
  supabase: ReturnType<typeof createClient>,
  baseUrl: string,
  serviceKey: string,
  mappings: RegionMapping[],
  codeNames: Map<string, string>,
): Promise<{ storedCount: number; hiddenCount: number }> {
  const mappingByCode = new Map(
    mappings.map((mapping) => [`${mapping.regn_cd}:${mapping.signgu_cd}`, mapping]),
  );
  const rows: Record<string, unknown>[] = [];
  let hiddenCount = 0;

  for (let page = 1; page <= 100; page += 1) {
    const response = await tourRequest(baseUrl, serviceKey, 'syncList', {
      numOfRows: String(PAGE_SIZE),
      pageNo: String(page),
    });
    const items = itemList(response);

    for (const item of items) {
      const showYn = (scalar(item, ['showYn', 'displayYn', 'useYn']) ?? 'Y')
          .toUpperCase();
      if (showYn === 'N' || showYn === '0' || showYn === 'FALSE') {
        hiddenCount += 1;
      }

      const regnCd = scalar(item, ['regnCd', 'areaCode']);
      const signguCd = scalar(item, ['signguCd', 'sigunguCode']);
      if (!regnCd || !signguCd) continue;

      const mapping = mappingByCode.get(`${regnCd}:${signguCd}`);
      if (!mapping) continue;

      const row = jobRow(item, mapping, codeNames);
      if (row) rows.push(row);
    }

    if (items.length < PAGE_SIZE) break;
  }

  if (rows.length > 0) {
    const { error } = await supabase
      .from('tour_api_job_postings')
      .upsert(rows, { onConflict: 'empmn_info_no' });
    if (error) throw error;
  }

  return { storedCount: rows.length, hiddenCount };
}

Deno.serve(async (request: Request) => {
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, content-type, x-sync-secret',
      },
    });
  }

  const expectedSecret = Deno.env.get('TOUR_API_SYNC_SECRET');
  if (!expectedSecret) {
    return jsonResponse(500, { error: 'TOUR_API_SYNC_SECRET is not configured' });
  }
  if (request.headers.get('x-sync-secret') !== expectedSecret) {
    return jsonResponse(401, { error: 'Invalid sync secret' });
  }

  try {
    const supabaseUrl = requiredEnv('SUPABASE_URL');
    const supabase = createClient(supabaseUrl, serviceRoleKey());
    const serviceKey = requiredEnv('TOUR_API_SERVICE_KEY');
    const baseUrl = Deno.env.get('TOUR_API_BASE_URL') ?? DEFAULT_API_BASE_URL;

    const mappingCount = await syncRegionMappings(supabase, baseUrl, serviceKey);
    const { data: mappings, error: mappingError } = await supabase
      .from('tour_api_region_mappings')
      .select('upper_region, lower_region, regn_cd, signgu_cd');
    if (mappingError) throw mappingError;

    const codeNames = await loadCodeNames(baseUrl, serviceKey);
    const syncedCount = await syncList(
      supabase,
      baseUrl,
      serviceKey,
      mappings ?? [],
      codeNames,
    );
    const synchronizationResult = await syncSynchronizationList(
      supabase,
      baseUrl,
      serviceKey,
      mappings ?? [],
      codeNames,
    );
    const { count: storedCount, error: countError } = await supabase
      .from('tour_api_job_postings')
      .select('empmn_info_no', { count: 'exact', head: true });
    if (countError) throw countError;

    return jsonResponse(200, {
      ok: true,
      mappingCount,
      visibleListCount: syncedCount,
      synchronizationListStoredCount: synchronizationResult.storedCount,
      syncedCount: storedCount ?? synchronizationResult.storedCount,
      hiddenCount: synchronizationResult.hiddenCount,
      syncedAt: new Date().toISOString(),
    });
  } catch (error) {
    console.error(error);
    return jsonResponse(500, {
      ok: false,
      error: error instanceof Error ? error.message : 'Tour API sync failed',
    });
  }
});
