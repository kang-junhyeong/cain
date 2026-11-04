import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/models/service.dart';
import '../../core/repositories/service_repository.dart';

class CompletionScreen extends StatefulWidget {
  final String serviceId;

  const CompletionScreen({super.key, required this.serviceId});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  final _repo = ServiceRepository();
  ServiceModel? _service;

  @override
  void initState() {
    super.initState();
    _repo.getById(widget.serviceId).then((s) => setState(() => _service = s));
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final strings = AppStrings(locale);
    final s = _service;

    return Scaffold(
      appBar: AppBar(title: Text(strings.complete)),
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 완료 아이콘
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, size: 72, color: AppTheme.success),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    strings.completionTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    s != null
                        ? strings.completionMessage(s.title.resolve(locale))
                        : strings.completionTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 완료 단계 카드
                  if (s != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_box, color: AppTheme.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                strings.complete,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${s.steps.length} / ${s.steps.length}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(height: 1, color: AppTheme.divider),
                          const SizedBox(height: 14),

                          // 후속 확인사항
                          Text(
                            strings.followUpTitle,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          // 서비스 ID로 비교 (언어 무관하게 안정적)
                          _FollowUpItem(text: strings.followUpCheckDoc),
                          const SizedBox(height: 4),
                          _FollowUpItem(text: strings.followUpSavePrint),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // 하단 버튼
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _goHome(context),
              icon: const Icon(Icons.home, size: 18),
              label: Text(strings.goHome),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _viewAgain(context),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(strings.viewAgain),
            ),
          ],
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
  }

  void _viewAgain(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.guideStep,
      (r) => r.settings.name == AppRoutes.home,
      arguments: {'serviceId': widget.serviceId, 'stepIndex': 0},
    );
  }
}

// _FollowUpItem은 이미 번역된 문자열을 text로 받는다.
// 하드코딩된 한글을 직접 넘기지 말고 반드시 AppStrings를 통해 전달할 것.
class _FollowUpItem extends StatelessWidget {
  final String text;
  const _FollowUpItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
        ),
      ],
    );
  }
}
