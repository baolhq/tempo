import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempo/screens/clock_screen.dart';
import 'package:tempo/utils/prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode =
      await AdaptiveTheme.getThemeMode() ?? AdaptiveThemeMode.light;

  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required AdaptiveThemeMode savedThemeMode});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  AdaptiveThemeMode? savedThemeMode;
  SharedPreferences? _prefs;

  var _locale = const Locale("en", "US");

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var prefs = await Prefs.loadPrefs();

      setState(() {
        _prefs = prefs;
      });

      _loadLanguague();
    });
  }

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _loadLanguague() {
    var lang = _prefs?.getString("lang");

    if (lang != null) {
      switch (lang) {
        case "en_US":
          setState(() {
            _locale = const Locale("en", "US");
          });
          break;
        case "vi_VN":
          setState(() {
            _locale = const Locale("vi", "VN");
          });
          break;
      }
    }
  }

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
          supportedLocales: const [Locale("en", "US"), Locale("vi", "VN")],
          locale: _locale,
          localeListResolutionCallback: (locales, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (locales != null &&
                  supportedLocale.languageCode == locales.first.languageCode &&
                  supportedLocale.countryCode == locales.first.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          theme: light,
          darkTheme: dark,
          home: const ClockScreen(),
        );
      },
    );
  }
}
