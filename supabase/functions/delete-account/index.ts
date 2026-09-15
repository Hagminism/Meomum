import { createClient } from 'npm:@supabase/supabase-js@2.57.4';

type JwtPayload = {
  iss?: unknown;
  sub?: unknown;
  aud?: unknown;
  exp?: unknown;
};

type Auth0DeletionResult = {
  completed: boolean;
  message?: string;
};

function getBearerToken(request: Request): string | null {
  const authorization = request.headers.get('Authorization');
  if (!authorization?.startsWith('Bearer ')) return null;

  const token = authorization.slice('Bearer '.length).trim();
  return token || null;
}

function decodeJwtPayload(token: string): JwtPayload | null {
  const encodedPayload = token.split('.')[1];
  if (!encodedPayload) return null;

  try {
    const normalizedPayload = encodedPayload
      .replaceAll('-', '+')
      .replaceAll('_', '/');
    const padding = normalizedPayload.length % 4;
    const paddedPayload = normalizedPayload + (padding ? '='.repeat(4 - padding) : '');
    const binaryPayload = atob(paddedPayload);
    const payloadBytes = Uint8Array.from(
      binaryPayload,
      (character) => character.charCodeAt(0),
    );
    const payload = JSON.parse(
      new TextDecoder().decode(payloadBytes),
    ) as unknown;

    return payload && typeof payload === 'object'
      ? (payload as JwtPayload)
      : null;
  } catch (_) {
    return null;
  }
}

function normalizedDomain(value: string): string {
  return value
    .replace(/^https?:\/\//, '')
    .replace(/\/+$/, '');
}

function hasAudience(audience: unknown, expectedAudience: string): boolean {
  if (typeof audience === 'string') return audience === expectedAudience;
  if (Array.isArray(audience)) {
    return audience.some((value) => value === expectedAudience);
  }
  return false;
}

function validateJwt(token: string): JwtPayload | null {
  const payload = decodeJwtPayload(token);
  const auth0Domain = Deno.env.get('AUTH0_DOMAIN');
  const auth0ClientId = Deno.env.get('AUTH0_CLIENT_ID');

  if (!payload || !auth0Domain || !auth0ClientId) return null;

  const expectedIssuer = `https://${normalizedDomain(auth0Domain)}/`;
  const isValidExpiration =
    typeof payload.exp === 'number' && payload.exp > Date.now() / 1000;

  if (
    payload.iss !== expectedIssuer ||
    typeof payload.sub !== 'string' ||
    payload.sub.length === 0 ||
    !hasAudience(payload.aud, auth0ClientId) ||
    !isValidExpiration
  ) {
    return null;
  }

  return payload;
}

function getServiceKey(): string | null {
  const directKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (directKey) return directKey;

  const secretKeys = Deno.env.get('SUPABASE_SECRET_KEYS');
  if (!secretKeys) return null;

  try {
    const parsedKeys = JSON.parse(secretKeys) as Record<string, string>;
    return parsedKeys.default ?? null;
  } catch (_) {
    return null;
  }
}

function response(status: number, body: Record<string, unknown>): Response {
  return Response.json(body, {
    status,
    headers: { 'Cache-Control': 'no-store' },
  });
}

async function requestManagementToken(
  domain: string,
  clientId: string,
  clientSecret: string,
  audience: string,
): Promise<string | null> {
  try {
    const tokenResponse = await fetch(
      `https://${normalizedDomain(domain)}/oauth/token`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          grant_type: 'client_credentials',
          client_id: clientId,
          client_secret: clientSecret,
          audience,
        }),
      },
    );

    if (!tokenResponse.ok) return null;

    const tokenBody = (await tokenResponse.json()) as {
      access_token?: unknown;
    };
    return typeof tokenBody.access_token === 'string'
      ? tokenBody.access_token
      : null;
  } catch (_) {
    return null;
  }
}

