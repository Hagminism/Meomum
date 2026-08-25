나는 **상당히 좋은 검토 결과라고 봐.** 특히 이번 피드백에서 중요한 건 "Auth0로 바꾸자"가 아니라, **Auth0 전환을 인증 SDK 교체가 아닌 데이터 모델/보안 경계의 변경으로 정확히 정의했다는 점**이야.

다만 나는 몇 군데는 **그대로 받아들이기보다 수정해서 진행**할 것 같아.

### 1. 가장 중요한 지적: `accounts` 매핑 계층을 두는 게 맞음

이 부분은 나도 강하게 동의해.

```text
Auth0 sub
   ↓
accounts.id (UUID)
   ↓
profiles
posts
comments
likes
...
```

이렇게 가는 게 훨씬 좋아.

특히 `Auth0 sub`를 `posts.author_id` 같은 곳에 직접 박아버리면 나중에 Auth0를 바꾸는 순간 DB 전체가 흔들려.

반면:

```text
accounts
────────────────────
id                  UUID
auth_subject        TEXT UNIQUE
```

로 추상화하면:

```text
Auth0
google-oauth2|123
       ↓
accounts
UUID = AAAAAAAA
       ↓
posts.author_id
```

가 되고, 나중에 Logto로 바꾸더라도 `auth_subject` 매핑만 바꾸면 돼.

**이건 지금 설계 단계에서 반드시 넣는 걸 추천해.**

---

### 2. RLS 부분은 "Auth0 JWT를 Supabase가 어떻게 인식하느냐"를 먼저 확정해야 함

여기서 피드백의 방향은 맞는데, 약간 더 정확하게 봐야 해.

Supabase Auth를 제거하면 기존:

```sql
auth.uid()
```

중심의 RLS가 그대로 유지되는 게 아니야.

따라서 최종적으로는:

```text
Auth0 JWT
   ↓
Supabase
   ↓
JWT의 sub
   ↓
accounts.auth_subject
   ↓
accounts.id
   ↓
RLS
```

라는 경로를 확립해야 해.

그리고 **이걸 실제 PoC에서 먼저 성공시키는 게 중요해.**

특히 `Storage`까지 포함해서.

Database는 잘 되는데 Storage RLS에서 막히는 경우가 생기면 인증 전환이 생각보다 귀찮아질 수 있어.

---

### 3. `profiles(user_id, provider)`는 이제 과감히 버리는 게 맞음

현재 구조에서:

```text
user_id + provider
```

를 계정 식별자로 사용했던 건 **Supabase Auth가 계정을 합쳐버리기 때문**이었잖아.

Auth0로 넘어가면:

```text
Google → Auth0 User A
Kakao  → Auth0 User B
Naver  → Auth0 User C
```

가 되니까 더 이상 provider를 profile의 PK 구성 요소로 사용할 이유가 없어.

나는 최종적으로:

```text
accounts
  id UUID PK
  auth_subject TEXT UNIQUE

profiles
  user_id UUID PK/FK → accounts.id
  nickname
  ...

posts
  author_id UUID FK → accounts.id

comments
  author_id UUID FK → accounts.id

likes
  user_id UUID FK → accounts.id
```

이렇게 만들겠어.

**"계정"이라는 개념을 DB에서 명시적으로 하나 만드는 것**이 이번 전환에서 가장 중요한 설계 변화라고 봐.

---

### 4. 한 가지는 문서에서 표현을 조금 수정하는 게 좋음

현재 문서의:

> 현재 Repository–DataSource 구조는 그대로 유지한다.

이건 피드백에서 지적한 것처럼 약간 과해.

나는:

> **Repository–DataSource 아키텍처는 유지하되, Auth 관련 DataSource와 인증 상태 모델은 변경한다.**

라고 쓰는 게 정확하다고 봐.

실제로:

```text
AuthDataSource
 ├── Supabase.currentUser()
 ├── Supabase.currentSession()
 └── onAuthStateChange()
```

에서

```text
AuthDataSource
 ├── Auth0 credentials
 ├── Auth0 user profile
 └── Auth0 session
```

