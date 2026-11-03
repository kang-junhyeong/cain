# Cain — 개발 메모 (DEV_NOTES)

> 최종 갱신: 2026-11-03
> 담당: 강준형 (프론트엔드)
> 앱명: Cain — AI 다국어 캠퍼스 생활 안내 앱 (한국기술교육대학교)

---

## 목차

1. [프로젝트 구조](#1-프로젝트-구조)
2. [실행 방법](#2-실행-방법)
3. [코드 검토 이력](#3-코드-검토-이력)
4. [보류 목록](#4-보류-목록)
5. [TODO — 실제 데이터 입력 필요](#5-todo--실제-데이터-입력-필요)
6. [팀 계약](#6-팀-계약)
7. [화면 흐름](#7-화면-흐름)
8. [변경 이력](#8-변경-이력)

---

## 1. 프로젝트 구조

```
cain/
├── pubspec.yaml                        # 의존성 (provider, shared_preferences, url_launcher, http)
├── assets/
│   └── data/
│       ├── manifest.json               # contentVersion, 지원 언어 목록
│       ├── services.json               # 서비스 + 단계 데이터 (현재 더미)
│       ├── contacts.json               # 전화번호부 (현재 더미)
│       └── buildings.json              # 건물 정보 (현재 더미)
└── lib/
    ├── main.dart                       # 진입점: SharedPreferences 언어 확인 → 분기
    ├── app/
    │   ├── app.dart                    # MaterialApp, 전체 라우팅
    │   ├── routes.dart                 # 라우트 경로 상수
    │   └── theme.dart                  # 색상·테마 (Primary: #1565C0, Accent: #FF8F00)
    ├── core/
    │   ├── models/
    │   │   ├── localized_text.dart     # LocalizedText: resolve(locale), isFallback(locale)
    │   │   ├── service.dart            # ServiceModel + GuideStep
    │   │   ├── building.dart           # Building (hasCoordinates)
    │   │   └── contact.dart            # Contact
    │   ├── locale/
    │   │   └── locale_provider.dart    # LocaleProvider (ChangeNotifier) + AppStrings (4개 언어)
    │   └── repositories/
    │       ├── service_repository.dart # getAll / getById / getByCategory / search
    │       ├── contact_repository.dart # getAll / getById / getByIds / search
    │       └── building_repository.dart# getAll / getById
    ├── features/
    │   ├── language_select/            # S01 — 첫 실행 언어 선택
    │   ├── home/                       # S02 — 홈·검색·설정 탭 (BottomNavigationBar)
    │   ├── guides/
    │   │   ├── service_list_screen     # S03 — 서비스 목록 (카테고리별)
    │   │   ├── service_detail_screen   # S04 — 서비스 상세 (위치·시간·준비물·이용 대상)
    │   │   ├── pre_visit_screen        # S04b — 방문 전 준비 (체크리스트)
    │   │   ├── guide_step_screen       # S05 — 단계별 안내 (진행 바·이미지·주의사항·AI 버튼)
    │   │   └── completion_screen       # S11 — 이용 완료 (후속 안내·홈으로·다시 보기)
    │   ├── campus/                     # S06 — 캠퍼스 지도 【보류】
    │   ├── directory/                  # S07 — 전화번호부 (검색·전화·복사)
    │   ├── online/                     # S08 — 교내 온라인 서비스 (외부 링크)
    │   ├── assistant/                  # S09 — AI 챗봇 UI (서버 연동 【보류】)
    │   └── settings/                   # S10 — 설정 (홈 탭 3번에 인라인 구현)
    └── shared/
        └── widgets/
            ├── service_card.dart       # 서비스 목록 카드 (검수 배지 포함)
            └── step_nav_button.dart    # 이전/다음/완료 버튼 세트
```

---

## 2. 실행 방법

코드는 완성되어 있지만 Flutter SDK 설치가 필요합니다.

```bash
# 1. Flutter SDK 설치
brew install --cask flutter

# 2. 기본 프로젝트 스캐폴딩 생성
cd /Users/kang-junhyeong/workspace/flutter
flutter create --org com.cain --project-name cain cain_base

# 3. 필요한 폴더를 cain/ 에 복사
cp -r cain_base/android  cain/
cp -r cain_base/ios      cain/
cp -r cain_base/test     cain/
rm -rf cain_base

# 4. 패키지 설치 및 실행
cd cain
flutter pub get
flutter run
```

> **주의:** `cain/lib/`, `cain/assets/`, `cain/pubspec.yaml`은 이미 작성되어 있으므로
> 덮어쓰지 말고 `android/`, `ios/`, `test/`만 복사합니다.

---

## 3. 코드 검토 이력

### 검토 일자: 2026-11-03 (1차)

전체 파일을 검토하여 발견된 문제 9건을 수정 완료.

| # | 심각도 | 파일 | 문제 | 상태 |
|---|--------|------|------|------|
| 1 | 🔴 High | `shared/widgets/service_card.dart:61` | `'검수 완료'` 하드코딩 → 다국어 미지원 | ✅ 수정 |
| 2 | 🔴 High | `features/guides/completion_screen.dart:129-133` | 후속 확인사항 한글 하드코딩 | ✅ 수정 |
| 3 | 🔴 High | `features/guides/completion_screen.dart:129` | `s.title.resolve(locale) == '재학 증명서'` — 언어 변경 시 항상 false | ✅ 수정 (serviceId 비교로 변경, 더 나아가 공통 문자열로 통합) |
| 4 | 🟡 Medium | `features/online/online_screen.dart:163` | `'링크를 열 수 없습니다.'` 하드코딩 | ✅ 수정 |
| 5 | 🟡 Medium | `features/campus/campus_screen.dart:129` | `'위치 정보 준비 중'` 하드코딩 | ✅ 수정 |
| 6 | 🟡 Medium | `app/app.dart:5` | `campus_screen.dart` import 후 미사용 (unused import 경고) | ✅ 수정 (주석 처리) |
| 7 | 🟡 Medium | `app/app.dart` | `settings` 라우트 케이스 누락 → default(홈)로 잘못 라우팅 | ✅ 수정 (홈으로 리다이렉트 명시) |
| 8 | 🟢 Low | `locale_provider.dart` | `locationUnavailable`, `cannotOpenLink`, `followUpCheckDoc`, `followUpSavePrint`, `urlPending` 문자열 누락 | ✅ 추가 |
| 9 | 🟢 Low | `app/app.dart` | `provider` import 미사용 | ✅ 수정 (제거) |

**수정 후 잔여 문제 없음.** 다음 검토 시점: 서버 연동 후.

---

## 4. 보류 목록

### 4-1. 캠퍼스 지도 (S06) — `lib/features/campus/campus_screen.dart`

**상태:** 파일 존재, 라우트와 import 주석 처리, 건물 목록 폴백 화면만 동작
**재개 조건:**

- [ ] 지도 방식 결정
  - 옵션 A: `google_maps_flutter` — Google Maps API 키 필요 (Android용 `google-services.json`)
  - 옵션 B: WebView + 네이버지도/카카오맵 URL — 별도 API 키 불필요
- [ ] `buildings.json`에 주요 건물 위도·경도 입력
- [ ] 층별 배치도 이미지 확보 → `assets/maps/` 에 추가 (`pubspec.yaml` 주석 해제 필요)

**재개 시 수정 위치:**

```
pubspec.yaml                    — google_maps_flutter 주석 해제 / assets/maps/ 주석 해제
lib/app/routes.dart             — campus 라우트 주석 해제
lib/app/app.dart                — campus import 주석 해제, case 주석 해제
lib/features/campus/            — 실제 지도 위젯 구현
assets/data/buildings.json      — latitude, longitude 입력
```

---

### 4-2. AI 챗봇 서버 연동 (S09) — `lib/features/assistant/assistant_screen.dart`

**상태:** UI 완성, `_sendMessage()` 내 HTTP 코드 전체 주석 처리, 더미 응답 반환 중
**재개 조건:**

- [ ] FastAPI 서버 배포 URL 확정 (담당: 윤우성)
- [ ] `assistant_screen.dart` 상단 `_kApiBase` 상수에 실제 URL 입력
- [ ] `http` 패키지 import 주석 해제 (`pubspec.yaml`에 이미 선언됨)
- [ ] `_sendMessage()` 내 주석 블록 해제 및 더미 코드 삭제

**API 계약:** `기획/개발 기획서.md` 섹션 06·07 참조

**오류 처리 구현 범위 (주석 내 포함):**

| HTTP 코드 | 동작 |
|-----------|------|
| 200 answered | 답변 + 출처 라벨 표시 |
| 200 insufficient_evidence | 확인 안내 메시지 |
| 409 CONTENT_VERSION_MISMATCH | 앱 업데이트 안내 |
| 429 RATE_LIMITED | 잠시 후 재시도 안내 |
| 502/503 AI_UNAVAILABLE | 로컬 안내 이용 권장 |
| Timeout (30s) | 재시도 버튼 |

---

## 5. TODO — 실제 데이터 입력 필요

담당: 정대윤 (PM·기획)

### `assets/data/services.json`

| 서비스 ID | TODO 항목 |
|-----------|-----------|
| 모든 서비스 | `verificationStatus: "pending"` → 실제 자료 검수 후 `"approved"`로 변경 |
| `cafeteria` | `location`, `hours` 필드 실제 값 입력 |
| `online_services` | 각 온라인 서비스별 steps 배열 입력 (현재 빈 배열) |

### `assets/data/contacts.json`

모든 연락처의 `phone` 필드가 `"TODO: 실제 번호 입력"` 상태.
실제 번호 입력 시 `directory_screen.dart`의 전화·복사 기능이 자동 활성화됨.

### `assets/data/buildings.json`

모든 건물의 `latitude`, `longitude`, `imagePath`가 `null`.
지도 구현 재개 시 함께 업데이트 필요.

### `lib/features/online/online_screen.dart`

`_kServices` 상수의 각 `url` 필드가 `"TODO: ..."` 상태.
실제 한기대 공식 URL 확인 후 입력 필요.

---

## 6. 팀 계약

### 모델 계약
`lib/core/models/` 내 클래스 이름·필드·ID 변경은 3인 사전 합의 필요.

### 데이터 계약
- `cain/assets/data/` = 앱 배포용 원본
- `cain/content/` = 팀 공통 원본 (백엔드와 동일 버전 유지)
- `manifest.json`의 `contentVersion` = 앱·서버 동일하게 유지
- 버전 불일치 시 서버가 409 반환 → 앱은 업데이트 안내

### 화면 계약
- 화면 이동 시 `serviceId`, `stepId`를 `arguments` Map으로 전달
- AI 화면 진입 후 pop 시 원래 단계(`stepIndex`)와 체크 상태는 `GuideStepScreen`이 자체 유지
- `completion_screen`에서 홈으로 이동 시 전체 스택 제거 (`pushNamedAndRemoveUntil`)

### API 계약
`기획/개발 기획서.md` 섹션 06·07 준수.
서버 미응답 시 앱은 로컬 안내로 폴백.

### 브랜치 전략
`feature/*` → PR → 다른 팀원 1명 리뷰 후 merge
공통 모델·API 수정은 3인 합의 후 진행.

---

## 7. 화면 흐름

```
앱 시작
  ├─ 저장된 언어 없음 → LanguageSelectScreen (S01)
  └─ 저장된 언어 있음 → HomeScreen (S02)

HomeScreen (탭)
  ├─ [홈 탭]
  │   ├─ 서류발급 카테고리 → ServiceListScreen (S03, categoryId: 'documents')
  │   ├─ 캠퍼스 시설 카테고리 → SnackBar "지도 준비 중" 【보류】
  │   ├─ 서비스 카드 탭 → ServiceDetailScreen (S04)
  │   └─ AI 질문 버튼 → AssistantScreen (S09, 컨텍스트 없음)
  ├─ [검색 탭] → 실시간 검색 → ServiceDetailScreen
  └─ [설정 탭] → 언어 변경 + 데이터 버전 표시 (인라인)

ServiceDetailScreen (S04)
  ├─ 위치 확인 버튼 → SnackBar "지도 준비 중" 【보류】
  └─ 절차 시작 버튼 → PreVisitScreen (S04b)

PreVisitScreen (S04b)
  └─ 절차 시작 버튼 → GuideStepScreen (S05, stepIndex: 0)

GuideStepScreen (S05)
  ├─ 이전/다음 버튼 → 같은 화면, stepIndex 변경
  ├─ AI 질문 버튼 → AssistantScreen (S09, serviceId + stepId 컨텍스트)
  │   └─ pop → GuideStepScreen 복귀 (상태 유지)
  └─ 마지막 단계 완료 → CompletionScreen (S11) [스택 교체]

CompletionScreen (S11)
  ├─ 홈으로 → HomeScreen [전체 스택 제거]
  └─ 다시 보기 → GuideStepScreen (stepIndex: 0) [홈 위에 유지]
```

---

## 8. 변경 이력

| 날짜 | 버전 | 내용 |
|------|------|------|
| 2026-11-03 | v0.1.0 | 전체 초기 구현 (31개 파일) |
| 2026-11-03 | v0.1.1 | 1차 코드 검토 후 9개 문제 수정, DEV_NOTES 재작성 |
