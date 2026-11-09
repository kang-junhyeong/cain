import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../app_strings.dart';
import '../models/building.dart';
import '../models/service.dart';
import '../repositories/building_repository.dart';
import '../viewmodels/locale_provider.dart';
import '../widgets/step_route_map.dart';

/// 서비스의 건물 위치를 지도로 연다.
/// 건물 정보나 좌표가 없으면 안내 문구만 띄운다.
Future<void> openServiceLocation(BuildContext context, ServiceModel service) async {
  final locale = context.read<LocaleProvider>().locale;
  final strings = AppStrings(locale);
  final buildingId = service.buildingId;

  Building? building;
  if (buildingId != null) {
    try {
      building = await context.read<BuildingRepository>().getById(buildingId);
    } catch (e) {
      debugPrint('[openServiceLocation] 건물 정보 로드 실패: $e');
    }
  }
  if (!context.mounted) return;

  if (building == null || !building.hasCoordinates) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.locationUnavailable)),
    );
    return;
  }

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BuildingLocationScreen(
        building: building!,
        locationText: service.location.resolve(locale),
      ),
    ),
  );
}

class BuildingLocationScreen extends StatelessWidget {
  final Building building;

  /// 서비스에 적힌 상세 위치 (예: 학생회관 2층 무인발급기)
  final String? locationText;

  const BuildingLocationScreen({super.key, required this.building, this.locationText});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final strings = AppStrings(locale);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(strings.checkLocation)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              building.name.resolve(locale),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            if (locationText != null && locationText!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      locationText!,
                      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            StepRouteMap(building: building, locale: locale),
          ],
        ),
      ),
    );
  }
}
