import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/models/currency.dart';
import '../../domain/entities/exchange_rate.dart';

const _kStorageKey = 'swap_log';

class SwapLogEntry {
  const SwapLogEntry({required this.exchangeRate, required this.timestamp});

  final ExchangeRate exchangeRate;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'fromCurrencyId': exchangeRate.fromCurrency.id,
    'toCurrencyId': exchangeRate.toCurrency.id,
    'inputAmount': exchangeRate.inputAmount,
    'outputAmount': exchangeRate.outputAmount,
    'rate': exchangeRate.rate,
  };

  static SwapLogEntry? fromJson(Map<String, dynamic> json) {
    try {
      final fromCurrency = _findCurrency(json['fromCurrencyId'] as String);
      final toCurrency = _findCurrency(json['toCurrencyId'] as String);
      if (fromCurrency == null || toCurrency == null) return null;
      return SwapLogEntry(
        timestamp: DateTime.parse(json['timestamp'] as String),
        exchangeRate: ExchangeRate(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          inputAmount: (json['inputAmount'] as num).toDouble(),
          outputAmount: (json['outputAmount'] as num).toDouble(),
          rate: (json['rate'] as num).toDouble(),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static Currency? _findCurrency(String id) {
    final all = [...Currency.fiatCurrencies, ...Currency.cryptoCurrencies];
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

class SwapLogNotifier extends StateNotifier<List<SwapLogEntry>> {
  SwapLogNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static List<SwapLogEntry> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_kStorageKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SwapLogEntry.fromJson(e as Map<String, dynamic>))
          .whereType<SwapLogEntry>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  void add(ExchangeRate rate) {
    final updated = [
      SwapLogEntry(exchangeRate: rate, timestamp: DateTime.now()),
      ...state,
    ];
    state = updated;
    _prefs.setString(
      _kStorageKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }
}

final sharedPrefsProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);

final swapLogProvider =
    StateNotifierProvider<SwapLogNotifier, List<SwapLogEntry>>((ref) {
  final prefs = ref.watch(sharedPrefsProvider).requireValue;
  return SwapLogNotifier(prefs);
});
