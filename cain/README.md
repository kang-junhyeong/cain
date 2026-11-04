# Cain

외국인 유학생을 위한 캠퍼스 안내 Flutter 앱

---

## 개발 환경 설정 (Windows · Android Studio 기준)

### 1. 저장소 클론

1. Android Studio 실행
2. 상단 메뉴 `File > New > Project from Version Control` (3번째 항목)
3. `GitHub` 선택
4. GitHub 계정 로그인
5. 저장소 목록에서 `cain` 선택 후 `Clone`

### 2. Flutter SDK 경로 설정 (최초 1회)

`File > Settings` (단축키: `Ctrl + Alt + S`)
→ `Languages & Frameworks > Flutter`
→ Flutter SDK path 입력

### 3. 실행

에뮬레이터 또는 실기기 연결 후 ▶ 버튼 클릭

---

## Git 작업 흐름

| 작업 | 단축키 (Windows) |
|------|----------------|
| 커밋 | `Ctrl + K` |
| 푸시 | `Ctrl + Shift + K` |
| 풀 | `Ctrl + T` |

수정 → 커밋 → 푸시 순서로 진행

---

## Claude Code CLI 설정 (선택)

Android Studio 내장 터미널에서 Claude AI 사용 가능

### 설치
1. Node.js 설치: https://nodejs.org (LTS 버전)
2. 터미널에서 설치:
```bash
npm install -g @anthropic-ai/claude-code
```
3. 터미널 재시작 후 실행:
```bash
claude
```

---

## 기술 스택

- Flutter / Dart
- Provider (상태 관리)
- SharedPreferences (로컬 저장)
- 4개국어 지원 (한국어 · 영어 · 중국어 · 벵골어)
