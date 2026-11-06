class LocalizedText {
  final String ko;
  final String en;
  final String? zh;
  final String? bn;

  const LocalizedText({
    required this.ko,
    required this.en,
    this.zh,
    this.bn,
  });

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      ko: json['ko'] as String? ?? '',
      en: json['en'] as String? ?? '',
      zh: json['zh'] as String?,
      bn: json['bn'] as String?,
    );
  }

  /// 선택한 언어로 텍스트를 반환한다.
  /// 해당 언어 번역이 없으면 영어(en), 그다음 한국어(ko)로 폴백한다.
  String resolve(String locale) {
    switch (locale) {
      case 'ko':
        return ko.isNotEmpty ? ko : en;
      case 'en':
        return en.isNotEmpty ? en : ko;
      case 'zh':
        if (zh != null && zh!.isNotEmpty) return zh!;
        return en.isNotEmpty ? en : ko;
      case 'bn':
        if (bn != null && bn!.isNotEmpty) return bn!;
        return en.isNotEmpty ? en : ko;
      default:
        return en.isNotEmpty ? en : ko;
    }
  }

  /// 번역이 없어 폴백 언어를 사용하고 있는지 여부
  bool isFallback(String locale) {
    switch (locale) {
      case 'zh':
        return zh == null || zh!.isEmpty;
      case 'bn':
        return bn == null || bn!.isEmpty;
      default:
        return false;
    }
  }
}
