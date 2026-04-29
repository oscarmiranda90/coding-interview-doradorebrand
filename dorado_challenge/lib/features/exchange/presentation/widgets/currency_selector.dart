import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/currency.dart';

class CurrencySelector extends ConsumerWidget {
  const CurrencySelector({
    super.key,
    required this.currencies,
    required this.selectedProvider,
    required this.label,
    required this.onChanged,
  });

  final List<Currency> currencies;
  final StateProvider<Currency> selectedProvider;
  final String label;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        DropdownButtonFormField<Currency>(
          value: selected,
          decoration: const InputDecoration(),
          items: currencies.map((currency) {
            return DropdownMenuItem(
              value: currency,
              child: Row(
                children: [
                  Image.asset(
                    currency.assetPath,
                    width: 24,
                    height: 24,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.monetization_on, size: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(currency.id),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            ref.read(selectedProvider.notifier).state = value;
            onChanged();
          },
        ),
      ],
    );
  }
}
