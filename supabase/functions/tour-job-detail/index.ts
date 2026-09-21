import { createClient } from 'npm:@supabase/supabase-js@2.57.4';

const DEFAULT_API_BASE_URL = 'https://apis.data.go.kr/B551011/tursmService';

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
      // 아래에서 일관된 설정 오류로 반환합니다.
    }
  }
  throw new Error('Supabase service key is not configured');
}

async function requestDetail(
  baseUrl: string,
  serviceKey: string,
  empmnInfoNo: string,
): Promise<unknown> {
  const url = new URL(`${baseUrl.replace(/\/$/, '')}/empmnInfoDetail`);
  url.searchParams.set('serviceKey', normalizeServiceKey(serviceKey));
  url.searchParams.set('MobileOS', 'ETC');
  url.searchParams.set('MobileApp', 'Meomum');
  url.searchParams.set('_type', 'json');
  url.searchParams.set('empmnInfoNo', empmnInfoNo);

  const response = await fetch(url);
  if (!response.ok) throw new Error(`empmnInfoDetail request failed: ${response.status}`);
  return await response.json();
}

function firstItem(payload: unknown): Record<string, unknown> {
  if (!payload || typeof payload !== 'object') return {};
  const root = payload as Record<string, unknown>;
  const response = (root.response ?? root.body ?? root) as Record<string, unknown>;
  const body = (response.body ?? response) as Record<string, unknown>;
  const items = (body.items ?? body.item ?? body.data) as unknown;
  if (Array.isArray(items) && items[0] && typeof items[0] === 'object') {
    return items[0] as Record<string, unknown>;
  }
  if (items && typeof items === 'object') {
    const item = (items as Record<string, unknown>).item;
    if (Array.isArray(item) && item[0] && typeof item[0] === 'object') {
      return item[0] as Record<string, unknown>;
    }
    if (item && typeof item === 'object') return item as Record<string, unknown>;
    return items as Record<string, unknown>;
  }
  return {};
}

function jsonResponse(status: number, body: Record<string, unknown>): Response {
  return Response.json(body, {
    status,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'authorization, content-type',
      'Cache-Control': 'no-store',
    },
  });
}

Deno.serve(async (request: Request) => {
  if (request.method === 'OPTIONS') return new Response(null, { status: 204 });
  if (!request.headers.get('Authorization')) {
    return jsonResponse(401, { error: 'Missing Authorization header' });
  }

  try {
    const body = (await request.json()) as { empmnInfoNo?: unknown };
    const empmnInfoNo = String(body.empmnInfoNo ?? '').trim();
    if (!empmnInfoNo) return jsonResponse(400, { error: 'empmnInfoNo is required' });

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      serviceRoleKey(),
    );
    const { data: current, error: currentError } = await supabase
      .from('tour_api_job_postings')
      .select('empmn_info_no, detail_payload, detail_fetched_at')
      .eq('empmn_info_no', empmnInfoNo)
      .maybeSingle();
    if (currentError) throw currentError;
    if (!current) return jsonResponse(404, { error: 'Job posting not found' });

    const fetchedAt = current.detail_fetched_at
      ? new Date(current.detail_fetched_at).getTime()
      : 0;
    const isFresh =
      current.detail_payload &&
      Date.now() - fetchedAt < 24 * 60 * 60 * 1000;
    if (isFresh) return jsonResponse(200, { detail: current.detail_payload, cached: true });

    const payload = await requestDetail(
      Deno.env.get('TOUR_API_BASE_URL') ?? DEFAULT_API_BASE_URL,
      requiredEnv('TOUR_API_SERVICE_KEY'),
      empmnInfoNo,
    );
    const detail = firstItem(payload);
    const originalUrl = detail.tursmEmpmnInfoURL;
    const { error: updateError } = await supabase
      .from('tour_api_job_postings')
      .update({
        detail_payload: detail,
        detail_fetched_at: new Date().toISOString(),
        ...(typeof originalUrl === 'string' && originalUrl.trim()
          ? { original_url: originalUrl.trim() }
          : {}),
        updated_at: new Date().toISOString(),
      })
      .eq('empmn_info_no', empmnInfoNo);
    if (updateError) throw updateError;

    return jsonResponse(200, { detail, cached: false });
  } catch (error) {
    console.error(error);
    return jsonResponse(502, {
      error: error instanceof Error ? error.message : 'Tour API detail failed',
    });
  }
});
