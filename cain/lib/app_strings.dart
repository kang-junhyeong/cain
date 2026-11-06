/// 지원 언어 목록
const List<AppLocale> kSupportedLocales = [
  AppLocale(code: 'ko', label: '한국어', flag: '🇰🇷'),
  AppLocale(code: 'en', label: 'English', flag: '🇺🇸'),
  AppLocale(code: 'zh', label: '中文', flag: '🇨🇳'),
  AppLocale(code: 'bn', label: 'বাংলা', flag: '🇧🇩'),
];

class AppLocale {
  final String code;
  final String label;
  final String flag;

  const AppLocale({required this.code, required this.label, required this.flag});
}

/// 다국어 UI 문자열 (앱 고정 텍스트)
/// TODO(zh): 중국어 번역 완성 필요
/// TODO(bn): 벵골어 번역 완성 필요
class AppStrings {
  final String locale;

  const AppStrings(this.locale);

  String get appName => _t(ko: 'Cain', en: 'Cain', zh: 'Cain', bn: 'Cain');
  String get appSubtitle => _t(
    ko: '교내 시설·서비스 이용 안내',
    en: 'Campus facility & service guide',
    zh: '校内设施·服务使用指南',
    bn: 'ক্যাম্পাস সুবিধা ও সেবা গাইড',
  );

  // 탭 바
  String get tabHome => _t(ko: '홈', en: 'Home', zh: '首页', bn: 'হোম');
  String get tabSearch => _t(ko: '검색', en: 'Search', zh: '搜索', bn: 'অনুসন্ধান');
  String get tabSettings => _t(ko: '설정', en: 'Settings', zh: '设置', bn: 'সেটিংস');

  // 홈
  String get searchHint => _t(
    ko: '서비스를 검색해보세요',
    en: 'Search for services',
    zh: '搜索服务',
    bn: 'সেবা অনুসন্ধান করুন',
  );
  String get categoryDocuments => _t(ko: '서류발급', en: 'Documents', zh: '证书申请', bn: 'সার্টিফিকেট');
  String get categoryCampus => _t(ko: '캠퍼스 시설', en: 'Campus', zh: '校园设施', bn: 'ক্যাম্পাস');
  String get featuredServices => _t(ko: '주요 서비스', en: 'Featured Services', zh: '主要服务', bn: 'প্রধান সেবা');
  String get viewAll => _t(ko: '전체보기', en: 'View all', zh: '查看全部', bn: 'সব দেখুন');
  String get helpSection => _t(ko: '도움 기능', en: 'Help', zh: '帮助功能', bn: 'সাহায্য');
  String get aiAssistant => _t(ko: 'AI 질문', en: 'AI Assistant', zh: 'AI问答', bn: 'AI সহকারী');
  String get aiAssistantDesc => _t(
    ko: '교내 생활, 시설, 서비스 등\n무엇이든 물어보세요',
    en: 'Ask anything about campus life,\nfacilities, and services',
    zh: '关于校园生活、设施、服务等\n任何问题都可以询问',
    bn: 'ক্যাম্পাস জীবন, সুবিধা এবং সেবা সম্পর্কে\nযেকোনো প্রশ্ন করুন',
  );

  // 서비스 목록·상세
  String get selectService => _t(ko: '필요한 서비스를 선택하세요', en: 'Select a service', zh: '请选择所需服务', bn: 'একটি সেবা নির্বাচন করুন');
  String get locationLabel => _t(ko: '이용 장소', en: 'Location', zh: '使用地点', bn: 'অবস্থান');
  String get hoursLabel => _t(ko: '운영시간', en: 'Hours', zh: '运营时间', bn: 'সময়সূচি');
  String get requirementsLabel => _t(ko: '준비물', en: 'Requirements', zh: '所需材料', bn: 'প্রয়োজনীয় জিনিস');
  String get targetUsersLabel => _t(ko: '이용 대상', en: 'Target users', zh: '适用对象', bn: 'লক্ষ্য ব্যবহারকারী');
  String get checkLocation => _t(ko: '위치 확인', en: 'Check location', zh: '确认位置', bn: 'অবস্থান দেখুন');
  String get startProcedure => _t(ko: '절차 시작', en: 'Start procedure', zh: '开始流程', bn: 'প্রক্রিয়া শুরু করুন');
  String get verifiedBadge => _t(ko: '검수 완료', en: 'Verified', zh: '审核完成', bn: 'যাচাইকৃত');

