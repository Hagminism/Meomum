# Auth0 연동 및 Supabase 마이그레이션 계획

* 상태: 제안안
* 작성일: 2026-08-25
* 대상: Flutter(Android/iOS), Riverpod, GoRouter, Supabase Database / Realtime / Storage

---

# 1. 배경

현재 앱은 **Supabase Auth + Supabase Database**를 사용하고 있다.

하지만 Google, Kakao, Naver에서 **동일한 이메일을 사용하더라도 서로 다른 계정으로 가입할 수 있어야 한다**는 커뮤니티 앱의 요구사항과 Supabase Auth의 자동 Identity Linking 방식이 맞지 않는다.

예를 들어:

```text
Google + A@naver.com → 계정 A
Kakao  + A@naver.com → 계정 B
Naver  + A@naver.com → 계정 C
```

를 원하는데, Supabase Auth에서는 동일 이메일을 가진 OAuth Identity가 하나의 사용자로 연결될 수 있다.

따라서 인증을 **Supabase Auth에서 Auth0로 분리**하는 방향을 검토한다.

---

# 2. 핵심 결론

이번 작업은 단순한 **"인증 SDK 교체"가 아니다.**

기존에는 Supabase Auth의 사용자 ID가 앱의 사용자 ID 역할까지 담당했다.

```text
기존

Supabase Auth
    ↓
auth.users.id
    ↓
profiles / posts / comments / likes
```

Auth0로 변경하면 인증과 앱의 사용자 ID를 분리한다.

```text
변경

Auth0
    ↓
JWT의 sub
    ↓
accounts
    ↓
accounts.id (UUID)
    ↓
profiles / posts / comments / likes
```

즉,

> **Auth0는 "누구인지 인증"하고, `accounts`는 "우리 서비스에서 누구인지" 관리한다.**

---

# 3. 목표 계정 구조

## 3.1 동일 이메일도 별도 계정

최종적으로 다음과 같이 동작해야 한다.

```text
Google
A@naver.com
    ↓
Auth0 User A
    ↓
accounts.id = UUID-A


Kakao
A@naver.com
    ↓
Auth0 User B
    ↓
accounts.id = UUID-B


Naver
A@naver.com
    ↓
Auth0 User C
    ↓
accounts.id = UUID-C
```

이메일이 같더라도 `accounts.id`가 다르기 때문에 앱에서는 완전히 다른 계정이다.

---

# 4. `accounts` 테이블

`accounts`는 Auth0와 앱의 데이터 사이를 연결하는 **내부 계정 테이블**이다.

단순히 "매퍼 테이블"이라고 보기보다는 **우리 서비스의 실제 계정(Account)을 표현하는 테이블**로 취급한다.

예시:

```sql
create table public.accounts (
  id uuid primary key default gen_random_uuid(),

  -- Auth0를 식별하는 정보
  auth_issuer text not null,
  auth_subject text not null,

  -- 참고용 메타데이터
  auth_connection text,
  email text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  unique (auth_issuer, auth_subject)
);
```

---

# 5. 각 컬럼의 역할

## `id`

우리 서비스가 사용하는 **내부 사용자 ID**다.

```text
UUID-A
UUID-B
UUID-C
```

게시글, 댓글, 좋아요 등의 FK는 모두 이 값을 사용한다.

---

## `auth_issuer`

Auth0의 발급자를 나타낸다.

예:

```text
https://my-tenant.auth0.com/
```

`auth_subject`와 함께 외부 Identity를 식별한다.

```text
(auth_issuer, auth_subject)
```

를 unique key로 사용한다.

---

## `auth_subject`

Auth0 JWT의 `sub` 값이다.

예:

```text
google-oauth2|123456
kakao|abcdef
naver|987654
```

**외부 인증 사용자를 식별하는 핵심 값이다.**

---

## `auth_connection`

Google, Kakao, Naver 등의 로그인 방식을 기록하는 **메타데이터**다.

예:

```text
google-oauth2
kakao
naver
```

단, 다음 용도로는 사용하지 않는다.

* PK
* FK
* 계정 식별
* RLS 보안 조건

계정 식별은 항상:

```text
auth_issuer + auth_subject
```

를 사용한다.

---

## `email`

사용자의 이메일을 저장할 수 있지만 **계정 식별자로 사용하지 않는다.**