으로 상당히 많이 바뀌니까.

반면 `AuthRepository → Riverpod → GoRouter`라는 **상위 구조는 그대로 유지**할 수 있어.

---

### 5. `onAuthStateChange`가 없어진 건 큰 문제가 아님

이건 우리가 앞에서 이야기했던 부분인데, 네 Repository–DataSource + Riverpod 구조에서는 오히려 깔끔해.

```text
Auth0 CredentialsManager
        ↓
AuthDataSource
        ↓
AuthRepository
        ↓
AuthStateProvider
        ↓
RouterRefreshNotifier
        ↓
GoRouter
```

이렇게 만들면 돼.

그러니까 **Supabase의 Stream을 대체하는 것이지, 인증 상태 관리 자체를 없애는 게 아니야.**

그리고 `initializing` 상태를 추가하자는 의견도 좋음.

```text
initializing
authenticated
unauthenticated
```

이렇게 해두면 앱 시작 시 Auth0 credential 확인하는 동안 Login 화면이 잠깐 나타나는 문제도 피할 수 있어.

---

# 내가 생각하는 진짜 PoC 순서

여기서 중요한 건 **바로 마이그레이션하지 않는 것**이야.

나는 아래 순서로 테스트할 것 같아.

### Phase 1 — Auth0 자체 검증

```text
Google
Kakao
Naver
```

각각 같은 이메일로 가입.

결과:

```text
Auth0
├── google|xxx
├── kakao|xxx
└── naver|xxx
```

**3개의 독립 User ID가 나오는지 확인.**

이게 첫 번째 관문.

---

### Phase 2 — Supabase 인증 연동

```text
Auth0
  ↓
ID Token
  ↓
Supabase
```

그리고:

```text
SELECT ...
INSERT ...
UPDATE ...
DELETE ...
```

가 정상적으로 RLS를 통과하는지 확인.

---

### Phase 3 — 계정 매핑

```text
Auth0 sub
    ↓
accounts.auth_subject
    ↓
accounts.id
```

그리고 기존:

```text
profiles
posts
comments
likes
...
```

가 전부 `accounts.id`를 FK로 바라보도록 테스트.

---

### Phase 4 — Storage

이걸 **반드시 별도로 테스트**할 것 같아.

예:

```text
accounts/A/profile.png
accounts/B/profile.png
```

A가 B의 파일을 읽거나 삭제할 수 없는지 확인.

커뮤니티 앱에서는 이미지 업로드가 들어갈 가능성이 높으니까 이 부분이 꽤 중요해.

---

### Phase 5 — Flutter

그 다음에야 기존 앱 구조에 붙이는 거야.

```text
Auth0DataSource
       ↓
AuthRepository
       ↓
Riverpod
       ↓
GoRouter
```

그리고 앱 재시작 / 로그아웃 / 토큰 만료 / refresh / Android process death까지 테스트.

---

## 그래서 내 최종 의견

**방향은 맞아. 그리고 지금까지의 논의보다 훨씬 설계가 제대로 잡힌 상태야.**

특히 나는 이 부분을 핵심 결정으로 잡을 거야:

> **Auth0는 인증 시스템이고, Supabase의 `accounts`는 애플리케이션 내부의 사용자 식별 계층이다.**

즉:

```text
          Auth0
           │
        auth_subject
           │
           ▼
       accounts.id
           │
     ┌─────┼─────┐
     ↓     ↓     ↓
 profiles posts likes ...
```

이렇게 **Auth0와 애플리케이션의 사용자 ID를 분리**하면 이번 문제뿐 아니라 향후 인증 공급자를 변경할 때도 훨씬 안전해.

그리고 지금 단계에서는 **Auth0 전환 작업을 시작하기보다 위의 Phase 1~2 정도를 작은 테스트 프로젝트에서 먼저 검증하는 게 가장 현명해 보여.**

특히 **"동일 이메일 3개 provider → 3개 Auth0 user → 그 JWT로 Supabase RLS 접근"** 이 두 가지가 성공하면, 그때 실제 앱 마이그레이션을 진행하면 돼.
