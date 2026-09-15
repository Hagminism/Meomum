import { createClient } from 'npm:@supabase/supabase-js@2.57.4';

const BATCH_SIZE = 50;

type CleanupItem = {
  id: string;
  bucket_id: string;
  storage_path: string;
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

Deno.serve(async (request: Request) => {
  if (request.method !== 'POST') {
    return Response.json(
      { error: 'Method not allowed' },
      { status: 405 },
    );
  }

  const expectedSecret = Deno.env.get('STORAGE_CLEANUP_CRON_SECRET');
  const receivedSecret = request.headers.get('x-storage-cleanup-secret');
  if (!expectedSecret || receivedSecret !== expectedSecret) {
    return Response.json(
      { error: 'Unauthorized' },
      { status: 401 },
    );
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceKey = getServiceKey();
  if (!supabaseUrl || !serviceKey) {
    return Response.json(
      { error: 'Storage cleanup service is not configured' },
      { status: 500 },
    );
  }

  const supabaseAdmin = createClient(supabaseUrl, serviceKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });

  const { data, error: claimError } = await supabaseAdmin.rpc(
    'claim_storage_cleanup_items',
    { p_limit: BATCH_SIZE },
  );

  if (claimError) {
    return Response.json(
      { error: `Failed to claim cleanup items: ${claimError.message}` },
      { status: 500 },
    );
  }

  const items = (data ?? []) as CleanupItem[];
  if (items.length === 0) {
    return Response.json({ processed: 0, failed: 0 });
  }

  const groupedItems = new Map<string, CleanupItem[]>();
  for (const item of items) {
    const bucketItems = groupedItems.get(item.bucket_id) ?? [];
    bucketItems.push(item);
    groupedItems.set(item.bucket_id, bucketItems);
  }

  let processed = 0;
  let failed = 0;

  for (const [bucketId, bucketItems] of groupedItems) {
    const ids = bucketItems.map((item) => item.id);
    const storagePaths = bucketItems.map((item) => item.storage_path);
    const { error: removeError } = await supabaseAdmin.storage
      .from(bucketId)
      .remove(storagePaths);

    if (removeError) {
      failed += ids.length;
      await supabaseAdmin.rpc('fail_storage_cleanup_items', {
        p_ids: ids,
        p_message: removeError.message,
      });
      continue;
    }

    const { error: completeError } = await supabaseAdmin.rpc(
      'complete_storage_cleanup_items',
      { p_ids: ids },
    );

    if (completeError) {
      failed += ids.length;
      await supabaseAdmin.rpc('fail_storage_cleanup_items', {
        p_ids: ids,
        p_message: completeError.message,
      });
      continue;
    }

    processed += ids.length;
  }

  return Response.json({
    processed,
    failed,
    claimed: items.length,
  });
});
