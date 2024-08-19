import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ci.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempo/models/palette.dart';
import 'package:tempo/utils/core.dart';
import 'package:tempo/utils/prefs.dart';
import 'package:tempo/utils/themes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math' as math;

class ThemePickerScreen extends StatefulWidget {
  const ThemePickerScreen({super.key});

  @override
  State<ThemePickerScreen> createState() => _ThemePickerScreenState();
}

class _ThemePickerScreenState extends State<ThemePickerScreen> {
  var _palette = Themes.blackPink;
  SharedPreferences? _prefs;

  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var prefs = await Prefs.loadPrefs();

      setState(() {
        _prefs = prefs;
      });

      _loadPalette();
    });
  }

  void _loadPalette() {
    final String? json = _prefs?.getString("palette");

    if (json != null && json.isNotEmpty) {
      var palette = Palette.fromJson(jsonDecode(json));

      setState(() {
        _palette = palette;
      });
    }
  }

  Future<bool> _savePalette() async {
    await _prefs?.setString("palette", jsonEncode(_palette));
    return true;
  }

  Widget _buildTapper(
      {Color bgColor = Colors.black,
      Color textColor = Colors.white,
      Duration duration = const Duration(minutes: 5),
      bool isTop = false}) {
    var minute = duration.inMinutes;
    var sec = duration.inSeconds % 60;
    var minuteStr = minute.toString().padLeft(2, '0');
    var secStr = sec.toString().padLeft(2, '0');

    double topLeftRadius = isTop ? 16 : 0;
    double topRightRadius = isTop ? 16 : 0;
    double bottomLeftRadius = isTop ? 0 : 16;
    double bottomRightRadius = isTop ? 0 : 16;

    return Expanded(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topLeftRadius),
              topRight: Radius.circular(topRightRadius),
              bottomLeft: Radius.circular(bottomLeftRadius),
              bottomRight: Radius.circular(bottomRightRadius),
            ),
            color: bgColor),
        child: Transform.rotate(
          angle: isTop ? math.pi : 0,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "$minuteStr:$secStr",
              style: TextStyle(fontSize: 24, color: textColor),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildThemeTile(Palette palette) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _palette = palette;
          });
        },
        borderRadius: BorderRadius.circular(128),
        child: Ink(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Stack(children: [
              Column(
                children: [
                  Expanded(
                      child: Container(
                    decoration: BoxDecoration(
                        color: palette.topBgColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(128),
                            topRight: Radius.circular(128))),
                  )),
                  Expanded(
                      child: Container(
                    decoration: BoxDecoration(
                        color: palette.bottomBgColor,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(128),
                            bottomRight: Radius.circular(128))),
                  )),
                ],
              ),
              if (_palette.topBgColor == palette.topBgColor)
                Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withAlpha(220),
                            shape: BoxShape.circle),
                        child: Iconify(
                          Ci.check,
                          color: Theme.of(context).colorScheme.onSurface,
                        )))
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildApplyButton(Color bgColor, Color textColor) {
    return Container(
      width: MediaQuery.of(context).size.width - 84,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          _loadAd();
          await _savePalette();
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              AppLocalizations.of(context)!.apply,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: GoogleFonts.poppins().fontFamily),
            ),
          ),
        ),
      ),
    );
  }

  void _loadAd() {
    InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');

            ad.fullScreenContentCallback =
                FullScreenContentCallback(onAdDismissedFullScreenContent: (_) {
              Core.showToast(
                  mounted, context, AppLocalizations.of(context)!.themeApplied);
            });
            ad.show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Iconify(
            Ci.chevron_left,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.themes,
        ),
        centerTitle: true,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        shadowColor: Theme.of(context).shadowColor,
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 48),
          width: double.infinity,
          height: 280,
          child: Center(
            child: SizedBox(
              width: 160,
              child: Column(
                children: [
                  _buildTapper(
                      bgColor: _palette.topBgColor,
                      textColor: _palette.topTextColor,
                      duration: const Duration(minutes: 5),
                      isTop: true),
                  _buildTapper(
                    bgColor: _palette.bottomBgColor,
                    textColor: _palette.bottomTextColor,
                    duration: const Duration(minutes: 5),
                  )
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildThemeTile(Themes.blackPink),
            _buildThemeTile(Themes.blackWhite),
            _buildThemeTile(Themes.goldenBlack),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildThemeTile(Themes.crimsonBlack),
              _buildThemeTile(Themes.greenBlack),
              _buildThemeTile(Themes.coralSky),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildApplyButton(
                      _palette.topBgColor, _palette.topTextColor))
            ],
          ),
        )
      ]),
    );
  }
}
