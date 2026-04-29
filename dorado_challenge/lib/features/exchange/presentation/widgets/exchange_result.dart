import 'package:flutter/material.dart';

import '../../../../shared/models/currency.dart';
import '../../domain/entities/exchange_rate.dart';

class ExchangeResult extends StatelessWidget {
  const ExchangeResult({super.key, required this.exchangeRate});

  final ExchangeRate exchangeRate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // fiatToCryptoExchangeRate is always "fiat per 1 crypto unit"
    // e.g. 3640 means 1 USDT = 3640 COP — regardless of swap direction.
    final Currency cryptoCurrency =
        exchangeRate.fromCurrency.type == CurrencyType.crypto
        ? exchangeRate.fromCurrency
        : exchangeRate.toCurrency;
    final Currency fiatCurrency =
        exchangeRate.fromCurrency.type == CurrencyType.fiat
        ? exchangeRate.fromCurrency
        : exchangeRate.toCurrency;

    // Format rate: trim trailing zeros but keep up to 2 decimal places
    final rateFormatted =
        exchangeRate.rate == exchangeRate.rate.truncateToDouble()
        ? exchangeRate.rate.toStringAsFixed(0)
        : exchangeRate.rate.toStringAsFixed(2);

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You receive', style: textTheme.labelMedium),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  exchangeRate.outputAmount.toStringAsFixed(6),
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  exchangeRate.toCurrency.symbol,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              '1 ${cryptoCurrency.symbol} = $rateFormatted ${fiatCurrency.symbol}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