  // 준비물 화면
  String get preVisitTitle => _t(ko: '방문 전 준비', en: 'Pre-visit checklist', zh: '访问前准备', bn: 'পরিদর্শনের আগে প্রস্তুতি');
  String get checklist => _t(ko: '준비물 체크리스트', en: 'Checklist', zh: '准备清单', bn: 'চেকলিস্ট');
  String get preVisitNotes => _t(ko: '방문 전 안내사항', en: 'Before you go', zh: '访问前注意事项', bn: 'যাওয়ার আগে জানুন');

  // 단계 화면
  String get stepOf => ''; // "{current} / {total} 단계" — 포맷 메서드 사용
  String stepProgress(int current, int total) => _t(
    ko: '$current / $total 단계',
    en: 'Step $current of $total',
    zh: '第$current步 / 共$total步',
    bn: 'ধাপ $current / $total',
  );
  String get caution => _t(ko: '주의사항', en: 'Caution', zh: '注意事项', bn: 'সতর্কতা');
  String get askAI => _t(ko: 'AI에게 질문', en: 'Ask AI', zh: '询问AI', bn: 'AI-কে জিজ্ঞেস করুন');
  String get trackProgress => _t(ko: '진행이 막혔어요', en: 'I\'m stuck', zh: '遇到问题了', bn: 'আমি আটকে গেছি');
  String get prevStep => _t(ko: '이전', en: 'Prev', zh: '上一步', bn: 'আগে');
  String get nextStep => _t(ko: '다음', en: 'Next', zh: '下一步', bn: 'পরে');

  // 완료 화면
  String get completionTitle => _t(ko: '절차를 완료했어요!', en: 'All done!', zh: '流程完成！', bn: 'সম্পন্ন হয়েছে!');
  String completionMessage(String serviceName) => _t(
    ko: '$serviceName 절차가 정상적으로 완료되었어요!\n발급된 내용을 꼭 확인해 주세요.',
    en: 'The $serviceName procedure has been completed successfully!\nPlease check the issued document.',
    zh: '$serviceName流程已成功完成！\n请务必确认发放的内容。',
    bn: '$serviceName প্রক্রিয়া সফলভাবে সম্পন্ন হয়েছে!\nইস্যু করা নথি অবশ্যই পরীক্ষা করুন।',
  );
  String get followUpTitle => _t(ko: '후속 확인사항', en: 'Follow-up', zh: '后续确认事项', bn: 'পরবর্তী পদক্ষেপ');
  String get goHome => _t(ko: '홈으로', en: 'Go home', zh: '返回首页', bn: 'হোমে যান');
  String get viewAgain => _t(ko: '다시 보기', en: 'View again', zh: '再次查看', bn: 'আবার দেখুন');

  // 전화번호부
  String get directoryTitle => _t(ko: '전화번호부', en: 'Directory', zh: '电话号码簿', bn: 'ডিরেক্টরি');
  String get searchDept => _t(ko: '부서·업무 검색', en: 'Search department or duty', zh: '搜索部门·业务', bn: 'বিভাগ বা কাজ অনুসন্ধান করুন');
  String get call => _t(ko: '전화', en: 'Call', zh: '拨打', bn: 'কল করুন');
  String get copy => _t(ko: '복사', en: 'Copy', zh: '复制', bn: 'কপি করুন');
  String get copied => _t(ko: '복사됨', en: 'Copied', zh: '已复制', bn: 'কপি হয়েছে');
  String get noPhone => _t(ko: '번호 미입력', en: 'No phone number', zh: '未输入号码', bn: 'ফোন নম্বর নেই');

  // 온라인 서비스
  String get onlineTitle => _t(ko: '교내 온라인 서비스', en: 'Online Services', zh: '校内在线服务', bn: 'অনলাইন সেবা');
  String get openLink => _t(ko: '열기', en: 'Open', zh: '打开', bn: 'খুলুন');
  String get courseReg => _t(ko: '수강신청', en: 'Course Registration', zh: '选课申请', bn: 'কোর্স নিবন্ধন');
  String get syllabus => _t(ko: '강의계획서', en: 'Syllabus', zh: '课程计划书', bn: 'সিলেবাস');
  String get elSystem => _t(ko: 'EL (e-Learning)', en: 'EL (e-Learning)', zh: 'EL（网络学习）', bn: 'EL (ই-লার্নিং)');

