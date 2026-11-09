import 'localized_text.dart';

class Building {
  final String id;
  final LocalizedText name;
  final double? latitude;
  final double? longitude;
  final String? imagePath;

  const Building({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.imagePath,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String,
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imagePath: json['imagePath'] as String?,
    );
  }

  bool get hasCoordinates => latitude != null && longitude != null;
}
