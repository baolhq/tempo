import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ci.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempo/components/membership.dart';

import 'package:tempo/main.dart';
import 'package:tempo/utils/prefs.dart';

class OptionScreen extends StatefulWidget {
  const OptionScreen({super.key});

  @override
  State<OptionScreen> createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen> {
  var _isDarkTheme = false;
  var _isSystemTheme = false;
  var _selectedLocale = const Locale("en", "US");
  SharedPreferences? _prefs;
  final _supportedLocales = [
    const Locale("en", "US"),
    const Locale("vi", "VN")
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var prefs = await Prefs.loadPrefs();

      setState(() {
        _isDarkTheme = AdaptiveTheme.of(context).mode.isDark;
        _isSystemTheme = AdaptiveTheme.of(context).mode.isSystem;
        _prefs = prefs;
      });

      _loadLanguague();
    });
  }

  void _loadLanguague() {
    var lang = _prefs?.getString("lang");

    if (lang != null) {
      switch (lang) {
        case "en_US":
          setState(() {
            _selectedLocale = const Locale("en", "US");
          });
          break;
        case "vi_VN":
          setState(() {
            _selectedLocale = const Locale("vi", "VN");
          });
          break;
      }
    }
  }

  void _saveLanguage() async {
    String res = "";

    if (_selectedLocale.languageCode == "en" &&
        _selectedLocale.countryCode == "US") {
      res = "en_US";
    } else if (_selectedLocale.languageCode == "vi" &&
        _selectedLocale.countryCode == "VN") {
      res = "vi_VN";
    }

    await _prefs?.setString("lang", res);
  }

  void _setDarkTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
      _isSystemTheme = false;
    });

    if (isDark) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
  }

  void _setSystemTheme(bool isSystem) {
    setState(() {
      _isDarkTheme = false;
      _isSystemTheme = isSystem;
    });

    if (isSystem) {
      AdaptiveTheme.of(context).setSystem();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
  }

  String _localeToString(Locale locale) {
    if (locale.languageCode == "vi" && locale.countryCode == "VN") {
      return "Tiếng Việt";
    }
    return "English";
  }

  void _setLocale(BuildContext context, Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });

    MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    if (state != null) {
      state.changeLanguage(locale);
    }

    _saveLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Iconify(
              Ci.chevron_left,
              color: Theme.of(context).colorScheme.onBackground,
            )),
        title: Text(AppLocalizations.of(context)!.options),
        centerTitle: true,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        shadowColor: Theme.of(context).shadowColor,
      ),
      body: ListView(
        children: [
          const Membership(),
          ListTile(
            title: Text(AppLocalizations.of(context)!.useDarkTheme),
            trailing: Switch(
              onChanged: (value) => _setDarkTheme(value),
              value: _isDarkTheme,
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.useSystemTheme),
            trailing: Switch(
              onChanged: (value) => _setSystemTheme(value),
              value: _isSystemTheme,
            ),
          ),
          InkWell(
            onTap: () {},
            child: Ink(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListTile(
                  title: Text(AppLocalizations.of(context)!.feedback),
                  trailing: Iconify(Ci.chevron_right,
                      color: Theme.of(context).colorScheme.onBackground)),
            ),
          ),
          InkWell(
            onTap: () {},
            child: Ink(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.language),
                  trailing: DropdownButton(
                    icon: Iconify(
                      Ci.chevron_down,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    underline: const SizedBox(),
                    value: _selectedLocale,
                    onChanged: (value) => _setLocale(context, value as Locale),
                    items: [
                      for (var locale in _supportedLocales)
                        DropdownMenuItem(
                          value: locale,
                          child: Text(_localeToString(locale)),
                        )
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
