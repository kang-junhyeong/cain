import 'localized_text.dart';

class ServiceModel {
  final String id;
  final String categoryId;
  final LocalizedText title;
  final LocalizedText summary;
  final LocalizedText location;
  final LocalizedText hours;
  final LocalizedText requirements;
  final LocalizedText targetUsers;
  final String? buildingId;
  final List<String> contactIds;
  final String iconName;
  final String verificationStatus;
  final List<GuideStep> steps;

  const ServiceModel({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.summary,
    required this.location,
    required this.hours,
    required this.requirements,
    required this.targetUsers,
    this.buildingId,
    required this.contactIds,
    required this.iconName,
    required this.verificationStatus,
    required this.steps,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final stepList = (json['steps'] as List<dynamic>? ?? [])
        .map((s) => GuideStep.fromJson(s as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return ServiceModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      summary: LocalizedText.fromJson(json['summary'] as Map<String, dynamic>),
      location: LocalizedText.fromJson(json['location'] as Map<String, dynamic>),
      hours: LocalizedText.fromJson(json['hours'] as Map<String, dynamic>),
      requirements: LocalizedText.fromJson(json['requirements'] as Map<String, dynamic>),
      targetUsers: LocalizedText.fromJson(json['targetUsers'] as Map<String, dynamic>),
      buildingId: json['buildingId'] as String?,
      contactIds: (json['contactIds'] as List<dynamic>? ?? []).cast<String>(),
      iconName: json['iconName'] as String? ?? 'info',
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
      steps: stepList,
    );
  }

  bool get isVerified => verificationStatus == 'approved';
}

class GuideStep {
  final String id;
  final String serviceId;
  final int order;
  final LocalizedText title;
  final LocalizedText body;
  final LocalizedText? caution;
  final String? imagePath;

  const GuideStep({
    required this.id,
    required this.serviceId,
    required this.order,
    required this.title,
    required this.body,
    this.caution,
    this.imagePath,
  });

  factory GuideStep.fromJson(Map<String, dynamic> json) {
    return GuideStep(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      order: json['order'] as int,
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      body: LocalizedText.fromJson(json['body'] as Map<String, dynamic>),
      caution: json['caution'] != null
          ? LocalizedText.fromJson(json['caution'] as Map<String, dynamic>)
          : null,
      imagePath: json['imagePath'] as String?,
    );
  }
}
