import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StockBookApp());
}

class StockBookApp extends StatelessWidget {
  const StockBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'የእቃ መዝገብ',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        
        // Add localization support for Amharic
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('am', 'ET'), // Amharic, Ethiopia
          Locale('en', 'US'), // English, US
        ],
        // Set Amharic as the default locale
        locale: const Locale('am', 'ET'),

        home: const HomeScreen(),
      ),
    );
  }
}
