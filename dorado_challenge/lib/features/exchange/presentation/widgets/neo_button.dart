import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum NeoButtonState { idle, loading, success }

/// Full-width CTA button designed to sit at the bottom of a [NeoCard].
/// The top border and color transitions between idle / loading / success states.
class NeoButton extends StatelessWidget {
  const NeoButton({
    super.key,
    required this.label,
    this.onTap,
    this.state = NeoButtonState.idle,
  });

  final String label;
  final VoidCallback? onTap;
  final NeoButtonState state;

  @override
  Widget build(BuildContext context) {
    final Color bg = switch (state) {
      NeoButtonState.idle => AppColors.yellow,
      NeoButtonState.loading => AppColors.loadingGrey,
      NeoButtonState.success => AppColors.successGreen,
    };

    final Widget content = switch (state) {
      NeoButtonState.idle => Text(
        label,
        style: AppTextStyles.monoCaption(
          fontSize: 15,
          color: AppColors.black,
          opacity: 1.0,
          letterSpacing: 1.5,
        ),
      ),
      NeoButtonState.loading => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.offWhite),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'PROCESANDO...',
            style: AppTextStyles.monoCaption(
              fontSize: 15,
              color: AppColors.offWhite,
              opacity: 1.0,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      NeoButtonState.success => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: AppColors.offWhite, size: 20),
          const SizedBox(width: 8),
          Text(
            'CONFIRMADO',
            style: AppTextStyles.monoCaption(
              fontSize: 15,
              color: AppColors.offWhite,
              opacity: 1.0,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    };

    return GestureDetector(
      onTap: state == NeoButtonState.idle ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          border: const Border(
            top: BorderSide(color: AppColors.black, width: 3),
          ),
        ),
        child: Center(child: content),
      ),
    );
  }
}
