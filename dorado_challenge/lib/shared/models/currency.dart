enum CurrencyType { fiat, crypto }

class Currency {
  const Currency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.assetPath,
    this.label,
  });

  final String id;
  final String name;
  final String symbol;
  final CurrencyType type;
  final String assetPath;

  /// Optional short display label (overrides [id] in the UI).
  final String? label;

  /// The label shown in the UI — falls back to [id] when [label] is null.
  String get displayId => label ?? id;

  static const List<Currency> fiatCurrencies = [
    Currency(
      id: 'BRL',
      name: 'Brazilian Real',
      symbol: 'R\$',
      type: CurrencyType.fiat,
      assetPath: '../assets/fiat_currencies/BRL.png',
    ),
    Currency(
      id: 'COP',
      name: 'Colombian Peso',
      symbol: 'COP',
      type: CurrencyType.fiat,
      assetPath: '../assets/fiat_currencies/COP.png',
    ),
    Currency(
      id: 'PEN',
      name: 'Peruvian Sol',
      symbol: 'S/',
      type: CurrencyType.fiat,
      assetPath: '../assets/fiat_currencies/PEN.png',
    ),
    Currency(
      id: 'VES',
      name: 'Venezuelan Bolívar',
      symbol: 'Bs.',
      type: CurrencyType.fiat,
      assetPath: '../assets/fiat_currencies/VES.png',
    ),
  ];

  static const List<Currency> cryptoCurrencies = [
    Currency(
      id: 'TATUM-TRON-USDT',
      name: 'USDT (TRC-20)',
      symbol: 'USDT',
      type: CurrencyType.crypto,
      assetPath: '../assets/cripto_currencies/TATUM-TRON-USDT.png',
      label: 'USDT',
    ),
  ];
}
