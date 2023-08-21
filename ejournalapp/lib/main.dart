import 'package:ejournalapp/pages/HomePage.dart';
import 'package:ejournalapp/pages/regPage.dart';
import 'package:ejournalapp/pages/startPage.dart';
import 'package:flutter/material.dart';
/*import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';*/
import 'package:flutter_localizations/flutter_localizations.dart';
void main() {
  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => StartPage(),
        '/regScreen': (context) => RegPage(),
        '/homeScreen': (context) => HomePage(),
      },
      localizationsDelegates:  [
      // Другие делегаты локализации...
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales:  [
        const Locale('en', 'US'), // Английский (США)
        const Locale('ru', 'BY'), // Испанский (Испания)
        // Другие поддерживаемые локали...
      ],
    );
  }
}