import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../app_strings.dart';
import '../viewmodels/locale_provider.dart';
import '../models/service.dart';
import '../repositories/service_repository.dart';
import 'pre_visit_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  ServiceModel? _service;
  bool _isLoading = true;
  bool _hasError = false;

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

    return Scaffold(
      appBar: AppBar(title: Text(s.title.resolve(locale))),
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 배너
                  Container(
                    width: double.infinity,
                    height: 120,
                    color: AppTheme.primary.withOpacity(0.1),
                    child: Center(
                      child: Icon(_iconFromName(s.iconName), size: 48, color: AppTheme.primary),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목 + 검수 배지
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.title.resolve(locale),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                              ),
                            ),
                            if (s.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified, size: 14, color: AppTheme.success),
                                    const SizedBox(width: 4),
                                    Text(strings.verifiedBadge,
                                        style: const TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(s.summary.resolve(locale),
                            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),

                        const SizedBox(height: 20),
                        // 이용 안내 카드
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Column(
                            children: [
                              _InfoRow(icon: Icons.location_on, label: strings.locationLabel, value: s.location.resolve(locale)),
                              _divider(),
                              _InfoRow(icon: Icons.access_time, label: strings.hoursLabel, value: s.hours.resolve(locale)),
                              _divider(),
                              _InfoRow(icon: Icons.badge, label: strings.requirementsLabel, value: s.requirements.resolve(locale)),
                              _divider(),
                              _InfoRow(icon: Icons.people, label: strings.targetUsersLabel, value: s.targetUsers.resolve(locale)),
                            ],
                          ),
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
                    onPressed: () {
                      // TODO(지도 보류): 지도 화면 연결
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.mapComingSoon)),
                      );
                    },
                    icon: const Icon(Icons.location_on, size: 18),
                    label: Text(strings.checkLocation),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: s.steps.isEmpty ? null : () => _goToPreVisit(s),
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

  Future<void> _goToPreVisit(ServiceModel s) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => PreVisitScreen(serviceId: s.id)),
    );
    if (!mounted) return;
    if (result == 'home') Navigator.pop(context, 'home');
  }

  Widget _divider() => const Divider(height: 1, color: AppTheme.divider, indent: 16, endIndent: 16);

  IconData _iconFromName(String name) {
    switch (name) {
      case 'school': return Icons.school;
      case 'grade': return Icons.grade;
      case 'workspace_premium': return Icons.workspace_premium;
      case 'restaurant': return Icons.restaurant;
      case 'laptop': return Icons.laptop;
      default: return Icons.description;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
