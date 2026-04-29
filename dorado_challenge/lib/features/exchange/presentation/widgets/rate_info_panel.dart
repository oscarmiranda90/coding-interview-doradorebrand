import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RateInfoPanel extends StatelessWidget {
  const RateInfoPanel({
    super.key,
    required this.rateLabel,
    required this.receivesLabel,
    this.timeLabel = '~2 min',
    this.isLoading = false,
  });

  final String rateLabel;
  final String receivesLabel;
  final String timeLabel;
  final bool isLoading;

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
          _InfoRow(label: 'TASA ESTIMADA', value: rateLabel, isLoading: isLoading),
          const SizedBox(height: 10),
          _InfoRow(label: 'RECIBIRÁS', value: receivesLabel, isLoading: isLoading),
          const SizedBox(height: 10),
          _InfoRow(label: 'TIEMPO ESTIMADO', value: timeLabel, isLoading: false),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.isLoading,
  });

  final String label;
  final String value;
  final bool isLoading;

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
        isLoading
            ? _SkeletonBar(width: 90)
            : Flexible(
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

class _SkeletonBar extends StatefulWidget {
  const _SkeletonBar({required this.width});
  final double width;

  @override
  State<_SkeletonBar> createState() => _SkeletonBarState();
}

class _SkeletonBarState extends State<_SkeletonBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        // Shimmer sweep: the highlight travels from left to right
        final offset = _ctrl.value * 2 - 0.5;
        return Container(
          width: widget.width,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (offset - 0.4).clamp(0.0, 1.0),
                offset.clamp(0.0, 1.0),
                (offset + 0.4).clamp(0.0, 1.0),
              ],
              colors: const [
                Color(0x33FAFAF5), // offWhite dim
                AppColors.yellow,  // highlight peak
                Color(0x33FAFAF5), // offWhite dim
              ],
            ),
          ),
        );
      },
    );
  }
}
