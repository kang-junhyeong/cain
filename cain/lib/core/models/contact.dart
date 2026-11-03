import 'localized_text.dart';

class Contact {
  final String id;
  final LocalizedText department;
  final LocalizedText duty;
  final String phone;
  final String? buildingId;
  final String? officialUrl;

  const Contact({
    required this.id,
    required this.department,
    required this.duty,
    required this.phone,
    this.buildingId,
    this.officialUrl,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      department: LocalizedText.fromJson(json['department'] as Map<String, dynamic>),
      duty: LocalizedText.fromJson(json['duty'] as Map<String, dynamic>),
      phone: json['phone'] as String? ?? '',
      buildingId: json['buildingId'] as String?,
      officialUrl: json['officialUrl'] as String?,
    );
  }
}
