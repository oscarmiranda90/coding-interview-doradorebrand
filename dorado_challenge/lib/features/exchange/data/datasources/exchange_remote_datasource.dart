import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/models/currency.dart';
import '../models/exchange_rate_model.dart';

abstract class ExchangeRemoteDatasource {
  Future<ExchangeRateModel> fetchExchangeRate({
    required Currency cryptoCurrency,
    required Currency fiatCurrency,
    required double amount,
    required String amountCurrencyId,
    required int type,
  });
}

class ExchangeRemoteDatasourceImpl implements ExchangeRemoteDatasource {
  const ExchangeRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ExchangeRateModel> fetchExchangeRate({
    required Currency cryptoCurrency,
    required Currency fiatCurrency,
    required double amount,
    required String amountCurrencyId,
    required int type,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.recommendationsEndpoint,
        queryParameters: {
          'type': type,
          'cryptoCurrencyId': cryptoCurrency.id,
          'fiatCurrencyId': fiatCurrency.id,
          'amount': amount,
          'amountCurrencyId': amountCurrencyId,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('[Datasource] raw response: ${response.data}');
        return ExchangeRateModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw ServerException(
        'Unexpected status code: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          e.message ?? 'Network error — check your connection.',
        );
      }
      throw ServerException(
        e.message ?? 'Server error.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
