import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../app_strings.dart';
import '../viewmodels/guide_view_model.dart';
import '../viewmodels/locale_provider.dart';
import '../models/service.dart';
import '../repositories/building_repository.dart';
import '../repositories/service_repository.dart';
import '../widgets/floor_plan_guide.dart';
import '../widgets/step_nav_button.dart';
import '../widgets/step_route_map.dart';
import 'assistant_screen.dart';
import 'completion_screen.dart';

// 단계별 시각 자료 연결 (모델 필드 추가 없이 단계 ID로 연결한다)

/// 건물까지 구글맵·도보 경로를 보여줄 단계 (서비스의 buildingId 좌표 사용)
const Set<String> _mapStepIds = {'step_enroll_01'};

/// 건물 안 배치도 길찾기를 보여줄 단계
const Map<String, _FloorPlanRoute> _floorPlanSteps = {
  'step_enroll_02': _FloorPlanRoute(
    // assets/map/진짜.png(학생회관 층별 안내)의 2F 부분을 잘라낸 이미지
    imagePath: 'assets/map/student_union_2f_guide.png',
    aspectRatio: 1400 / 760,
    floor: 2,
    // 배치도 이미지 기준 0~1 비율 좌표. 첫 점 = 현위치(2층 엘리베이터 앞 복도), 마지막 점 = 무인발급기
    // 시연용 임의 위치: 2층 가로 복도 오른쪽 끝. TODO(위치 확인): 실제 위치 확인 후 마지막 점 조정
    route: [
      Offset(0.44, 0.415),
      Offset(0.935, 0.415),
    ],
  ),
};

class _FloorPlanRoute {
  final String imagePath;
  final double aspectRatio;
  final int floor;
  final List<Offset> route;

  const _FloorPlanRoute({
    required this.imagePath,
    required this.aspectRatio,
    required this.floor,
    required this.route,
  });
}

class GuideStepScreen extends StatelessWidget {
  final String serviceId;
  final int stepIndex;

  const GuideStepScreen({super.key, required this.serviceId, required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GuideViewModel(
        repository: context.read<ServiceRepository>(),
        buildingRepository: context.read<BuildingRepository>(),
        serviceId: serviceId,
        stepIndex: stepIndex,
      )..load(),
      child: const _GuideStepView(),
    );
  }
}

class _GuideStepView extends StatefulWidget {
  const _GuideStepView();

  @override
  State<_GuideStepView> createState() => _GuideStepViewState();
}

class _GuideStepViewState extends State<_GuideStepView> {
  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final strings = AppStrings(locale);
    final vm = context.watch<GuideViewModel>();
    final service = vm.service;

    if (vm.isLoading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    if (vm.hasError) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(strings.error)));
    }
    if (service == null || service.steps.isEmpty) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(strings.noData)));
    }

    final steps = service.steps;
    final currentIndex = vm.currentIndex;
    final step = steps[currentIndex];
    final total = steps.length;
    final isLast = currentIndex == total - 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(service.title.resolve(locale)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / total,
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
                    strings.stepProgress(currentIndex + 1, total),
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

                  // 단계 시각 자료 (지도 / 배치도 / 이미지 / 아이콘 placeholder)
                  _buildStepVisual(step, vm, locale, currentIndex),

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
                        color: AppTheme.warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber, color: AppTheme.warning, size: 18),
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
                                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.5),
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
                    onTap: () => _openAssistant(step),
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
                              color: AppTheme.accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.smart_toy, color: AppTheme.accent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(strings.askAI,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                Text(strings.trackProgress,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
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
            hasPrev: currentIndex > 0,
            hasNext: true,
            isLast: isLast,
            onPrev: currentIndex > 0 ? vm.prev : null,
            onNext: isLast ? _complete : vm.next,
            prevLabel: strings.prevStep,
            nextLabel: strings.nextStep,
            completeLabel: strings.complete,
          ),
        ],
      ),
    );
  }

  // 완료 화면(S11)의 결과: 'again'이면 처음 단계로, 'home'이면 위로 전달한다.
  Future<void> _complete() async {
    final vm = context.read<GuideViewModel>();
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => CompletionScreen(serviceId: vm.serviceId)),
    );
    if (!mounted) return;
    if (result == 'again') {
      vm.restart();
    } else if (result == 'home') {
      Navigator.pop(context, 'home');
    }
  }

  // AI 화면(S09)에서 고른 추천 서비스를 돌려받는다. 단계 index는 그대로 유지된다.
  Future<void> _openAssistant(GuideStep step) async {
    final vm = context.read<GuideViewModel>();
    final id = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => AssistantScreen(serviceId: vm.serviceId, stepId: step.id),
      ),
    );
    if (!mounted || id == null) return;
    final locale = context.read<LocaleProvider>().locale;
    final title = await vm.serviceTitle(id, locale);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings(locale).aiRecommendedService(title ?? id))),
    );
  }

  Widget _buildStepVisual(GuideStep step, GuideViewModel vm, String locale, int index) {
    final building = vm.building;
    if (_mapStepIds.contains(step.id) && building != null && building.hasCoordinates) {
      return StepRouteMap(key: ValueKey(step.id), building: building, locale: locale);
    }

    final floorPlan = _floorPlanSteps[step.id];
    if (floorPlan != null) {
      return FloorPlanGuide(
        key: ValueKey(step.id),
        imagePath: floorPlan.imagePath,
        aspectRatio: floorPlan.aspectRatio,
        floorLabel: '${building?.name.resolve(locale) ?? ''} ${AppStrings(locale).floorLabel(floorPlan.floor)}'.trim(),
        route: floorPlan.route,
        locale: locale,
      );
    }

    if (step.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Image.asset(step.imagePath!, fit: BoxFit.cover),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(
          _stepIcon(index),
          size: 64,
          color: AppTheme.primary.withOpacity(0.4),
        ),
      ),
    );
  }

  IconData _stepIcon(int index) {
    const icons = [
      Icons.directions_walk,
      Icons.map_outlined,
      Icons.touch_app,
      Icons.download_done,
    ];
    return icons[index % icons.length];
  }
}
