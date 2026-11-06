# Cain 작업 규칙

Flutter 앱은 `cain/`(pubspec.yaml 위치)에 있다. 팀원 3명이 합의한 구조 정렬 제안서 기준이며, 모든 작업은 이 파일을 따른다.

## 절대 기준

- 기획(기능, 화면 S01~S11, 데이터 모델 4개, `assets/data`의 JSON 4개, AppStrings 문구)은 지금 Git 코드가 기준이다. 임의로 바꾸지 않는다.
- 코드 작성 방식은 수업 기준이다.
  - `Navigator.push<T>(MaterialPageRoute)` + 생성자 전달 + `pop<T>` 결과 반환
  - await 뒤 `mounted` 확인, try/catch/finally
  - Form + validator
  - ChangeNotifier + Provider(watch/read)
  - abstract Repository + 실제/Demo 구현 교체
- 금지: 새 패키지 추가, 모델 필드나 JSON 변경, UI 배치·색·문구 변경, 화면 추가·삭제.
- 수업에 없는 API는 쓰지 않는다. `pushNamed`, `pushReplacementNamed`, `pushNamedAndRemoveUntil`, `onGenerateRoute`, `PageRouteBuilder`를 쓰지 않는다.
- 예외 하나: Repository 공유는 provider 패키지의 `Provider<T>.value`를 쓴다.

## 폴더 규칙 (`cain/lib/`)

```
lib/
├── main.dart          앱 시작, MultiProvider 등록, CainApp(MaterialApp)
├── app_theme.dart
├── app_strings.dart   AppStrings, AppLocale, kSupportedLocales
├── models/
├── services/
├── repositories/
├── viewmodels/
├── screens/           화면 1개 = 파일 1개
└── widgets/
```

- models: 필드, 생성자, factory fromJson만 둔다. http, rootBundle, 위젯 import는 금지.
- services: http 요청, 상태 코드 확인, jsonDecode만 한다.
- repositories: abstract 계약과 구현을 둔다(`local_` / `api_` / `demo_` 접두어). BuildContext와 로딩 상태는 금지.
- viewmodels: `extends ChangeNotifier`. private 상태 + getter, `notifyListeners()`, `_disposed` 플래그를 둔다. 위젯과 Navigator는 금지.
- screens: 화면과 그 화면 전용 private 위젯을 둔다. http, rootBundle, jsonDecode, `XxxRepository()` 직접 생성은 금지.
- widgets: 2개 이상의 화면이 쓰는 위젯만 둔다.

## 코드 규칙

1. 화면 이동: `Navigator.push(MaterialPageRoute(builder: (_) => XxxScreen(필요한 값)))` + 생성자 전달.
   - MaterialApp은 `home:` 하나다. LocaleProvider 로드 전이면 로딩, 언어 저장 이력이 없으면 LanguageSelectScreen, 있으면 HomeScreen.
   - 언어 선택 완료 시 화면을 이동하지 않고 LocaleProvider 상태를 바꾼다.
   - S11은 `pop(context, 'home')` / `pop(context, 'again')`을 돌려준다. guide_step은 'again'이면 `GuideViewModel.restart()`, 'home'이면 위로 전달한다. pre_visit, service_detail, service_list도 'home'을 위로 전달한다.
   - S09는 S05에서 `await Navigator.push<String>`으로 연다. 추천 서비스 탭은 `pop<String>(serviceId)`로 돌려준다. S05의 단계 index는 유지한다.
2. 비동기 로드: `try { … if (!mounted) return; setState } catch { 오류 문구 } finally { if (mounted) 로딩 해제 }`. `.then` 대신 async/await를 쓴다.
3. ViewModel 수명: `ChangeNotifierProvider(create: …)`로 만든다. `_disposed` 플래그, dispose 오버라이드, `if (_isLoading || _disposed) return;` 중복 요청 차단을 둔다. LocaleProvider는 `create: (_) => LocaleProvider()..load()`로 등록하고 main에서 await하지 않는다.
4. Repository 공유: main의 MultiProvider에 등록하고 화면은 `context.read<…>()`로만 가져온다.
5. 구현 교체: ServiceRepository, ChatRepository는 abstract다. main에서 `String.fromEnvironment('CAIN_API_BASE')`가 비면 DemoChatRepository, 아니면 ApiChatRepository를 쓴다.
6. AI 호출: ChatApiService(HTTP) → ApiChatRepository(ChatAnswer 변환) → AssistantViewModel(상태, 409·429·타임아웃·기타 오류 문구) → 화면. 하드코딩 오류 문구는 app_strings.dart에 두고 지원 언어 전부에 넣는다.
7. 질문 입력: Form + TextFormField + validator. 빈 값과 300자 초과를 막고 전송 전에 `_formKey.currentState!.validate()`를 확인한다. TextEditingController는 dispose에서 정리한다.
8. 전송 버튼: `IconButton.filled(onPressed: vm.isSending ? null : _submit)`. 전송 중에는 LinearProgressIndicator, 오류가 있으면 오류 문구를 표시한다.

바꾸지 않는 것:

- 목록·상세·준비·완료·전화번호부·지도 화면의 setState 구조
- GuideStep이 services.json 안에 들어 있는 구조
- withOpacity 경고
- flutter_localizations 미도입

## 커밋 규칙

- 커밋 메시지는 한국어로 `refactor: …`, `feat: …`, `docs: …` 형식을 쓴다.
- 각 커밋 전 `flutter analyze` 오류 0. 구조·기능 변경 뒤에는 `flutter build apk --debug` 성공까지 확인한다.
- push 전에는 항상 `git pull --rebase origin main`을 한다. 충돌이 나면 해결을 추측하지 말고 멈추고 보고한다.
- force push, 히스토리 수정, API 키나 서버 주소 커밋은 금지한다.
