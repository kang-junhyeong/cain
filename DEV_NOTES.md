# Cain — 개발 메모 (DEV_NOTES)

> 최종 갱신: 2026-11-06
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
    ├── main.dart                       # 앱 시작, MultiProvider 등록, CainApp(MaterialApp)
    ├── app_theme.dart                  # 색상·테마 (Primary: #1565C0, Accent: #FF8F00)
    ├── app_strings.dart                # AppStrings (4개 언어), AppLocale, kSupportedLocales
    ├── models/
    │   ├── localized_text.dart         # LocalizedText: resolve(locale), isFallback(locale)
    │   ├── service.dart                # ServiceModel + GuideStep
    │   ├── building.dart               # Building (hasCoordinates)
    │   ├── contact.dart                # Contact
    │   ├── chat_message.dart           # 화면에 표시할 채팅 메시지
    │   └── chat_answer.dart            # AI 응답 (status, answer, references)
    ├── services/
    │   └── chat_api_service.dart       # POST /api/v1/chat, 상태 코드 확인, jsonDecode
    ├── repositories/
    │   ├── service_repository.dart     # abstract: getAll / getById / getByCategory / search
    │   ├── local_service_repository.dart # services.json 구현
    │   ├── contact_repository.dart     # getAll / getById / getByIds / search
    │   ├── building_repository.dart    # getAll / getById
    │   ├── chat_repository.dart        # abstract: ask
    │   ├── api_chat_repository.dart    # 서버 구현
    │   └── demo_chat_repository.dart   # 서버 없는 시연용 구현
    ├── viewmodels/
    │   ├── locale_provider.dart        # 언어 상태, hasSelected
    │   ├── home_view_model.dart        # 주요 서비스, 검색
    │   ├── guide_view_model.dart       # 단계 index, restart()
    │   └── assistant_view_model.dart   # 메시지, 전송 상태, 오류 문구
    ├── screens/
    │   ├── language_select_screen.dart # S01 — 첫 실행 언어 선택
    │   ├── home_screen.dart            # S02 — 홈·검색·설정 탭 (S10 설정은 탭 3번에 인라인 구현)
    │   ├── service_list_screen.dart    # S03 — 서비스 목록 (카테고리별)
    │   ├── service_detail_screen.dart  # S04 — 서비스 상세 (위치·시간·준비물·이용 대상)
    │   ├── pre_visit_screen.dart       # S04b — 방문 전 준비 (체크리스트)
    │   ├── guide_step_screen.dart      # S05 — 단계별 안내 (진행 바·이미지·주의사항·AI 버튼)
    │   ├── campus_screen.dart          # S06 — 캠퍼스 지도 【보류】
    │   ├── directory_screen.dart       # S07 — 전화번호부 (검색·전화·복사)
    │   ├── online_screen.dart          # S08 — 교내 온라인 서비스 (외부 링크)
    │   ├── assistant_screen.dart       # S09 — AI 챗봇 (서버 연동 【보류】, 기본은 Demo)
    │   └── completion_screen.dart      # S11 — 이용 완료 (후속 안내·홈으로·다시 보기)
    └── widgets/
        ├── service_card.dart           # 서비스 목록 카드 (검수 배지 포함)
        └── step_nav_button.dart        # 이전/다음/완료 버튼 세트