따라서 unique 제약을 두지 않는다.

```text
A@naver.com
A@naver.com
A@naver.com
```

이 모두 존재할 수 있다.

이메일 변경이나 Auth0 정보 동기화에 사용할 수 있는 **보조 정보**로 취급한다.

---

# 6. 도메인 데이터는 `accounts.id`를 사용

기존에 Supabase Auth의 `auth.users.id`를 참조하던 데이터는 `accounts.id`를 참조하도록 변경한다.

예:

```text
accounts
    │
    ├── profiles.account_id
    ├── posts.author_id
    ├── comments.author_id
    ├── post_likes.account_id
    └── ...
```

예를 들어:

```text
accounts
──────────────────────
id
UUID-A
UUID-B
UUID-C
```

게시글:

```text
posts
──────────────────────
id     author_id
1      UUID-A
2      UUID-B
3      UUID-A
```

이렇게 하면 UUID-A 사용자가 작성한 게시글과 UUID-B 사용자의 게시글이 명확하게 분리된다.

---

# 7. `profiles`의 역할

`accounts`와 `profiles`는 서로 다른 역할을 가진다.

### accounts

**계정 자체**

```text
accounts
- id
- auth_issuer
- auth_subject
- auth_connection
- email
```

### profiles

**서비스에서 사용하는 프로필 정보**

```text
profiles
- account_id
- nickname
- bio
- avatar_url
...
```

따라서:

```text
Auth0
  ↓
accounts
  ↓
profiles
```

라는 관계가 된다.

---

# 8. Auth0 → Supabase 인증 흐름

이 부분이 이번 구조에서 가장 중요하다.

## 8.1 Google/Kakao/Naver → Auth0

사용자가 Google로 로그인한다고 가정한다.

```text
Flutter
  ↓
Auth0
  ↓
Google
  ↓
Google 인증 성공
  ↓
Auth0
```

Auth0는 Google에서 인증 결과를 받은 뒤 해당 사용자를 확인한다.

---

## 8.2 Auth0 → JWT 발급

Auth0는 인증된 사용자에게 JWT를 발급한다.

개념적으로:

```json
{
  "iss": "https://my-tenant.auth0.com/",
  "sub": "google-oauth2|123456",
  "role": "authenticated"
}
```

여기서 가장 중요한 값은:

```text
sub = google-oauth2|123456
```

이다.

이 값이 **Auth0에서 인증된 사용자를 식별하는 ID**다.

---

## 8.3 Flutter → Supabase

Flutter는 Auth0에서 받은 JWT를 가지고 Supabase에 요청한다.

개념적으로:

```http
Authorization: Bearer <JWT>
```

즉 Supabase에게:

> "Auth0가 인증한 사용자이고, 그 신분증이 이 JWT입니다."

라고 전달하는 것이다.

---

## 8.4 Supabase가 JWT 검증

Supabase는 Auth0의 공개키를 이용해 JWT의 서명을 검증한다.

```text
Auth0
 ├── Private Key
 │      ↓
 │    JWT 서명
 │
 └── Public Key
        ↓
     Supabase
```

Supabase는:

> "이 JWT가 정말 Auth0가 발급한 토큰인가?"

를 확인한다.

따라서 Supabase가 Google이나 Kakao에 다시 인증을 요청할 필요는 없다.

---

# 9. JWT와 `accounts` 연결

JWT가 검증되면 Supabase는 JWT의 `sub`를 확인한다.

```text
JWT

sub = google-oauth2|123456
```

그리고 `accounts`에서:

```text
auth_subject = google-oauth2|123456
```

를 찾는다.

결과:

```text
google-oauth2|123456
        ↓
accounts.id = UUID-A
```

가 된다.

즉 `accounts`는:

> Auth0의 사용자 ID와 우리 서비스의 사용자 ID를 연결하는 역할

을 한다.

---

# 10. RLS는 `accounts.id`를 기준으로 동작

예를 들어 현재 로그인한 사용자가:

```text
Auth0 sub
google-oauth2|123456
```

이고:

```text
accounts
auth_subject          id
────────────────────────────
google-oauth2|123456  UUID-A
kakao|456789          UUID-B
naver|987654          UUID-C
```

라면 현재 앱 사용자는:

