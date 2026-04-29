import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/exchange/presentation/pages/exchange_page.dart';

void main() {
  runApp(const ProviderScope(child: DoradoApp()));
}

class DoradoApp extends StatelessWidget {
  const DoradoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dorado Exchange',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const ExchangePage(),
    );
  }
}
