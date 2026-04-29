import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInput extends StatelessWidget {
  const AmountInput({
    super.key,
    required this.controller,
    required this.currencySymbol,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String currencySymbol;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
          ],
          decoration: InputDecoration(
            prefixText: '$currencySymbol ',
            hintText: '0.00',
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
