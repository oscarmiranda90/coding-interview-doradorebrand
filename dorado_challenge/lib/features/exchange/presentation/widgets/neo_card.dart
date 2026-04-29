import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Generic neobrutalist card.
/// Provides a white card with thick black border and hard offset shadow.
/// Pass [footer] for a full-width bottom section (e.g. CTA button)
/// that is clipped to the card's border radius.
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.shadowColor = AppColors.yellow,
    this.borderColor = AppColors.black,
    this.borderRadius = 20.0,
  });

  final Widget child;
  final Color shadowColor;
  final Color borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        // Slightly tighter radius so content sits inside the border
        borderRadius: BorderRadius.circular(borderRadius - 3),
        child: child,
      ),
    );
  }
}
