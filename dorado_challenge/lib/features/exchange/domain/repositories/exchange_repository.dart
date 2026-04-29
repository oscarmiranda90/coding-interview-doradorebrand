import '../../../../core/error/failures.dart';
import '../entities/exchange_direction.dart';
import '../entities/exchange_rate.dart';
import '../../../../shared/models/currency.dart';

abstract class ExchangeRepository {
  Future<({ExchangeRate? data, Failure? failure})> getExchangeRate({
    required Currency fromCurrency,
    required Currency toCurrency,
    required double amount,
    required ExchangeDirection direction,
  });
}