async function deleteAuth0User(
  domain: string,
  managementToken: string,
  userId: string,
): Promise<Auth0DeletionResult> {
  try {
    const deleteResponse = await fetch(
      `https://${normalizedDomain(domain)}/api/v2/users/${encodeURIComponent(userId)}`,
      {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${managementToken}` },
      },
    );

    if (deleteResponse.status === 204 || deleteResponse.status === 404) {
      return { completed: true };
    }

    return {
      completed: false,
      message: `Auth0 user deletion failed with status ${deleteResponse.status}`,
    };
  } catch (_) {
    return {
      completed: false,
      message: 'Auth0 user deletion request failed',
    };
  }
}

async function updateQueue(
  supabaseAdmin: ReturnType<typeof createClient>,
  issuer: string,
  subject: string,
  completed: boolean,
  message?: string,
): Promise<boolean> {
  const { data: queueItem, error: findError } = await supabaseAdmin
    .from('auth0_user_deletion_queue')
    .select('id')
    .eq('auth_issuer', issuer)
    .eq('auth_subject', subject)
    .maybeSingle();

  if (findError || !queueItem) return false;

  const rpcName = completed
    ? 'complete_auth0_user_deletion_items'
    : 'fail_auth0_user_deletion_items';
  const params = completed
    ? { p_ids: [queueItem.id] }
    : { p_ids: [queueItem.id], p_message: message ?? 'Unknown error' };
  const { error } = await supabaseAdmin.rpc(rpcName, params);
  return !error;
}

Deno.serve(async (request: Request) => {
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: { 'Cache-Control': 'no-store' },
    });
  }

  if (request.method !== 'POST') {
    return response(405, { error: 'Method not allowed' });
  }

  const token = getBearerToken(request);
  const payload = token ? validateJwt(token) : null;
  if (!token || !payload) {
    return response(401, { error: 'Unauthorized' });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const supabasePublicKey =
    Deno.env.get('SUPABASE_ANON_KEY') ??
    Deno.env.get('SUPABASE_PUBLISHABLE_KEY');
  if (!supabaseUrl || !supabasePublicKey) {
    return response(500, { error: 'Account deletion is not configured' });
  }

  const supabaseUser = createClient(supabaseUrl, supabasePublicKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
    global: {
      headers: { Authorization: `Bearer ${token}` },
    },
  });

  const { error: deleteError } = await supabaseUser.rpc('delete_account');
  if (deleteError) {
    return response(500, { error: 'Account deletion failed' });
  }

  const auth0Domain = Deno.env.get('AUTH0_DOMAIN');
  const auth0ClientId = Deno.env.get('AUTH0_M2M_CLIENT_ID');
  const auth0ClientSecret = Deno.env.get('AUTH0_M2M_CLIENT_SECRET');
  const auth0Audience =
    Deno.env.get('AUTH0_MANAGEMENT_API_AUDIENCE') ??
    `https://${normalizedDomain(auth0Domain ?? '')}/api/v2/`;
  const managementToken =
    auth0Domain && auth0ClientId && auth0ClientSecret
      ? await requestManagementToken(
          auth0Domain,
          auth0ClientId,
          auth0ClientSecret,
          auth0Audience,
        )
      : null;
  const serviceKey = getServiceKey();
  const supabaseAdmin = serviceKey
    ? createClient(supabaseUrl, serviceKey, {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      })
    : null;

  if (managementToken && auth0Domain) {
    const deletionResult = await deleteAuth0User(
      auth0Domain,
      managementToken,
      payload.sub as string,
    );
    if (supabaseAdmin) {
      await updateQueue(
        supabaseAdmin,
        payload.iss as string,
        payload.sub as string,
        deletionResult.completed,
        deletionResult.message,
      );
    }

    return response(deletionResult.completed ? 200 : 202, {
      accepted: true,
      auth0_cleanup: deletionResult.completed ? 'completed' : 'queued',
    });
  }

  if (supabaseAdmin) {
    await updateQueue(
      supabaseAdmin,
      payload.iss as string,
      payload.sub as string,
      false,
      'Auth0 Management API is not configured or unavailable',
    );
  }

  return response(202, {
    accepted: true,
    auth0_cleanup: 'queued',
  });
});