```text
UUID-A
```

이다.

게시글:

```text
posts

id   author_id
──────────────
1    UUID-A
2    UUID-B
3    UUID-C
```

에서 RLS는 현재 사용자가 `UUID-A`임을 확인하고 권한을 판단한다.

```text
현재 사용자 = UUID-A
       ↓
posts.author_id = UUID-A
       ↓
접근 허용
```

따라서 사용자가 클라이언트에서 임의로:

```text
author_id = UUID-B
```

를 전달한다고 해서 B의 데이터에 접근할 수 있어서는 안 된다.

---

# 11. `ensure_account()` RPC

처음 로그인한 사용자는 아직 `accounts`에 존재하지 않을 수 있다.

따라서 인증 후 `ensure_account()`를 호출한다.

```text
Auth0 로그인
     ↓
JWT 발급
     ↓
Supabase
     ↓
ensure_account()
```

`ensure_account()`는 **클라이언트에서 `sub`를 전달받지 않는다.**

잘못된 방식:

```dart
ensureAccount(
  authSubject: "google-oauth2|123",
);
```

이렇게 하면 악의적인 클라이언트가 다른 사용자의 ID를 전달할 수 있다.

올바른 방식:

```text
Flutter
  ↓
ensure_account()
  ↓
Supabase가 JWT에서 직접
iss / sub 등을 읽음
```

---

# 12. `ensure_account()`의 역할

`ensure_account()`는 다음 작업을 수행한다.

1. JWT의 필요한 claim 확인
2. JWT의 `iss`, `sub` 확인
3. 기존 `accounts` 검색
4. 없으면 `accounts` 생성
5. `account_id` 반환

예:

```text
첫 로그인

Auth0 sub
google-oauth2|123
       ↓
ensure_account()
       ↓
accounts에 없음
       ↓
UUID-A 생성
       ↓
UUID-A 반환
```

다음 로그인:

```text
Auth0 sub
google-oauth2|123
       ↓
ensure_account()
       ↓
UUID-A 존재
       ↓
UUID-A 반환
```

---

# 13. `profiles` 생성

초기 가입 시 프로필이 반드시 필요한 경우:

```text
ensure_account()
      ↓
accounts 생성
      ↓
profiles 생성
      ↓
account_id 반환
```

으로 처리할 수 있다.

다만 향후 온보딩이나 추가 가입 정보가 필요해질 가능성이 있다면 `accounts` 생성과 `profiles` 생성의 책임을 분리하는 것도 고려한다.

현재 앱에서 가입 즉시 빈 프로필이 필요하다면 하나의 트랜잭션으로 처리한다.

---

# 14. Storage

Storage 역시 `accounts.id`를 기준으로 관리한다.

## 커뮤니티 이미지

공개 읽기가 필요한 경우:

```text
community-images/
  accounts/{account_id}/{object_id}.{extension}
```

public-read를 유지할 수 있다.

단:

* 다른 계정의 업로드 금지
* 다른 계정의 덮어쓰기 금지
* 다른 계정의 삭제 금지

는 RLS/Storage Policy로 보장한다.

---

## 인증 증빙 파일

개인정보가 포함될 수 있는 인증 증빙 파일은 별도의 private bucket을 사용한다.

```text
verification-documents/
  accounts/{account_id}/{object_id}.{extension}
```

이 bucket은 public-read를 허용하지 않는다.

---

# 15. 왜 Storage path에 Auth0 `sub`를 사용하지 않는가?

다음과 같이 만들 수도 있지만:

```text
❌ accounts/google-oauth2|123/profile.jpg
```

Auth0에 종속된다.

대신:

```text
⭕ accounts/550e8400-e29b-41d4-a716-446655440000/profile.jpg
```

처럼 내부 UUID를 사용한다.

그러면 나중에 Auth0를 다른 인증 서비스로 교체해도 Storage 구조를 변경할 필요가 없다.

---

# 16. Realtime

Realtime 역시 별도의 PoC가 필요하다.

특히 다음 기능을 실제 환경에서 확인한다.

* 게시글 실시간 변경
* 댓글 실시간 변경
* 좋아요 실시간 변경
* 인증된 사용자만 필요한 이벤트를 수신하는지
* Database RLS와 Realtime의 권한 동작이 예상과 일치하는지

