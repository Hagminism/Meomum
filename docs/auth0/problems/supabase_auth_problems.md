# 커뮤니티 앱 인증 구조 검토 (Supabase Auth → Auth0)

## 배경

현재 앱은 Flutter + Riverpod + GoRouter + Supabase(Database) 기반의 커뮤니티 서비스이며, 소셜 로그인은 다음 3가지를 지원한다.

* Google
* Kakao
* Naver

초기에는 구현 편의성과 Supabase DB와의 높은 통합성을 이유로 **Supabase Auth**를 사용하려고 했지만, 커뮤니티 서비스의 계정 정책과 충돌하는 문제가 발견되었다.

---

# 문제 상황

## 원하는 계정 정책

커뮤니티 앱에서는 **로그인 수단 자체가 하나의 계정**이 되는 경우가 많다.

예를 들어 동일한 이메일을 사용하더라도 다음은 서로 다른 계정이어야 한다.

| 로그인 방식 | 이메일                                | 기대 결과 |
| ------ | ---------------------------------- | ----- |
| Google | [A@naver.com](mailto:A@naver.com)  |  계정 A |
| Kakao  | [A@naver.com](mailto:A@naver.com)  |  계정 B |
| Naver  | [A@naver.com](mailto:A@naver.com)  |  계정 C |

각 계정은 데이터를 완전히 독립적으로 가져야 한다.

즉 **이메일이 아니라 로그인 Identity가 계정의 기준**이다.

---

## Supabase Auth의 문제

Supabase Auth는 OAuth 로그인 시 **동일 이메일을 가진 Identity를 자동으로 하나의 사용자로 연결(Automatic Identity Linking)** 한다.

결과적으로 다음과 같이 된다.

```text
Google (A@naver.com)
        │
Kakao (A@naver.com)
        │
Naver (A@naver.com)
        ▼
 하나의 auth.users
```

이 구조에서는 Google로 가입한 사용자가 Kakao로 로그인해도 **새 계정이 아니라 기존 계정으로 로그인**된다.

커뮤니티 서비스에서는 의도하지 않은 UX가 된다.

---

# 검토했던 해결 방법

## 1. profiles 테이블을 provider별로 분리

```
(user_id, provider)를 복합 PK로 하는 profiles 테이블을 별도 운영
```

### 장점

* Google / Kakao / Naver마다 서로 다른 프로필 생성 가능
* 게시글도 provider 기준으로 분리 가능

### 한계

인증 계정은 여전히 하나다.

```text
auth.users
    │
    ├── Google Profile
    ├── Kakao Profile
    └── Naver Profile
```

즉 **프로필 분리**일 뿐, **계정 분리**는 아니다.

`auth.uid()`는 항상 동일하기 때문에 RLS 설계도 복잡해진다.

> 결론: 커뮤니티 계정 모델에는 적합하지 않음.

---

## 2. Supabase Auth Hook 활용

Hook를 이용해 계정 생성 전에 이메일을 변경하거나 정책을 수정하는 방법도 검토했다.

### 가능한 것

* 가입 허용/거부
* JWT Claim 추가
* 인증 정책 커스터마이징

### 문제

핵심인 **Automatic Identity Linking을 막을 수 있는지는 보장되지 않는다.**

즉 Hook만으로는 근본 해결책이 되기 어렵다.

---

## 3. 자체 Auth 구현

```text
Flutter
   │
Google / Kakao / Naver
   │
자체 Auth Server
   │
JWT
   │
Supabase DB
```

### 장점

* 계정 정책 100% 자유
* provider 기준 계정 생성 가능

### 단점

* JWT 발급
* Refresh Token
* 세션 관리
* 보안
* 계정 복구

등을 모두 직접 구현해야 한다.

초기 프로젝트에는 부담이 크다.

---

# 선택한 방향: Auth0

## 왜 Auth0인가?

### 1. Connection 기반 사용자 모델

Auth0에서는 로그인 제공자가 각각 독립된 Connection이다.

```text
Google Connection
 └── google|123

Kakao Connection
 └── kakao|456

Naver Connection
 └── naver|789
```

동일 이메일이라도 **서로 다른 User ID**를 가질 수 있다.

### 2. 무료 플랜도 충분

* 25,000 MAU
* Social Login 무제한
* Google / Kakao / Naver 구성 가능

Firebase Free의 OIDC 50 MAU보다 현실적이다.

### 3. 계정 연결은 선택 사항

필요할 때만 Account Linking을 제공하므로,

기본 정책을 "로그인 수단 = 하나의 계정" 으로 가져가기 쉽다.

---

# 최종 아키텍처

```text
                 Auth0
                   │
      ┌────────────┼────────────┐
      │            │            │
   Google       Kakao        Naver
      │            │            │
      └────────────┼────────────┘
                   │
             Auth0 User ID
                   │
                   ▼
            Flutter (Riverpod)
                   │
                   ▼
             Supabase Database
                   │
          RLS / Storage / Realtime
```

### 역할 분리

| 담당      | 서비스              |
| ------- | ---------------- |
| 인증      | Auth0            |
| 사용자 데이터 | Supabase         |
| 게시글/댓글  | Supabase         |
| 파일      | Supabase Storage |
| 권한      | Supabase RLS     |

---

# Flutter 구조

현재 Repository–DataSource 구조는 그대로 유지한다.

```text
Auth0
  │
  ▼
AuthDataSource
  │
  ▼
AuthRepository
  │
  ▼
Riverpod AuthState
  │
  ▼
GoRouter Redirect
```

### 장점

* Auth 공급자 교체가 쉬움
* UI는 Auth0를 모름
* 테스트 용이
* Riverpod 중심 상태 관리 유지

---

# GoRouter 인증 리다이렉트

기존에는

```text
Supabase
onAuthStateChange
        │
        ▼
refreshListenable
        ▼
GoRouter
```

이었다.

Auth0에서는 Stream 대신 Riverpod 상태를 사용한다.

```text
Auth0
Credentials
      │
      ▼
Riverpod AuthState
      │
      ▼
RouterRefreshNotifier
      │
      ▼
GoRouter
```

즉 `onAuthStateChange`가 없어도 **인증 상태 기반 리다이렉트는 동일하게 구현 가능**하다.

---

# 남은 검증 사항

Auth0 도입 전 반드시 확인할 항목

* [ ] Google `A@naver.com` 가입
* [ ] Kakao `A@naver.com` 가입
* [ ] Naver `A@naver.com` 가입
* [ ] Dashboard에서 3개의 서로 다른 User ID 생성 확인
* [ ] Auth0 JWT → Supabase RLS 연동 검증
* [ ] Flutter Credential Manager 기반 자동 로그인 동작 확인

---

# 결론

현재 프로젝트의 요구사항은 **이메일 기반 계정이 아니라 Identity 기반 계정**이다.

Supabase Auth는 구현이 매우 편하지만 Automatic Identity Linking 때문에 커뮤니티 계정 모델과 충돌한다.

반면 Auth0는 Connection 기반 사용자 모델을 제공하여 **Google / Kakao / Naver를 각각 독립 계정으로 운영하기에 더 적합한 선택지**로 판단된다.
