import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/border_beam.dart';
import '../../../../shared/models/currency.dart';

/// Neobrutalist unified currency selection bar.
///
/// Shows a "TENGO | [swap] | QUIERO" layout.
/// The circular swap button overflows the bar vertically by design.
/// Tapping a side with >1 option opens a modal bottom sheet picker.
class CurrencyBar extends StatefulWidget {
  const CurrencyBar({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromOptions,
    required this.toOptions,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onSwap,
  });

  final Currency fromCurrency;
  final Currency toCurrency;
  final List<Currency> fromOptions;
  final List<Currency> toOptions;
  final ValueChanged<Currency> onFromChanged;
  final ValueChanged<Currency> onToChanged;
  final VoidCallback onSwap;

  @override
  State<CurrencyBar> createState() => _CurrencyBarState();
}

class _CurrencyBarState extends State<CurrencyBar> {
  bool _swapping = false;

  void _triggerSwap() {
    setState(() => _swapping = true);
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _swapping = false);
    });
    widget.onSwap();
  }

  void _showPicker(
    BuildContext context,
    List<Currency> options,
    Currency current,
    ValueChanged<Currency> onChange,
  ) {
    if (options.length <= 1) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CurrencyPickerSheet(
        options: options,
        current: current,
        onSelect: (c) {
          onChange(c);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Labels row
        Row(
          children: [
            Expanded(
              child: Text(
                'TENGO',
                style: AppTextStyles.monoCaption(
                  fontSize: 10,
                  color: AppColors.black,
                  opacity: 0.5,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'QUIERO',
                textAlign: TextAlign.right,
                style: AppTextStyles.monoCaption(
                  fontSize: 10,
                  color: AppColors.black,
                  opacity: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Bar + overflowing swap button
        SizedBox(
          height: 56,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Bar (50px, centered in 56px stack → 3px breathing room each side)
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  border: Border.all(color: AppColors.black, width: 2.5),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.black,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // From side
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _showPicker(
                          context,
                          widget.fromOptions,
                          widget.fromCurrency,
                          widget.onFromChanged,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  widget.fromCurrency.assetPath,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.fromCurrency.displayId,
                                style: AppTextStyles.grotesk(
                                  fontSize: 18,
                                  weight: FontWeight.w800,
                                  color: AppColors.black,
                                ),
                              ),
                              if (widget.fromOptions.length > 1) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: AppColors.black,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Centre gap for the floating button
                    const SizedBox(width: 56),
                    // To side
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _showPicker(
                          context,
                          widget.toOptions,
                          widget.toCurrency,
                          widget.onToChanged,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.toOptions.length > 1) ...[
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: AppColors.black,
                                ),
                                const SizedBox(width: 4),
                              ],
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  widget.toCurrency.assetPath,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.toCurrency.displayId,
                                style: AppTextStyles.grotesk(
                                  fontSize: 18,
                                  weight: FontWeight.w800,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Circular swap button — centered, overflows bar top/bottom
              AnimatedRotation(
                turns: _swapping ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: GestureDetector(
                  onTap: _triggerSwap,
                  child: BorderBeam(
                    borderRadius: 26,
                    strokeWidth: 2.0,
                    beamFraction: 0.35,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.black,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.yellow,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: AppColors.yellow,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Currency Picker Bottom Sheet
// ---------------------------------------------------------------------------

class _CurrencyPickerSheet extends StatelessWidget {
  const _CurrencyPickerSheet({
    required this.options,
    required this.current,
    required this.onSelect,
  });

  final List<Currency> options;
  final Currency current;
  final ValueChanged<Currency> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          border: Border.all(color: AppColors.black, width: 2.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.black,
              offset: Offset(5, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sheet title bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.yellow,
                  border: Border(
                    bottom: BorderSide(color: AppColors.black, width: 2.5),
                  ),
                ),
                child: Text(
                  'SELECCIONAR',
                  style: AppTextStyles.monoCaption(
                    fontSize: 11,
                    color: AppColors.black,
                    opacity: 1.0,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              // Options
              ...options.map(
                (c) => _PickerRow(
                  currency: c,
                  isSelected: c.id == current.id,
                  onTap: () => onSelect(c),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  final Currency currency;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isSelected ? AppColors.yellow : AppColors.offWhite,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Image.asset(
              currency.assetPath,
              width: 28,
              height: 28,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 28,
                height: 28,
                child: Icon(Icons.monetization_on, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                currency.displayId,
                style: AppTextStyles.grotesk(
                  fontSize: 15,
                  weight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
            ),
            Text(
              currency.name,
              style: AppTextStyles.grotesk(
                fontSize: 12,
                weight: FontWeight.w500,
                color: AppColors.black,
              ).copyWith(color: AppColors.black.withAlpha(120)),
            ),
          ],
        ),
      ),
    );
  }
}
