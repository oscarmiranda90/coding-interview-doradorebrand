import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Neobrutalist amount input field.
/// Shows a Space Mono 22px input with the currency ID as a right suffix.
class NeoAmountInput extends StatelessWidget {
  const NeoAmountInput({
    super.key,
    required this.controller,
    required this.currencyId,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String currencyId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MONTO A ENVIAR',
          style: AppTextStyles.monoCaption(
            fontSize: 10,
            color: AppColors.black,
            opacity: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              style: AppTextStyles.monoAmount(
                fontSize: 22,
                color: AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: AppTextStyles.monoAmount(
                  fontSize: 22,
                  color: AppColors.black,
                ).copyWith(color: AppColors.black.withAlpha(76)),
                contentPadding: const EdgeInsets.fromLTRB(16, 14, 72, 14),
                filled: true,
                fillColor: AppColors.inputBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.black,
                    width: 2.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.black,
                    width: 2.5,
                  ),
                ),
              ),
              onChanged: onChanged,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Text(
                currencyId,
                style: GoogleFonts.spaceMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black.withAlpha(127),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
