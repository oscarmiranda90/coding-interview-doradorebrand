abstract class AppConstants {
  static const String baseUrl =
      'https://74j6q7lg6a.execute-api.eu-west-1.amazonaws.com/stage';
  static const String recommendationsEndpoint =
      '/orderbook/public/recommendations';

  /// type=0 → CRYPTO to FIAT
  static const int typeCryptoToFiat = 0;

  /// type=1 → FIAT to CRYPTO
  static const int typeFiatToCrypto = 1;
}
