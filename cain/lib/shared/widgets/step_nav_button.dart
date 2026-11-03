import 'package:flutter/material.dart';
import '../../app/theme.dart';

class StepNavButtons extends StatelessWidget {
  final bool hasPrev;
  final bool hasNext;
  final bool isLast;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final String prevLabel;
  final String nextLabel;
  final String completeLabel;

  const StepNavButtons({
    super.key,
    required this.hasPrev,
    required this.hasNext,
    required this.isLast,
    this.onPrev,
    this.onNext,
    required this.prevLabel,
    required this.nextLabel,
    required this.completeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (hasPrev) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onPrev,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                ),
                child: Text(prevLabel),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? AppTheme.success : AppTheme.primary,
                minimumSize: const Size(0, 52),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isLast ? completeLabel : nextLabel),
                  const SizedBox(width: 4),
                  Icon(
                    isLast ? Icons.check : Icons.arrow_forward,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
