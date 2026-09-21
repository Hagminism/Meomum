# 일자리 API 운영 설정

## Edge Function Secret

`tour-job-sync`, `tour-job-detail`에 아래 Secret을 설정합니다.

- `TOUR_API_SERVICE_KEY`: 한국관광공사 관광인 채용정보 API 인증키
- `TOUR_API_SYNC_SECRET`: 동기화 함수 호출용 별도 Secret
- `TOUR_API_BASE_URL`: 선택값. 기본값은 `https://apis.data.go.kr/B551011/tursmService`

Supabase가 제공하는 `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` 또는 `SUPABASE_SECRET_KEYS`는 함수가 캐시 테이블을 갱신하는 데 사용합니다. 서비스 키와 관광 API 키는 Flutter 앱의 `.env`나 저장소에 넣지 않습니다.

## 일일 동기화 Cron

동기화 함수는 한국 시간 오전 3시에 실행하도록 Supabase Cron에 등록합니다. 아래 SQL의 프로젝트 URL과 Secret 값은 Vault에 먼저 저장하고, 실제 값은 저장소에 커밋하지 않습니다.

```sql
select vault.create_secret('https://<project-ref>.supabase.co', 'meomum_project_url');
select vault.create_secret('<publishable-or-anon-key>', 'meomum_publishable_key');
select vault.create_secret('<tour-job-sync-secret>', 'tour_job_sync_secret');

select cron.schedule(
  'tour-job-sync-daily',
  '0 18 * * *',
  $$
  select net.http_post(
    url := (
      select decrypted_secret
      from vault.decrypted_secrets
      where name = 'meomum_project_url'
    ) || '/functions/v1/tour-job-sync',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (
        select decrypted_secret
        from vault.decrypted_secrets
        where name = 'meomum_publishable_key'
      ),
      'x-sync-secret', (
        select decrypted_secret
        from vault.decrypted_secrets
        where name = 'tour_job_sync_secret'
      )
    ),
    body := '{}'::jsonb
  );
  $$
);
```

`0 18 * * *`는 UTC 기준으로 한국 시간 03:00입니다. 최초 배포 후 `cron.job_run_details`에서 실행 결과를 확인하고, `tour_api_region_mappings`에 현재 앱 지역과 관광인 코드가 생성되는지 확인합니다.
