enum ExchangeDirection {
  /// type=0 in the API: the user sends crypto and receives fiat.
  cryptoToFiat,

  /// type=1 in the API: the user sends fiat and receives crypto.
  fiatToCrypto;

  int get apiType => switch (this) {
    ExchangeDirection.cryptoToFiat => 0,
    ExchangeDirection.fiatToCrypto => 1,
  };
}
