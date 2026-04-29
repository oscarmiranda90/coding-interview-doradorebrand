import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Screen header: neobrutalist logo square, centered title, avatar circle.
class SwapHeader extends StatelessWidget {
  const SwapHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo square
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              border: Border.all(color: AppColors.black, width: 2.5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow.withAlpha(128),
                  offset: const Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(Icons.grid_on, color: AppColors.black, size: 22),
          ),
          // Title
          Text(
            'INTERCAMBIO',
            style: AppTextStyles.monoCaption(
              fontSize: 13,
              color: AppColors.offWhite,
              opacity: 0.7,
              letterSpacing: 2.0,
            ),
          ),
          // Avatar circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.offWhite.withAlpha(50),
                width: 2.5,
              ),
              color: AppColors.offWhite.withAlpha(15),
            ),
            child: Icon(
              Icons.person_outline,
              color: AppColors.offWhite.withAlpha(178),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
