import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/routes.dart';
import 'core/locale/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeProvider = LocaleProvider();
  await localeProvider.load();
  final hasLocale = await localeProvider.hasStoredLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: CainApp(initialRoute: hasLocale ? AppRoutes.home : AppRoutes.languageSelect),
    ),
  );
}
