import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/currency.dart';
import '../../domain/entities/exchange_direction.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/exchange_repository.dart';
import '../datasources/exchange_remote_datasource.dart';

class ExchangeRepositoryImpl implements ExchangeRepository {
  const ExchangeRepositoryImpl(this._datasource);

  final ExchangeRemoteDatasource _datasource;

  @override
  Future<({ExchangeRate? data, Failure? failure})> getExchangeRate({
    required Currency fromCurrency,
    required Currency toCurrency,
    required double amount,
    required ExchangeDirection direction,
  }) async {
    // Resolve which is crypto and which is fiat regardless of direction
    final Currency cryptoCurrency = switch (direction) {
      ExchangeDirection.fiatToCrypto => toCurrency,
      ExchangeDirection.cryptoToFiat => fromCurrency,
    };
    final Currency fiatCurrency = switch (direction) {
      ExchangeDirection.fiatToCrypto => fromCurrency,
      ExchangeDirection.cryptoToFiat => toCurrency,
    };

    try {
      final model = await _datasource.fetchExchangeRate(
        cryptoCurrency: cryptoCurrency,
        fiatCurrency: fiatCurrency,
        amount: amount,
        amountCurrencyId: fromCurrency.id,
        direction: direction,
      );

      return (
        data: model.toEntity(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          inputAmount: amount,
          direction: direction,
        ),
        failure: null,
      );
    } on NetworkException catch (e) {
      debugPrint('[ExchangeRepository] NetworkException: ${e.message}');
      return (data: null, failure: NetworkFailure(e.message));
    } on ServerException catch (e) {
      debugPrint(
        '[ExchangeRepository] ServerException(${e.statusCode}): ${e.message}',
      );
      return (data: null, failure: ServerFailure(e.message));
    } catch (e, st) {
      debugPrint('[ExchangeRepository] Unexpected error: $e\n$st');
      return (data: null, failure: UnknownFailure(e.toString()));
    }
  }
}
