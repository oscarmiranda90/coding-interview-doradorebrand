import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/exchange_direction.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/currency.dart';
import '../providers/exchange_provider.dart';
import '../providers/exchange_state.dart';
import '../providers/swap_log_provider.dart';
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
  // true while the user tapped CAMBIAR and we're showing the success flash
  bool _showSuccess = false;
  // true while the debounce/API is running from typing (not from tapping CAMBIAR)
  bool _isSilentLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ExchangeState>(exchangeProvider, (previous, next) {
      if (next is ExchangeLoading && _isSilentLoading) {
        // keep silent — triggered by typing, not by button tap
      }
      if (next is ExchangeData) {
        ref.read(swapLogProvider.notifier).add(next.exchangeRate);
        // Only flash success if the user explicitly tapped CAMBIAR
        if (!_isSilentLoading) {
          setState(() => _showSuccess = true);
          Future.delayed(const Duration(milliseconds: 2200), () {
            if (mounted) setState(() => _showSuccess = false);
          });
        }
        if (mounted) setState(() => _isSilentLoading = false);
      }
      if (next is ExchangeError || next is ExchangeInitial) {
        if (mounted) setState(() => _isSilentLoading = false);
      }
    });

    final exchangeState = ref.watch(exchangeProvider);
    final notifier = ref.read(exchangeProvider.notifier);
    final direction = ref.watch(exchangeDirectionProvider);
    final fiat = ref.watch(selectedFiatProvider);
    final crypto = ref.watch(selectedCryptoProvider);

    final isFiatToCrypto = direction == ExchangeDirection.fiatToCrypto;
    final fromCurrency = isFiatToCrypto ? fiat : crypto;
    final toCurrency = isFiatToCrypto ? crypto : fiat;
    final fromOptions = isFiatToCrypto
        ? Currency.fiatCurrencies
        : Currency.cryptoCurrencies;
    final toOptions = isFiatToCrypto
        ? Currency.cryptoCurrencies
        : Currency.fiatCurrencies;

    final isLoading = exchangeState is ExchangeLoading;
    final rateStr = _rateStr(exchangeState, crypto, fiat);
    final receivesStr = _receivesStr(exchangeState, toCurrency, isFiatToCrypto);

    // Button: loading only when user tapped CAMBIAR, success after that resolves
    final NeoButtonState buttonState;
    if (exchangeState is ExchangeLoading && !_isSilentLoading) {
      buttonState = NeoButtonState.loading;
    } else if (_showSuccess) {
      buttonState = NeoButtonState.success;
    } else {
      buttonState = NeoButtonState.idle;
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
                              _CardHeaderBar(onLogTap: () => _showLogSheet(context)),
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
                                        onChanged: (v) {
                                          setState(() => _isSilentLoading = true);
                                          notifier.onAmountChanged(v);
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      RateInfoPanel(
                                        rateLabel: rateStr,
                                        receivesLabel: receivesStr,
                                        isLoading: isLoading,
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
                                    setState(() => _isSilentLoading = false);
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
                            color: AppColors.black,
                            opacity: 0.35,
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

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.black, width: 2.5),
      ),
      builder: (_) => Consumer(
        builder: (ctx, ref, __) =>
            _SwapLogSheet(entries: ref.watch(swapLogProvider)),
      ),
    );
  }

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
  const _CardHeaderBar({required this.onLogTap});
  final VoidCallback onLogTap;

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
            'SWAP',
            style: AppTextStyles.monoCaption(
              fontSize: 11,
              color: AppColors.black,
              opacity: 1.0,
              letterSpacing: 1.2,
            ),
          ),
          GestureDetector(
            onTap: onLogTap,
            child: Row(
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
          ),
        ],
      ),
    );
  }
}

class _SwapLogSheet extends StatelessWidget {
  const _SwapLogSheet({required this.entries});
  final List<SwapLogEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'SWAP LOG',
                style: AppTextStyles.monoCaption(
                  fontSize: 13,
                  color: AppColors.black,
                  opacity: 1.0,
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              Text(
                '${entries.length} CONSULTA${entries.length == 1 ? '' : 'S'}',
                style: AppTextStyles.monoCaption(
                  fontSize: 10,
                  color: AppColors.black,
                  opacity: 0.4,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.black, thickness: 2),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No swaps yet.',
                  style: AppTextStyles.monoCaption(
                    fontSize: 12,
                    color: AppColors.black,
                    opacity: 0.4,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(
                  color: AppColors.black,
                  thickness: 1,
                  height: 1,
                ),
                itemBuilder: (_, i) => _LogEntryTile(entry: entries[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry});
  final SwapLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final rate = entry.exchangeRate;
    final t = entry.timestamp;
    final timeStr =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
    final decimals =
        rate.toCurrency.type == CurrencyType.crypto ? 6 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${rate.inputAmount.toStringAsFixed(2)} ${rate.fromCurrency.symbol} → ${rate.outputAmount.toStringAsFixed(decimals)} ${rate.toCurrency.symbol}',
                style: AppTextStyles.monoCaption(
                  fontSize: 12,
                  color: AppColors.black,
                  opacity: 1.0,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'TASA ${rate.rate.toStringAsFixed(2)} ${rate.toCurrency.symbol}/${rate.fromCurrency.symbol}',
                style: AppTextStyles.monoCaption(
                  fontSize: 10,
                  color: AppColors.black,
                  opacity: 0.45,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          Text(
            timeStr,
            style: AppTextStyles.monoCaption(
              fontSize: 10,
              color: AppColors.black,
              opacity: 0.35,
              letterSpacing: 0.5,
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
      ..color = const Color(0xFF0A0A0A).withAlpha(12)
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
