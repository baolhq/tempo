import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ci.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempo/models/palette.dart';
import 'package:tempo/screens/option_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math' as math;

import 'package:tempo/screens/theme_picker_screen.dart';
import 'package:tempo/utils/themes.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  var _timerTop = const Duration(minutes: 5);
  var _timerBottom = const Duration(minutes: 5);
  var _palette = Themes.blackPink;
  var _isClockResetted = true;
  var _isClockPaused = true;
  var _playerTurn = -1;
  late Timer _timer;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPrefs();
      _loadPalette();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countDown();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<bool> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    return true;
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

  void _countDown() {
    if (!_isClockPaused) {
      if (_playerTurn == 1) {
        setState(() {
          _timerTop -= const Duration(seconds: 1);
        });
      } else {
        setState(() {
          _timerBottom -= const Duration(seconds: 1);
        });
      }
    }
  }

  Widget _buildTapper(
      {Color bgColor = Colors.black,
      Color textColor = Colors.white,
      Duration duration = const Duration(minutes: 5),
      bool isTop = false,
      bool isShowText = false,
      bool isClickable = false}) {
    var minute = duration.inMinutes;
    var sec = duration.inSeconds % 60;
    var minuteStr = minute.toString().padLeft(2, '0');
    var secStr = sec.toString().padLeft(2, '0');

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isShowText && _isClockPaused) {
          } else {
            if (!_timer.isActive) {
              setState(() {
                _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                  _countDown();
                });
              });
            }

            if (isTop) {
              setState(() {
                _playerTurn = 0;
              });
            } else {
              setState(() {
                _playerTurn = 1;
              });
            }

            setState(() {
              _isClockResetted = false;
              _isClockPaused = false;
            });
          }
        },
        child: Ink(
          color: bgColor,
          child: Container(
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: isTop ? math.pi : 0,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$minuteStr:$secStr",
                      style: TextStyle(
                          fontSize: 64,
                          color: textColor,
                          fontFamily: GoogleFonts.poppins().fontFamily),
                    ),
                    if ((_isClockPaused && isShowText) || _isClockResetted)
                      Text(
                        AppLocalizations.of(context)!.tapToStart,
                        style: TextStyle(fontSize: 16, color: textColor),
                      )
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(double x, double y, Iconify icon, Function onTap) {
    return Positioned(
        top: y,
        left: x,
        child: InkWell(
          onTap: () => onTap(),
          borderRadius: BorderRadius.circular(128),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(128),
              color: Theme.of(context).scaffoldBackgroundColor.withAlpha(100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(64)),
                  child: icon),
            ),
          ),
        ));
  }

  void _navigate(dynamic screen) async {
    setState(() {
      _isClockPaused = true;
    });
    _timer.cancel();
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => screen));
    _loadPalette();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    const buttonRadius = 32 - 8; // Minute padding size

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildTapper(
                  bgColor: _palette.topBgColor,
                  textColor: _palette.topTextColor,
                  duration: _timerTop,
                  isTop: true,
                  isShowText: _playerTurn == -1 || _playerTurn == 1,
                  isClickable: (_playerTurn == 0 && _isClockPaused) ||
                      _playerTurn == 1 ||
                      _isClockResetted),
              _buildTapper(
                  bgColor: _palette.bottomBgColor,
                  textColor: _palette.bottomTextColor,
                  duration: _timerBottom,
                  isShowText: _playerTurn == -1 || _playerTurn == 0,
                  isClickable: (_playerTurn == 1 && _isClockPaused) ||
                      _playerTurn == 0 ||
                      _isClockResetted),
            ],
          ),
          _buildButton(
              screenW / 4 - buttonRadius,
              screenH / 2 - buttonRadius,
              Iconify(
                Ci.settings,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              () => _navigate(const OptionScreen())),
          _buildButton(
              screenW / 1.4 - buttonRadius,
              screenH / 2 - buttonRadius,
              Iconify(
                Ci.color,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              () => _navigate(const ThemePickerScreen())),
        ],
      ),
    );
  }
}
