import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/language_provider.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StockBookApp());
}

class StockBookApp extends StatelessWidget {
  const StockBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, lang, _) {
          return MaterialApp(
            title: lang.isAmharic ? 'ግሮሰሪ' : 'Grocery',
            theme: AppTheme.theme,
            debugShowCheckedModeBanner: false,
            locale: lang.isAmharic
                ? const Locale('am', 'ET')
                : const Locale('en', 'US'),
            supportedLocales: const [
              Locale('am', 'ET'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
