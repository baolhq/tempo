import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tempo/screens/clock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode =
      await AdaptiveTheme.getThemeMode() ?? AdaptiveThemeMode.light;

  runApp(MyApp(savedThemeMode: savedThemeMode));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MyApp({super.key, required AdaptiveThemeMode savedThemeMode});

  AdaptiveThemeMode? savedThemeMode;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light(useMaterial3: true),
      dark: ThemeData.dark(useMaterial3: true),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (light, dark) {
        return MaterialApp(
          title: 'Tempo',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale("en"), Locale("vi")],
          theme: light,
          darkTheme: dark,
          home: const ClockScreen(),
        );
      },
    );
  }
}
