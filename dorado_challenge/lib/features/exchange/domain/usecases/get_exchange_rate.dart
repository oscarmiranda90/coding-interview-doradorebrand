import '../../../../core/error/failures.dart';
import '../../../../shared/models/currency.dart';
import '../entities/exchange_rate.dart';
import '../repositories/exchange_repository.dart';

class GetExchangeRateParams {
  const GetExchangeRateParams({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.type,
  });

  final Currency fromCurrency;
  final Currency toCurrency;
  final double amount;
  final int type;
}

class GetExchangeRate {
  const GetExchangeRate(this._repository);

  final ExchangeRepository _repository;

  Future<({ExchangeRate? data, Failure? failure})> call(
    GetExchangeRateParams params,
  ) {
    return _repository.getExchangeRate(
      fromCurrency: params.fromCurrency,
      toCurrency: params.toCurrency,
      amount: params.amount,
      type: params.type,
    );
  }
}
