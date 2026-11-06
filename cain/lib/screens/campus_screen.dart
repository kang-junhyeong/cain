// TODO(지도 보류): 캠퍼스 지도 화면 — 구현 대기 중
//
// 재개 조건:
//   1. 지도 방식 결정 (Google Maps API 또는 WebView 네이버지도)
//   2. Google Maps 사용 시 pubspec.yaml에 google_maps_flutter 추가 및 API 키 설정
//   3. 한기대 주요 건물 위도·경도 데이터 수집 → buildings.json 업데이트
//   4. 층별 배치도 이미지 확보 → assets/maps/ 에 추가
//
// 구현 계획:
//   - 캠퍼스 전체 지도: BuildingMarker 클릭 → 건물 정보 바텀시트
//   - 층별 배치도: 이미지 + Stack 위 AbsolutePositioned 마커 (Room.x, Room.y 0~1 좌표)
//   - 도면 없는 건물: 공간 목록(ListView) 폴백
//   - 지도 없이 목록형 건물 표시는 아래 _CampusFallback 에 임시 구현

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../app_strings.dart';
import '../viewmodels/locale_provider.dart';
import '../models/building.dart';
import '../repositories/building_repository.dart';

class CampusScreen extends StatefulWidget {
  const CampusScreen({super.key});

  @override
  State<CampusScreen> createState() => _CampusScreenState();
}

class _CampusScreenState extends State<CampusScreen> {
  final _repo = BuildingRepository();
  List<Building> _buildings = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final buildings = await _repo.getAll();
      if (!mounted) return;
      setState(() => _buildings = buildings);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final strings = AppStrings(locale);

    return Scaffold(
      appBar: AppBar(title: Text(strings.campusTitle)),
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text(strings.error))
              : _CampusFallback(buildings: _buildings, locale: locale, strings: strings),
    );
  }
}

/// 지도 미구현 동안 표시되는 건물 목록 폴백
class _CampusFallback extends StatelessWidget {
  final List<Building> buildings;
  final String locale;
  final AppStrings strings;

  const _CampusFallback({required this.buildings, required this.locale, required this.strings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 보류 안내 배너
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.warning.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.construction, color: AppTheme.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  strings.mapComingSoon,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                ),
              ),
            ],
          ),
        ),

        // 건물 목록
        Expanded(
          child: buildings.isEmpty
              ? Center(child: Text(strings.noData))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: buildings.length,
                  itemBuilder: (ctx, i) {
                    final b = buildings[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.apartment, color: AppTheme.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.name.resolve(locale),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                if (!b.hasCoordinates)
                                  Text(strings.locationUnavailable,
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
