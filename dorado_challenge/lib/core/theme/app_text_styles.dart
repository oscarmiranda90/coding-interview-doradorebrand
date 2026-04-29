import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  /// Space Mono — uppercase labels / captions
  static TextStyle monoCaption({
    double fontSize = 10,
    Color color = AppColors.black,
    double opacity = 0.5,
    double letterSpacing = 1.2,
  }) => GoogleFonts.spaceMono(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: color.withAlpha((opacity * 255).round()),
    letterSpacing: letterSpacing,
  );

  /// Space Mono — data values (rates, amounts in info panel)
  static TextStyle monoValue({
    double fontSize = 13,
    Color color = AppColors.offWhite,
  }) => GoogleFonts.spaceMono(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: 0.2,
  );

  /// Space Mono — large amount input
  static TextStyle monoAmount({
    double fontSize = 22,
    Color color = AppColors.black,
  }) => GoogleFonts.spaceMono(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: color,
  );

  /// Space Grotesk — display / currency names / UI labels
  static TextStyle grotesk({
    double fontSize = 15,
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.black,
    double letterSpacing = 0.0,
  }) => GoogleFonts.spaceGrotesk(
    fontSize: fontSize,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
  );
}
