import { createClient } from 'npm:@supabase/supabase-js@2.57.4';

const BATCH_SIZE = 25;

type CleanupItem = {
  id: string;
  auth_issuer: string;
  auth_subject: string;
};

type Auth0DeletionResult = {
  completed: boolean;
  message?: string;
};

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

function normalizedDomain(value: string): string {
  return value
    .replace(/^https?:\/\//, '')
    .replace(/\/+$/, '');
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
): Promise<{ token: string | null; message: string }> {
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

    if (!tokenResponse.ok) {
      return {
        token: null,
        message: `Auth0 Management API token request failed with status ${tokenResponse.status}`,
      };
    }

    const tokenBody = (await tokenResponse.json()) as {
      access_token?: unknown;
    };
    if (typeof tokenBody.access_token !== 'string') {
      return {
        token: null,
        message: 'Auth0 Management API token was not returned',
      };
    }

    return { token: tokenBody.access_token, message: '' };
  } catch (_) {
    return {
      token: null,
      message: 'Auth0 Management API token request failed',
    };
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

async function completeItem(
  supabaseAdmin: ReturnType<typeof createClient>,
  itemId: string,
): Promise<boolean> {
  const { error } = await supabaseAdmin.rpc(
    'complete_auth0_user_deletion_items',
    { p_ids: [itemId] },
  );
  return !error;
}

async function failItem(
  supabaseAdmin: ReturnType<typeof createClient>,
  itemId: string,
  message: string,
): Promise<boolean> {
  const { error } = await supabaseAdmin.rpc(
    'fail_auth0_user_deletion_items',
    { p_ids: [itemId], p_message: message },
  );
  return !error;
}

Deno.serve(async (request: Request) => {
  if (request.method !== 'POST') {
    return response(405, { error: 'Method not allowed' });
  }

  const expectedSecret = Deno.env.get('AUTH0_CLEANUP_CRON_SECRET');
  const receivedSecret = request.headers.get('x-auth0-cleanup-secret');
  if (!expectedSecret || receivedSecret !== expectedSecret) {
    return response(401, { error: 'Unauthorized' });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceKey = getServiceKey();
  const auth0Domain = Deno.env.get('AUTH0_DOMAIN');
  const auth0ClientId = Deno.env.get('AUTH0_M2M_CLIENT_ID');
  const auth0ClientSecret = Deno.env.get('AUTH0_M2M_CLIENT_SECRET');
  const auth0Audience =
    Deno.env.get('AUTH0_MANAGEMENT_API_AUDIENCE') ??
    `https://${normalizedDomain(auth0Domain ?? '')}/api/v2/`;

  if (
    !supabaseUrl ||
    !serviceKey ||
    !auth0Domain ||
    !auth0ClientId ||
    !auth0ClientSecret
  ) {
    return response(500, { error: 'Auth0 cleanup service is not configured' });
  }

  const supabaseAdmin = createClient(supabaseUrl, serviceKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });

  const { data, error: claimError } = await supabaseAdmin.rpc(
    'claim_auth0_user_deletion_items',
    { p_limit: BATCH_SIZE },
  );

  if (claimError) {
    return response(500, {
      error: 'Failed to claim Auth0 cleanup items',
    });
  }

  const items = (data ?? []) as CleanupItem[];
  if (items.length === 0) {
    return response(200, { processed: 0, failed: 0, claimed: 0 });
  }

  const expectedIssuer = `https://${normalizedDomain(auth0Domain)}/`;

  const tokenResult = await requestManagementToken(
    auth0Domain,
    auth0ClientId,
    auth0ClientSecret,
    auth0Audience,
  );
  if (!tokenResult.token) {
    for (const item of items) {
      await failItem(supabaseAdmin, item.id, tokenResult.message);
    }
    return response(500, {
      processed: 0,
      failed: items.length,
      claimed: items.length,
    });
  }

  let processed = 0;
  let failed = 0;

  for (const item of items) {
    if (item.auth_issuer !== expectedIssuer) {
      await failItem(
        supabaseAdmin,
        item.id,
        'Auth0 issuer does not match the configured tenant',
      );
      failed += 1;
      continue;
    }

    const deletionResult = await deleteAuth0User(
      auth0Domain,
      tokenResult.token,
      item.auth_subject,
    );

    if (deletionResult.completed) {
      if (await completeItem(supabaseAdmin, item.id)) {
        processed += 1;
      } else {
        await failItem(
          supabaseAdmin,
          item.id,
          'Failed to record Auth0 cleanup completion',
        );
        failed += 1;
      }
      continue;
    }

    await failItem(
      supabaseAdmin,
      item.id,
      deletionResult.message ?? 'Auth0 user deletion failed',
    );
    failed += 1;
  }

  return response(200, {
    processed,
    failed,
    claimed: items.length,
  });
});
