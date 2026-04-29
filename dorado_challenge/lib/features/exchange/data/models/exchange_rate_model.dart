import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/models/currency.dart';
import '../../domain/entities/exchange_rate.dart';

class ExchangeRateModel {
  const ExchangeRateModel({required this.fiatToCryptoExchangeRate});

  final double fiatToCryptoExchangeRate;

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data == null) {
      throw const ServerException('Unexpected API response: missing "data".');
    }

    final byPrice = (data as Map<String, dynamic>)['byPrice'];
    if (byPrice == null) {
      // The API returns {data: {}} when no offer matches the amount.
      // This means the amount is below the minimum limit for this pair.
      throw const ServerException(
        'No offers available for this amount. Try a higher value.',
      );
    }

    final raw = (byPrice as Map<String, dynamic>)['fiatToCryptoExchangeRate'];
    if (raw == null) {
      throw const ServerException(
        'Unexpected API response: missing exchange rate.',
      );
    }

    final rate = raw is num ? raw.toDouble() : double.parse(raw.toString());
    return ExchangeRateModel(fiatToCryptoExchangeRate: rate);
  }

  ExchangeRate toEntity({
    required Currency fromCurrency,
    required Currency toCurrency,
    required double inputAmount,
    required int type,
  }) {
    final double outputAmount = type == AppConstants.typeFiatToCrypto
        ? inputAmount * fiatToCryptoExchangeRate
        : inputAmount / fiatToCryptoExchangeRate;

    return ExchangeRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      inputAmount: inputAmount,
      outputAmount: outputAmount,
      rate: fiatToCryptoExchangeRate,
    );
  }
}
