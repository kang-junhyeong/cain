import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/models/building.dart';
import '../../core/models/service.dart';
import '../../core/repositories/building_repository.dart';
import '../../core/repositories/service_repository.dart';
import '../../shared/widgets/step_nav_button.dart';
import 'widgets/step_route_map.dart';

class GuideStepScreen extends StatefulWidget {
  final String serviceId;
  final int stepIndex;

  const GuideStepScreen(
      {super.key, required this.serviceId, required this.stepIndex});

  @override
  State<GuideStepScreen> createState() => _GuideStepScreenState();
}

class _GuideStepScreenState extends State<GuideStepScreen> {
  final _repo = ServiceRepository();
  final _buildingRepo = BuildingRepository();
  ServiceModel? _service;

  /// 단계에 연결된 건물 (buildingId → Building). 좌표가 있는 건물만 지도로 표시한다.
  final Map<String, Building> _buildings = {};
  bool _isLoading = true;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.stepIndex;
    _load();
  }

  Future<void> _load() async {
    _service = await _repo.getById(widget.serviceId);
    final buildingIds = {
      for (final step in _service?.steps ?? const <GuideStep>[])
        if (step.buildingId != null) step.buildingId!,
    };
    for (final id in buildingIds) {
      final building = await _buildingRepo.getById(id);
      if (building != null) _buildings[id] = building;
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final strings = AppStrings(locale);

    if (_isLoading) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()));
    }
    if (_service == null || _service!.steps.isEmpty) {
      return Scaffold(
          appBar: AppBar(), body: Center(child: Text(strings.noData)));
    }

    final steps = _service!.steps;
    final step = steps[_currentIndex];
    final total = steps.length;
    final isLast = _currentIndex == total - 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_service!.title.resolve(locale)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / total,
            backgroundColor: AppTheme.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 단계 진행 표시
                  Text(
                    strings.stepProgress(_currentIndex + 1, total),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.title.resolve(locale),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 이동 단계면 지도(건물 위치 + 도보 경로), 아니면 단계 이미지
                  if (_mapBuildingFor(step) case final building?)
                    StepRouteMap(
                      key: ValueKey('map_${step.id}'),
                      building: building,
                      locale: locale,
                    )
                  else
                    // 단계 이미지 (없으면 아이콘 placeholder)
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: step.imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(step.imagePath!,
                                  fit: BoxFit.cover),
                            )
                          : Center(
                              child: Icon(
                                _stepIcon(_currentIndex),
                                size: 64,
                                color: AppTheme.primary.withValues(alpha: 0.4),
                              ),
                            ),
                    ),

                  const SizedBox(height: 20),

                  // 본문 설명
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Text(
                      step.body.resolve(locale),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),

                  // 주의사항
                  if (step.caution != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber,
                              color: AppTheme.warning, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.caution,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.warning,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  step.caution!.resolve(locale),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textPrimary,
                                      height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // AI 질문 버튼
                  GestureDetector(
                    onTap: () => _openAssistant(context, step),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.smart_toy,
                                color: AppTheme.accent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(strings.askAI,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary)),
                                Text(strings.trackProgress,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 이전 / 다음 버튼
          StepNavButtons(
            hasPrev: _currentIndex > 0,
            hasNext: true,
            isLast: isLast,
            onPrev: _currentIndex > 0 ? _prevStep : null,
            onNext: isLast ? () => _complete(context) : _nextStep,
            prevLabel: strings.prevStep,
            nextLabel: strings.nextStep,
            completeLabel: strings.complete,
          ),
        ],
      ),
    );
  }

  /// 단계에 연결된 건물 중 좌표가 있는 건물. 없으면 null (지도 대신 이미지 표시)
  Building? _mapBuildingFor(GuideStep step) {
    final building = _buildings[step.buildingId];
    return (building != null && building.hasCoordinates) ? building : null;
  }

  void _prevStep() {
    setState(() => _currentIndex--);
  }

  void _nextStep() {
    setState(() => _currentIndex++);
  }

  void _complete(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.completion,
      arguments: {'serviceId': widget.serviceId},
    );
  }

  void _openAssistant(BuildContext context, GuideStep step) {
    Navigator.pushNamed(
      context,
      AppRoutes.assistant,
      arguments: {
        'serviceId': widget.serviceId,
        'stepId': step.id,
      },
    );
  }

  IconData _stepIcon(int index) {
    const icons = [
      Icons.directions_walk,
      Icons.touch_app,
      Icons.credit_card,
      Icons.download_done,
    ];
    return icons[index % icons.length];
  }
}
