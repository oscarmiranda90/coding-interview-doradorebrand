import '../../domain/entities/exchange_rate.dart';

sealed class ExchangeState {
  const ExchangeState();
}

final class ExchangeInitial extends ExchangeState {
  const ExchangeInitial();
}

final class ExchangeLoading extends ExchangeState {
  const ExchangeLoading();
}

final class ExchangeData extends ExchangeState {
  const ExchangeData(this.exchangeRate);
  final ExchangeRate exchangeRate;
}

final class ExchangeError extends ExchangeState {
  const ExchangeError(this.message);
  final String message;
}
