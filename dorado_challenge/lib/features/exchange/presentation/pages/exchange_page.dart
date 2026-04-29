import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/currency.dart';
import '../providers/exchange_provider.dart';
import '../providers/exchange_state.dart';
import '../widgets/currency_bar.dart';
import '../widgets/neo_amount_input.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../widgets/rate_info_panel.dart';
import '../widgets/swap_header.dart';

class ExchangePage extends ConsumerStatefulWidget {
  const ExchangePage({super.key});

  @override
  ConsumerState<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends ConsumerState<ExchangePage> {
  final _amountController = TextEditingController();
  bool _showSuccess = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Trigger success flash when new data arrives
    ref.listen<ExchangeState>(exchangeProvider, (previous, next) {
      if (next is ExchangeData && previous is! ExchangeData) {
        setState(() => _showSuccess = true);
        Future.delayed(const Duration(milliseconds: 2200), () {
          if (mounted) setState(() => _showSuccess = false);
        });
      }
    });

    final exchangeState = ref.watch(exchangeProvider);
    final notifier = ref.read(exchangeProvider.notifier);
    final direction = ref.watch(exchangeDirectionProvider);
    final fiat = ref.watch(selectedFiatProvider);
    final crypto = ref.watch(selectedCryptoProvider);

    final isFiatToCrypto = direction == AppConstants.typeFiatToCrypto;
    final fromCurrency = isFiatToCrypto ? fiat : crypto;
    final toCurrency = isFiatToCrypto ? crypto : fiat;
    final fromOptions = isFiatToCrypto
        ? Currency.fiatCurrencies
        : Currency.cryptoCurrencies;
    final toOptions = isFiatToCrypto
        ? Currency.cryptoCurrencies
        : Currency.fiatCurrencies;

    // Derived display strings for the info panel
    final rateStr = _rateStr(exchangeState, crypto, fiat);
    final receivesStr = _receivesStr(exchangeState, toCurrency, isFiatToCrypto);

    // Button state
    final NeoButtonState buttonState;
    if (exchangeState is ExchangeLoading) {
      buttonState = NeoButtonState.loading;
    } else if (_showSuccess) {
      buttonState = NeoButtonState.success;
    } else {
      buttonState = NeoButtonState.idle;
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Grid texture overlay
          const Positioned.fill(child: _GridTexture()),
          // Main content
          SafeArea(
            child: Column(
              children: [
                const SwapHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 22, 32),
                    child: Column(
                      children: [
                        // Main swap card
                        NeoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Yellow card header bar
                              _CardHeaderBar(),
                              // Card content
                              ColoredBox(
                                color: AppColors.offWhite,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    20,
                                    20,
                                    20,
                                  ),
                                  child: Column(
                                    children: [
                                      CurrencyBar(
                                        fromCurrency: fromCurrency,
                                        toCurrency: toCurrency,
                                        fromOptions: fromOptions,
                                        toOptions: toOptions,
                                        onFromChanged: (c) {
                                          if (isFiatToCrypto) {
                                            ref
                                                    .read(
                                                      selectedFiatProvider
                                                          .notifier,
                                                    )
                                                    .state =
                                                c;
                                          } else {
                                            ref
                                                    .read(
                                                      selectedCryptoProvider
                                                          .notifier,
                                                    )
                                                    .state =
                                                c;
                                          }
                                          notifier.onCurrencyChanged();
                                        },
                                        onToChanged: (c) {
                                          if (isFiatToCrypto) {
                                            ref
                                                    .read(
                                                      selectedCryptoProvider
                                                          .notifier,
                                                    )
                                                    .state =
                                                c;
                                          } else {
                                            ref
                                                    .read(
                                                      selectedFiatProvider
                                                          .notifier,
                                                    )
                                                    .state =
                                                c;
                                          }
                                          notifier.onCurrencyChanged();
                                        },
                                        onSwap: notifier.swap,
                                      ),
                                      const SizedBox(height: 20),
                                      NeoAmountInput(
                                        controller: _amountController,
                                        currencyId: fromCurrency.displayId,
                                        onChanged: notifier.onAmountChanged,
                                      ),
                                      const SizedBox(height: 20),
                                      RateInfoPanel(
                                        rateLabel: rateStr,
                                        receivesLabel: receivesStr,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // CTA button — bottom of card, clipped by NeoCard
                              NeoButton(
                                label: 'CAMBIAR →',
                                state: buttonState,
                                onTap: () {
                                  if (_amountController.text.isNotEmpty) {
                                    notifier.onAmountChanged(
                                      _amountController.text,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'COMISIÓN 0.5% · RED SEGURA',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.monoCaption(
                            fontSize: 10,
                            color: AppColors.offWhite,
                            opacity: 0.3,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _rateStr(ExchangeState state, Currency crypto, Currency fiat) =>
      switch (state) {
        ExchangeInitial() => '—',
        ExchangeLoading() => 'BUSCANDO...',
        ExchangeData(:final exchangeRate) => () {
          final r = exchangeRate.rate;
          final formatted = r == r.truncateToDouble()
              ? r.toStringAsFixed(0)
              : r.toStringAsFixed(2);
          return '1 ${crypto.symbol} = $formatted ${fiat.symbol}';
        }(),
        ExchangeError(:final message) => message,
      };

  String _receivesStr(
    ExchangeState state,
    Currency toCurrency,
    bool isFiatToCrypto,
  ) => switch (state) {
    ExchangeData(:final exchangeRate) => () {
      final decimals = isFiatToCrypto ? 6 : 2;
      return '${exchangeRate.outputAmount.toStringAsFixed(decimals)} ${toCurrency.symbol}';
    }(),
    _ => '— ${toCurrency.symbol}',
  };
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _CardHeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.yellow,
        border: Border(bottom: BorderSide(color: AppColors.black, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'INTERCAMBIO CRIPTO',
            style: AppTextStyles.monoCaption(
              fontSize: 11,
              color: AppColors.black,
              opacity: 1.0,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: List.generate(
              3,
              (i) => Container(
                margin: const EdgeInsets.only(left: 4),
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridTexture extends StatelessWidget {
  const _GridTexture();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter(), child: const SizedBox.expand());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE9FF47).withAlpha(10)
      ..strokeWidth = 1;

    for (double y = 0; y <= size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x <= size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
