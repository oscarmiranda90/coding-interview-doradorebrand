import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';


/// Screen header: neobrutalist logo square, centered title, avatar circle.
class SwapHeader extends StatelessWidget {
  const SwapHeader({super.key});

  void _showAboutModal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.yellow, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.yellow,
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  '../assets/logodorado.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'DISEÑADO POR',
                style: AppTextStyles.monoCaption(
                  fontSize: 10,
                  color: AppColors.offWhite,
                  opacity: 0.45,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'OSCAR CRESCENTE',
                style: AppTextStyles.monoCaption(
                  fontSize: 18,
                  color: AppColors.yellow,
                  opacity: 1.0,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PARA EL DORADO',
                style: AppTextStyles.monoCaption(
                  fontSize: 13,
                  color: AppColors.offWhite,
                  opacity: 0.8,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 1,
                color: AppColors.yellow.withAlpha(60),
              ),
              const SizedBox(height: 16),
              Text(
                'CHALLENGE DE RECRUITING',
                style: AppTextStyles.monoCaption(
                  fontSize: 9,
                  color: AppColors.offWhite,
                  opacity: 0.4,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '29 ABRIL 2026',
                style: AppTextStyles.monoCaption(
                  fontSize: 11,
                  color: AppColors.offWhite,
                  opacity: 0.65,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'www.crescente.dev',
                style: AppTextStyles.monoCaption(
                  fontSize: 12,
                  color: AppColors.yellow,
                  opacity: 1.0,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo square
          GestureDetector(
            onTap: () => _showAboutModal(context),
            child: Container(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  '../assets/logodorado.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Title
          Text(
            'INTERCAMBIO',
            style: AppTextStyles.monoCaption(
              fontSize: 13,
              color: AppColors.black,
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
                color: AppColors.black.withAlpha(50),
                width: 2.5,
              ),
              color: AppColors.black.withAlpha(10),
            ),
            child: Icon(
              Icons.person_outline,
              color: AppColors.black.withAlpha(178),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