  // AI 챗봇
  String get assistantTitle => _t(ko: 'AI 도우미', en: 'AI Assistant', zh: 'AI助手', bn: 'AI সহকারী');
  String get assistantHint => _t(ko: '질문을 입력하세요', en: 'Type your question', zh: '请输入问题', bn: 'আপনার প্রশ্ন লিখুন');
  String get officialLabel => _t(ko: '공식 자료', en: 'Official', zh: '官方资料', bn: 'অফিসিয়াল');
  String get tipLabel => _t(ko: '재학생 팁', en: 'Student tip', zh: '在校生经验', bn: 'ছাত্র টিপস');
  String get helpful => _t(ko: '도움이 됐어요', en: 'Helpful', zh: '有帮助', bn: 'সহায়ক');
  String get askAgain => _t(ko: '다시 질문', en: 'Ask again', zh: '再次提问', bn: 'আবার জিজ্ঞেস করুন');
  String get aiVersionMismatch => _t(
    ko: '앱 데이터 버전이 맞지 않습니다. 앱을 업데이트해 주세요.',
    en: 'App data version does not match. Please update the app.',
    zh: '应用数据版本不一致，请更新应用。',
    bn: 'অ্যাপের ডেটা সংস্করণ মিলছে না। অনুগ্রহ করে অ্যাপ আপডেট করুন।',
  );
  String get aiRateLimited => _t(
    ko: '잠시 후 다시 질문해 주세요.',
    en: 'Please try asking again in a moment.',
    zh: '请稍后再提问。',
    bn: 'অনুগ্রহ করে কিছুক্ষণ পরে আবার জিজ্ঞেস করুন।',
  );
  String get aiTimeout => _t(
    ko: '응답 시간이 초과되었습니다. 다시 시도해 주세요.',
    en: 'The request timed out. Please try again.',
    zh: '请求超时，请重试。',
    bn: 'অনুরোধের সময় শেষ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
  );
  String demoAnswer(String serviceName, String location, String hours) => _t(
    ko: '[데모 응답] $serviceName 안내입니다.\n이용 장소: $location\n운영시간: $hours',
    en: '[Demo reply] Here is the guide for $serviceName.\nLocation: $location\nHours: $hours',
    zh: '[演示回复] 这是$serviceName的指南。\n使用地点：$location\n运营时间：$hours',
    bn: '[ডেমো উত্তর] $serviceName গাইড।\nঅবস্থান: $location\nসময়সূচি: $hours',
  );
  String get demoNoMatch => _t(
    ko: '[데모 응답] 질문에 맞는 서비스를 찾지 못했습니다.\n앱 내 안내를 확인하거나 관련 부서에 문의하세요.',
    en: '[Demo reply] No matching service was found.\nPlease check in-app guides or contact the relevant office.',
    zh: '[演示回复] 未找到相关服务。\n请查看应用内指南或联系相关部门。',
    bn: '[ডেমো উত্তর] মিল থাকা কোনো সেবা পাওয়া যায়নি।\nঅ্যাপ গাইড দেখুন বা সংশ্লিষ্ট অফিসে যোগাযোগ করুন।',
  );
  String aiRecommendedService(String serviceName) => _t(
    ko: '추천 서비스: $serviceName',
    en: 'Recommended service: $serviceName',
    zh: '推荐服务：$serviceName',
    bn: 'প্রস্তাবিত সেবা: $serviceName',
  );
  String get aiUnavailable => _t(
    ko: 'AI 서비스를 일시적으로 이용할 수 없습니다.\n앱 내 안내를 확인하거나 관련 부서에 문의하세요.',
    en: 'AI service is temporarily unavailable.\nPlease check in-app guides or contact the relevant office.',
    zh: 'AI服务暂时不可用。\n请查看应用内指南或联系相关部门。',
    bn: 'AI সেবা সাময়িকভাবে অনুপলব্ধ।\nঅ্যাপ গাইড দেখুন বা সংশ্লিষ্ট অফিসে যোগাযোগ করুন।',
  );