```

폴더별 규칙은 저장소 루트의 `CLAUDE.md`를 따른다.

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

### 4-1. 캠퍼스 지도 (S06) — `lib/screens/campus_screen.dart`

**상태:** 파일 존재, 어느 화면에서도 열지 않음, 건물 목록 폴백 화면만 동작
**재개 조건:**

- [ ] 지도 방식 결정
  - 옵션 A: `google_maps_flutter` — Google Maps API 키 필요 (Android용 `google-services.json`)
  - 옵션 B: WebView + 네이버지도/카카오맵 URL — 별도 API 키 불필요
- [ ] `buildings.json`에 주요 건물 위도·경도 입력
- [ ] 층별 배치도 이미지 확보 → `assets/maps/` 에 추가 (`pubspec.yaml` 주석 해제 필요)

**재개 시 수정 위치:**

```
pubspec.yaml                    — google_maps_flutter 주석 해제 / assets/maps/ 주석 해제
lib/screens/home_screen.dart    — 캠퍼스 시설 버튼에서 Navigator.push로 CampusScreen 열기
lib/screens/campus_screen.dart  — 실제 지도 위젯 구현
assets/data/buildings.json      — latitude, longitude 입력
```

---

### 4-2. AI 챗봇 서버 연동 (S09) — `lib/screens/assistant_screen.dart`

**상태:** UI와 호출 계층 완성, 기본 실행은 `DemoChatRepository` 사용
**재개 조건:**

- [ ] FastAPI 서버 배포 URL 확정 (담당: 윤우성)
- [ ] 코드 수정 없이 아래 명령으로 실행 (서버 주소는 커밋하지 않음)

```bash
flutter run --dart-define=CAIN_API_BASE=주소
```

`CAIN_API_BASE`가 비어 있으면 `DemoChatRepository`, 값이 있으면 `ApiChatRepository`를 쓴다.
Demo는 질문에 `error`나 `오류`가 들어가면 예외를 던져 오류 화면을 시연할 수 있다.

**API 계약:** `기획/개발 기획서.md` 섹션 06·07 참조

**오류 처리 구현 범위:**

| HTTP 코드 | 동작 |
|-----------|------|
| 200 answered | 답변 + 출처 라벨 표시 |
| 200 insufficient_evidence | 확인 안내 메시지 |
| 409 CONTENT_VERSION_MISMATCH | 앱 업데이트 안내 |
| 429 RATE_LIMITED | 잠시 후 재시도 안내 |
| 502/503 AI_UNAVAILABLE | 로컬 안내 이용 권장 |
| Timeout (30s) | 재시도 안내 |

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

### `lib/screens/online_screen.dart`

`_kServices` 상수의 각 `url` 필드가 `"TODO: ..."` 상태.
실제 한기대 공식 URL 확인 후 입력 필요.

---

## 6. 팀 계약

### 모델 계약
`lib/models/` 내 클래스 이름·필드·ID 변경은 3인 사전 합의 필요.

### 데이터 계약
- `cain/assets/data/` = 앱 배포용 원본
- `cain/content/` = 팀 공통 원본 (백엔드와 동일 버전 유지)
- `manifest.json`의 `contentVersion` = 앱·서버 동일하게 유지
- 버전 불일치 시 서버가 409 반환 → 앱은 업데이트 안내

### 화면 계약
- 화면 이동은 생성자 전달 + `pop<T>` 결과로 값을 주고받는다 (`Navigator.push<T>(MaterialPageRoute)`)
- AI 화면(S09)은 S05에서 `await Navigator.push<String>`으로 연다. 추천 서비스를 탭하면 `pop<String>(serviceId)`로 돌려주고, 단계 index는 `GuideViewModel`이 유지한다
- `completion_screen`은 `pop(context, 'home')` 또는 `pop(context, 'again')`을 돌려준다. `guide_step`은 'again'이면 `restart()`, 'home'이면 위로 전달하고, `pre_visit`, `service_detail`, `service_list`도 'home'을 위로 전달한다

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
  ├─ LocaleProvider 로드 전 → 로딩 화면
  ├─ 저장된 언어 없음 → LanguageSelectScreen (S01)
  └─ 저장된 언어 있음 → HomeScreen (S02)

MaterialApp은 home 하나다. 언어를 선택하면 LocaleProvider 상태가 바뀌어 home이 다시 그려진다.

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
  │   ├─ pop → GuideStepScreen 복귀 (상태 유지)
  │   └─ 추천 서비스 탭 → pop<String>(serviceId) → SnackBar 표시 (상태 유지)
  └─ 마지막 단계 완료 → await push<String> CompletionScreen (S11)

CompletionScreen (S11)
  ├─ 홈으로 → pop('home') → 각 화면이 'home'을 위로 전달 → HomeScreen
  ├─ 다시 보기 → pop('again') → GuideStepScreen restart() (stepIndex: 0)
  └─ 뒤로가기 → GuideStepScreen 마지막 단계로 복귀
```

---

## 8. 변경 이력

| 날짜 | 버전 | 내용 |
|------|------|------|
| 2026-11-03 | v0.1.0 | 전체 초기 구현 (31개 파일) |
| 2026-11-03 | v0.1.1 | 1차 코드 검토 후 9개 문제 수정, DEV_NOTES 재작성 |
| 2026-11-06 | v0.2.0 | 구조 정렬: 폴더 구조 변경, 화면 이동을 생성자 전달 + pop 결과로 변경, ViewModel 수명과 Repository 공유 정리, AI 호출 계층 분리 + Demo 구현, 질문 입력 Form 검증 |
