import '../../../../shared/models/currency.dart';

class ExchangeRate {
  const ExchangeRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.inputAmount,
    required this.outputAmount,
    required this.rate,
  });

  final Currency fromCurrency;
  final Currency toCurrency;
  final double inputAmount;
  final double outputAmount;
  final double rate;
}
