import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/models/service.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final String locale;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(locale);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.title.resolve(locale),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (service.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, size: 12, color: AppTheme.success),
                              const SizedBox(width: 3),
                              Text(
                                strings.verifiedBadge,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.summary.resolve(locale),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: AppTheme.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          service.location.resolve(locale),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final iconData = _iconFromName(service.iconName);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: AppTheme.primary, size: 24),
    );
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'school': return Icons.school;
      case 'grade': return Icons.grade;
      case 'workspace_premium': return Icons.workspace_premium;
      case 'restaurant': return Icons.restaurant;
      case 'laptop': return Icons.laptop;
      case 'description': return Icons.description;
      default: return Icons.info_outline;
    }
  }
}
