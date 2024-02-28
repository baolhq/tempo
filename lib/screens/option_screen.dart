import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ci.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OptionScreen extends StatefulWidget {
  const OptionScreen({super.key});

  @override
  State<OptionScreen> createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen> {
  var _isDarkTheme = false;
  var _isSystemTheme = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isDarkTheme = AdaptiveTheme.of(context).mode.isDark;
        _isSystemTheme = AdaptiveTheme.of(context).mode.isSystem;
      });
    });
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
          ListTile(
              title: Text(AppLocalizations.of(context)!.feedback),
              trailing: Iconify(Ci.chevron_right,
                  color: Theme.of(context).colorScheme.onBackground)),
        ],
      ),
    );
  }
}
