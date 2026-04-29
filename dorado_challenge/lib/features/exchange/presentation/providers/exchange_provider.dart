import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/currency.dart';
import '../../data/datasources/exchange_remote_datasource.dart';
import '../../data/repositories/exchange_repository_impl.dart';
import '../../domain/usecases/get_exchange_rate.dart';
import 'exchange_state.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

final _datasourceProvider = Provider<ExchangeRemoteDatasource>(
  (ref) => ExchangeRemoteDatasourceImpl(DioClient.instance),
);

final _repositoryProvider = Provider<ExchangeRepositoryImpl>(
  (ref) => ExchangeRepositoryImpl(ref.watch(_datasourceProvider)),
);

final _usecaseProvider = Provider<GetExchangeRate>(
  (ref) => GetExchangeRate(ref.watch(_repositoryProvider)),
);

// ---------------------------------------------------------------------------
// Form state providers (selected currencies + direction)
// ---------------------------------------------------------------------------

final selectedFiatProvider = StateProvider<Currency>(
  (ref) => Currency.fiatCurrencies.first,
);

final selectedCryptoProvider = StateProvider<Currency>(
  (ref) => Currency.cryptoCurrencies.first,
);

/// type: 0 = CRYPTO→FIAT  |  1 = FIAT→CRYPTO
final exchangeDirectionProvider = StateProvider<int>(
  (ref) => AppConstants.typeFiatToCrypto,
);

// ---------------------------------------------------------------------------
// Exchange notifier
// ---------------------------------------------------------------------------

final exchangeProvider = StateNotifierProvider<ExchangeNotifier, ExchangeState>(
  (ref) => ExchangeNotifier(ref.watch(_usecaseProvider), ref),
);

class ExchangeNotifier extends StateNotifier<ExchangeState> {
  ExchangeNotifier(this._usecase, this._ref) : super(const ExchangeInitial());

  final GetExchangeRate _usecase;
  final Ref _ref;
  Timer? _debounce;
  double _currentAmount = 0;

  void onAmountChanged(String rawValue) {
    final amount = double.tryParse(rawValue.replaceAll(',', '.')) ?? 0;
    _currentAmount = amount;

    _debounce?.cancel();

    if (amount <= 0) {
      state = const ExchangeInitial();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), _fetchRate);
  }

  void onCurrencyChanged() {
    _debounce?.cancel();
    if (_currentAmount > 0) {
      _debounce = Timer(const Duration(milliseconds: 300), _fetchRate);
    }
  }

  void swap() {
    final current = _ref.read(exchangeDirectionProvider);
    _ref
        .read(exchangeDirectionProvider.notifier)
        .state = current == AppConstants.typeFiatToCrypto
        ? AppConstants.typeCryptoToFiat
        : AppConstants.typeFiatToCrypto;
    if (_currentAmount > 0) _fetchRate();
  }

  Future<void> _fetchRate() async {
    final type = _ref.read(exchangeDirectionProvider);
    final fiat = _ref.read(selectedFiatProvider);
    final crypto = _ref.read(selectedCryptoProvider);

    final fromCurrency = type == AppConstants.typeFiatToCrypto ? fiat : crypto;
    final toCurrency = type == AppConstants.typeFiatToCrypto ? crypto : fiat;

    state = const ExchangeLoading();

    final result = await _usecase(
      GetExchangeRateParams(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: _currentAmount,
        type: type,
      ),
    );

    if (!mounted) return;

    if (result.failure != null) {
      state = ExchangeError(result.failure!.message);
    } else {
      state = ExchangeData(result.data!);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