Database API에서 정상적으로 동작한다고 해서 Realtime까지 자동으로 문제가 없다고 가정하지 않는다.

---

# 17. Flutter 아키텍처

현재 사용 중인 **Repository–DataSource 구조는 유지할 수 있다.**

단, Supabase Auth에 직접 의존하는 인증 구현은 변경한다.

기존:

```text
Supabase Auth
      ↓
AuthDataSource
      ↓
AuthRepository
      ↓
Riverpod
      ↓
GoRouter
```

변경:

```text
Auth0
      ↓
AuthDataSource
      ↓
AuthRepository
      ↓
Riverpod AuthState
      ↓
GoRouter
```

Auth0 SDK는 DataSource 내부에서만 사용하도록 한다.

Domain / Repository / Presentation 계층에서는 Auth0를 직접 참조하지 않는다.

---

# 18. 인증 상태 관리

Supabase의:

```dart
onAuthStateChange
```

Stream을 더 이상 사용할 필요는 없다.

Auth0의 Credentials Manager를 이용해 현재 인증 상태를 확인하고 Riverpod에서 관리한다.

```text
Auth0 Credentials Manager
          ↓
AuthDataSource
          ↓
AuthRepository
          ↓
Riverpod AuthState
          ↓
RouterRefreshNotifier
          ↓
GoRouter
```

인증 상태는 최소한 다음 세 가지를 고려한다.

```text
initializing
authenticated
unauthenticated
```

앱 시작 시 Auth0의 저장된 Credential을 확인하는 동안 `initializing` 상태를 사용하여 로그인 화면이 잠시 나타나는 문제를 방지한다.

---

# 19. GoRouter

현재 사용 중인 `refreshListenable` 구조는 그대로 유지할 수 있다.

기존:

```text
Supabase Auth Stream
       ↓
notifyListeners()
       ↓
GoRouter
```

변경:

```text
Riverpod AuthState 변경
       ↓
RouterRefreshNotifier
       ↓
notifyListeners()
       ↓
GoRouter redirect()
```

따라서 Auth0가 Stream 기반 인증 상태 API를 제공하지 않더라도 인증 상태에 따른 자동 리다이렉트는 구현할 수 있다.

---

# 20. 기존 DB 마이그레이션

## 운영 데이터가 없는 경우

아직 실제 사용자가 없다면 기존 인증 관련 스키마를 제거하고 새 모델로 구성하는 것이 가장 간단하다.

```text
기존
auth.users
profiles.user_id
posts.author_id
...

        ↓

변경
accounts.id
profiles.account_id
posts.author_id
...
```

---

## 운영 데이터가 있는 경우

운영 중인 데이터가 있다면 한 번에 삭제하지 않고:

```text
Expand
   ↓
Migrate
   ↓
Verify
   ↓
Contract
```

방식으로 진행한다.

### Expand

새로운 `accounts` 구조와 필요한 컬럼을 추가한다.

### Migrate

기존 사용자를 새로운 `accounts`와 연결한다.

### Verify

게시글, 댓글, 좋아요, 프로필, Storage 등의 관계가 정상인지 확인한다.

### Contract

기존 `auth.users` FK 및 불필요한 provider 기반 구조를 제거한다.

---

# 21. 반드시 통과해야 하는 PoC

실제 앱을 수정하기 전에 별도의 테스트 환경에서 검증한다.

## Phase 1 — Auth0 계정 분리

같은 이메일로:

```text
Google
Kakao
Naver
```

각각 가입한다.

기대 결과:

```text
Google → Auth0 User A
Kakao  → Auth0 User B
Naver  → Auth0 User C
```

세 개의 서로 다른 `sub`가 생성되어야 한다.

---

## Phase 2 — Auth0 → Supabase

Auth0에서 발급된 JWT를 사용해:

* Database SELECT
* INSERT
* UPDATE
* DELETE

를 테스트한다.

그리고 Supabase가 JWT의:

```text
iss
sub
role
```

등 필요한 claim을 정상적으로 인식하는지 확인한다.

> 실제 구현에서 ID Token / Access Token 중 어떤 토큰을 Supabase에 전달할지는 현재 Supabase의 Auth0 Third-Party Auth 연동 방식에 맞춰 확정한다. 문서의 개념을 그대로 가정하지 않고 실제 PoC로 검증한다.

