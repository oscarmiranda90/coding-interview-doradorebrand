import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Dark info panel showing rate, receives, and estimated time.
/// Accepts pre-formatted strings so it stays purely presentational.
class RateInfoPanel extends StatelessWidget {
  const RateInfoPanel({
    super.key,
    required this.rateLabel,
    required this.receivesLabel,
    this.timeLabel = '~2 min',
  });

  final String rateLabel;
  final String receivesLabel;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoRow(label: 'TASA ESTIMADA', value: rateLabel, isLast: false),
          const SizedBox(height: 10),
          _InfoRow(label: 'RECIBIRÁS', value: receivesLabel, isLast: false),
          const SizedBox(height: 10),
          _InfoRow(label: 'TIEMPO ESTIMADO', value: timeLabel, isLast: true),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.isLast,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.monoCaption(
            fontSize: 10,
            color: AppColors.offWhite,
            opacity: 0.45,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.monoValue(
              fontSize: 13,
              color: AppColors.offWhite,
            ),
          ),
        ),
      ],
    );
  }
}
