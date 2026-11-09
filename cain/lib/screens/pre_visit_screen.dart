import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../app_strings.dart';
import '../viewmodels/locale_provider.dart';
import '../models/service.dart';
import '../repositories/service_repository.dart';
import 'building_location_screen.dart';
import 'guide_step_screen.dart';

class PreVisitScreen extends StatefulWidget {
  final String serviceId;

  const PreVisitScreen({super.key, required this.serviceId});

  @override
  State<PreVisitScreen> createState() => _PreVisitScreenState();
}

class _PreVisitScreenState extends State<PreVisitScreen> {
  ServiceModel? _service;
  bool _isLoading = true;
  bool _hasError = false;
  final Map<int, bool> _checks = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final service = await context.read<ServiceRepository>().getById(widget.serviceId);
      if (!mounted) return;
      setState(() => _service = service);
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

    if (_isLoading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    if (_hasError) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(strings.error)));
    }
    if (_service == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(strings.noData)));
    }

    final s = _service!;
    final checklistItems = s.checklist.isNotEmpty ? s.checklist : [s.requirements];

    return Scaffold(
      appBar: AppBar(title: Text(strings.preVisitTitle)),
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 선택 서비스 표시
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description, color: AppTheme.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title.resolve(locale),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                s.location.resolve(locale),
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 운영시간
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: AppTheme.primary, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          s.hours.resolve(locale),
                          style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 체크리스트 제목
                  Text(
                    strings.checklist,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // 준비물 체크리스트
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      children: checklistItems.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        final checked = _checks[i] ?? false;
                        return Column(
                          children: [
                            CheckboxListTile(
                              value: checked,
                              onChanged: (v) => setState(() => _checks[i] = v ?? false),
                              title: Text(
                                item.resolve(locale),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: checked ? AppTheme.textSecondary : AppTheme.textPrimary,
                                  decoration: checked ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              activeColor: AppTheme.primary,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            ),
                            if (i < checklistItems.length - 1)
                              const Divider(height: 1, color: AppTheme.divider, indent: 16, endIndent: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  // 절차 (단계 이름 목록)
                  if (s.steps.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      strings.procedure,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        children: s.steps.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value.title.resolve(locale),
                                    style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 방문 전 안내사항
                  Text(
                    strings.preVisitNotes,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppTheme.warning, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              s.requirements.resolve(locale),
                              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => openServiceLocation(context, s),
                    icon: const Icon(Icons.location_on, size: 18),
                    label: Text(strings.checkLocation),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _goToSteps(s),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(strings.startProcedure),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToSteps(ServiceModel s) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => GuideStepScreen(serviceId: s.id, stepIndex: 0)),
    );
    if (!mounted) return;
    if (result == 'home') Navigator.pop(context, 'home');
  }
}