---

## Phase 3 — RLS

계정 A와 계정 B를 만든다.

```text
Account A
UUID-A

Account B
UUID-B
```

A가 B의 데이터를:

* 조회
* 수정
* 삭제

할 수 없는지 확인한다.

특히 클라이언트가 임의의 `account_id`를 전달해도 권한을 얻을 수 없어야 한다.

---

## Phase 4 — Realtime

다음 기능을 테스트한다.

* 게시글 변경
* 댓글 변경
* 좋아요 변경
* 인증된 사용자 이벤트
* RLS와 Realtime 권한 관계

---

## Phase 5 — Storage

A가:

```text
accounts/UUID-A/...
```

를 사용할 수 있는지 확인한다.

그리고 A가:

```text
accounts/UUID-B/...
```

에 대해:

* 업로드
* 덮어쓰기
* 삭제

할 수 없는지 확인한다.

Private bucket인 `verification-documents`도 동일하게 테스트한다.

---

## Phase 6 — Flutter

마지막으로 실제 Flutter 앱에서:

* 로그인
* 자동 로그인
* 로그아웃
* 앱 재시작
* 토큰 만료
* 토큰 갱신
* Android process death
* GoRouter redirect

를 테스트한다.

---

# 22. 최종 구조

```text
                         ┌─────────┐
                         │ Google  │
                         │ Kakao   │
                         │ Naver   │
                         └────┬────┘
                              ↓
                         ┌─────────┐
                         │  Auth0  │
                         └────┬────┘
                              │
                         JWT (iss, sub)
                              ↓
                         ┌─────────┐
                         │ Flutter │
                         └────┬────┘
                              │
                         JWT 포함 요청
                              ↓
                    ┌──────────────────┐
                    │    Supabase      │
                    │                  │
                    │ ensure_account() │
                    │        ↓         │
                    │     accounts     │
                    └────────┬─────────┘
                             │
                      accounts.id
                             │
          ┌──────────────────┼──────────────────┐
          ↓                  ↓                  ↓
      profiles             posts             likes
          │                  │                  │
          └──────────────────┼──────────────────┘
                             ↓
                            RLS
                             │
                    ┌────────┴────────┐
                    ↓                 ↓
                 Storage           Realtime
```

---

# 23. 핵심 원칙 요약

이번 마이그레이션에서는 다음 원칙을 유지한다.

1. **Auth0는 인증만 담당한다.**
2. **Supabase Auth는 사용하지 않는다.**
3. **`accounts.id`를 우리 서비스의 영속적인 사용자 ID로 사용한다.**
4. **Auth0 JWT의 `iss + sub`를 외부 Identity 식별자로 사용한다.**
5. **이메일은 절대로 계정 식별자로 사용하지 않는다.**
6. **provider/connection은 메타데이터일 뿐 보안 경계가 아니다.**
7. **모든 도메인 데이터는 `accounts.id`를 FK로 사용한다.**
8. **클라이언트가 `sub`나 `account_id`를 임의로 지정해 권한을 얻지 못하도록 한다.**
9. **RLS는 JWT에서 인증된 사용자를 확인하고 내부 `accounts.id`와 연결하여 권한을 판단한다.**
10. **Storage도 내부 UUID를 기준으로 소유권을 판단한다.**
11. **Auth0와 Supabase의 실제 JWT 연동은 PoC를 통해 검증한 뒤 확정한다.**
12. **Auth0를 나중에 교체하더라도 애플리케이션의 사용자 ID와 도메인 데이터는 유지할 수 있도록 설계한다.**

---

# 24. 최종 목표

최종적으로 원하는 구조는 단순하다.

```text
"누구인가?"
      ↓
    Auth0

"우리 서비스에서 누구인가?"
      ↓
   accounts.id

"무엇을 소유하는가?"
      ↓
profiles / posts / comments / likes / Storage

"접근해도 되는가?"
      ↓
      RLS
```

이렇게 **인증(Authentication)** 과 **애플리케이션 계정/인가(Authorization)** 를 분리하는 것이 이번 마이그레이션의 핵심이다.

실제 구현은 **Phase 1 → Phase 2 PoC가 모두 성공한 이후** 진행한다.
