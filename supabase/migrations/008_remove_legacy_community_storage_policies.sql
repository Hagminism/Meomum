-- 007 replaced the community-image policy set, but these legacy policy names
-- include a trailing period and therefore were not matched by its DROP POLICY
-- statements. Policies combine with OR semantics, so the old upload policy
-- would otherwise allow any authenticated user to upload at an arbitrary path.
DROP POLICY IF EXISTS "Community images are publicly accessible." ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload community images." ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own community images." ON storage.objects;