  // 설정
  String get settingsTitle => _t(ko: '설정', en: 'Settings', zh: '设置', bn: 'সেটিংস');
  String get languageSection => _t(ko: '언어', en: 'Language', zh: '语言', bn: 'ভাষা');
  String get dataVersion => _t(ko: '데이터 버전', en: 'Data version', zh: '数据版本', bn: 'ডেটা সংস্করণ');
  String get sourceInfo => _t(ko: '출처 정보', en: 'Source info', zh: '资料来源', bn: 'উৎস তথ্য');

  // 캠퍼스 지도 (보류)
  String get campusTitle => _t(ko: '캠퍼스 지도', en: 'Campus Map', zh: '校园地图', bn: 'ক্যাম্পাস মানচিত্র');
  String get mapComingSoon => _t(
    ko: '캠퍼스 지도는 준비 중입니다.',
    en: 'Campus map is coming soon.',
    zh: '校园地图正在准备中。',
    bn: 'ক্যাম্পাস মানচিত্র শীঘ্রই আসছে।',
  );
  String get locationUnavailable => _t(
    ko: '위치 정보 준비 중',
    en: 'Location info unavailable',
    zh: '位置信息准备中',
    bn: 'অবস্থানের তথ্য প্রস্তুত হচ্ছে',
  );
  String get urlPending => _t(ko: 'URL 준비 중', en: 'URL pending', zh: 'URL准备中', bn: 'URL অপেক্ষমাণ');
  String get cannotOpenLink => _t(
    ko: '링크를 열 수 없습니다.',
    en: 'Cannot open link.',
    zh: '无法打开链接。',
    bn: 'লিঙ্ক খোলা যাচ্ছে না।',
  );

  // 완료 화면 후속 확인사항
  String get followUpCheckDoc => _t(
    ko: '발급된 내용을 꼭 확인해 주세요.',
    en: 'Please check the issued document.',
    zh: '请务必确认发放的内容。',
    bn: 'ইস্যু করা নথি অবশ্যই পরীক্ষা করুন।',
  );
  String get followUpSavePrint => _t(
    ko: '필요한 경우, 저장하거나 출력할 수 있어요.',
    en: 'You can save or print it if needed.',
    zh: '如有需要，可以保存或打印。',
    bn: 'প্রয়োজনে সংরক্ষণ বা প্রিন্ট করতে পারবেন।',
  );

  // 언어 선택
  String get selectLanguage => _t(
    ko: '사용 언어를 선택하세요',
    en: 'Select your language',
    zh: '请选择使用语言',
    bn: 'আপনার ভাষা নির্বাচন করুন',
  );
  String get languageSelectDesc => _t(
    ko: '앱 메뉴와 안내문이 선택한 언어로 표시됩니다.\n설정에서 언제든지 변경할 수 있습니다.',
    en: 'Menus and guides will be shown in the selected language.\nYou can change this anytime in Settings.',
    zh: '应用菜单和指南将以所选语言显示。\n可以随时在设置中更改。',
    bn: 'মেনু এবং গাইড নির্বাচিত ভাষায় প্রদর্শিত হবে।\nসেটিংসে যেকোনো সময় পরিবর্তন করতে পারবেন।',
  );
  String get confirm => _t(ko: '확인', en: 'Confirm', zh: '确认', bn: 'নিশ্চিত করুন');
  String get complete => _t(ko: '완료', en: 'Done', zh: '完成', bn: 'সম্পন্ন');

  // 공통
  String get loading => _t(ko: '로딩 중...', en: 'Loading...', zh: '加载中...', bn: 'লোড হচ্ছে...');
  String get error => _t(ko: '오류가 발생했습니다', en: 'An error occurred', zh: '发生了错误', bn: 'একটি ত্রুটি হয়েছে');
  String get retry => _t(ko: '다시 시도', en: 'Retry', zh: '重试', bn: 'আবার চেষ্টা করুন');
  String get noData => _t(ko: '데이터가 없습니다', en: 'No data', zh: '暂无数据', bn: 'কোনো ডেটা নেই');
  String get close => _t(ko: '닫기', en: 'Close', zh: '关闭', bn: 'বন্ধ করুন');
  String get back => _t(ko: '뒤로', en: 'Back', zh: '返回', bn: 'পেছনে' );

  String _t({required String ko, required String en, required String zh, required String bn}) {
    switch (locale) {
      case 'ko': return ko;
      case 'en': return en;
      case 'zh': return zh;
      case 'bn': return bn;
      default: return en;
    }
  }
}
