import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ci.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempo/components/clock_button.dart';
import 'package:tempo/components/clock_tapper.dart';
import 'package:tempo/models/palette.dart';
import 'package:tempo/models/timer_option.dart';
import 'package:tempo/screens/option_screen.dart';

import 'package:tempo/screens/theme_picker_screen.dart';
import 'package:tempo/utils/prefs.dart';
import 'package:tempo/utils/themes.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  var _initialTime = 5;
  var _bonusTime = 0;
  var _palette = Themes.blackPink;
  var _isClockResetted = true;
  var _isClockPaused = true;
  var _playerTurn = -1;
  late Timer _timer;
  TimerOption _durationTop = TimerOption(
      initialTime: const Duration(minutes: 5),
      bonusTime: const Duration(seconds: 0));
  TimerOption _durationBottom = TimerOption(
      initialTime: const Duration(minutes: 5),
      bonusTime: const Duration(seconds: 0));
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var prefs = await Prefs.loadPrefs();

      setState(() {
        _prefs = prefs;
      });

      _loadPalette();
      _loadTimerOption();
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

  void _countDown() {
    if (_durationTop.initialTime > Duration.zero &&
        _durationBottom.initialTime > Duration.zero) {
      if (!_isClockPaused) {
        if (_playerTurn == 1) {
          setState(() {
            _durationTop.initialTime -= const Duration(seconds: 1);
          });
        } else {
          setState(() {
            _durationBottom.initialTime -= const Duration(seconds: 1);
          });
        }
      }
    } else {
      debugPrint("Time out!!");
      _timer.cancel();
      _isClockPaused = true;
      _playerTurn = -1;
    }
  }

  void _tapperClicked(bool isShowText, bool isTop) {
    if (isShowText || !_isClockPaused) {
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
          _durationTop.initialTime += _durationTop.bonusTime;
        });
      } else {
        setState(() {
          _playerTurn = 1;
          _durationBottom.initialTime += _durationBottom.bonusTime;
        });
      }

      setState(() {
        _isClockResetted = false;
        _isClockPaused = false;
      });
    }
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

  void _navigate(dynamic screen) async {
    setState(() {
      _isClockPaused = true;
    });
    _timer.cancel();
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => screen));
    _loadPalette();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _pauseButtonPressed() {
    if (_isClockPaused) {
      _resetTimer();
    } else {
      setState(() {
        _isClockPaused = true;
      });
    }
  }

  void _resetTimer() {
    setState(() {
      _isClockResetted = true;
      _isClockPaused = true;
      _playerTurn = -1;
    });
    _loadTimerOption();

    _timer.cancel();
  }

  void _loadTimerOption() {
    var initialTime = _prefs?.getInt("initialTime");
    var bonusTime = _prefs?.getInt("bonusTime");

    if (initialTime != null && bonusTime != null) {
      setState(() {
        _initialTime = initialTime;
        _bonusTime = bonusTime;

        _durationTop = TimerOption(
            initialTime: Duration(minutes: _initialTime),
            bonusTime: Duration(seconds: _bonusTime));
        _durationBottom = TimerOption(
            initialTime: Duration(minutes: _initialTime),
            bonusTime: Duration(seconds: _bonusTime));
      });
    }
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
              ClockTapper(
                bgColor: _palette.topBgColor,
                textColor: _palette.topTextColor,
                durationTop: _durationTop,
                durationBottom: _durationBottom,
                isTop: true,
                isClockPaused: _isClockPaused,
                isClockResetted: _isClockResetted,
                timer: _timer,
                timerOption: _durationTop.toString(),
                playerTurn: _playerTurn,
                isShowText: _playerTurn == -1 || _playerTurn == 1,
                callback: (isShowText, isTop) =>
                    _tapperClicked(isShowText, isTop),
              ),
              ClockTapper(
                bgColor: _palette.bottomBgColor,
                textColor: _palette.bottomTextColor,
                durationTop: _durationTop,
                durationBottom: _durationBottom,
                isClockPaused: _isClockPaused,
                isClockResetted: _isClockResetted,
                timer: _timer,
                timerOption: _durationBottom.toString(),
                playerTurn: _playerTurn,
                isShowText: _playerTurn == -1 || _playerTurn == 0,
                callback: (isShowText, isTop) =>
                    _tapperClicked(isShowText, isTop),
              ),
            ],
          ),
          ClockButton(
              x: screenW / 4 - buttonRadius,
              y: screenH / 2 - buttonRadius,
              icon: Iconify(
                Ci.settings,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              isClockPaused: _isClockPaused,
              callback: () => _navigate(const OptionScreen())),
          ClockButton(
              x: screenW / 2 - buttonRadius,
              y: screenH / 2 - buttonRadius,
              icon: Iconify(
                _isClockPaused ? Ci.redo : Ci.pause_circle_outline,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              isClockPaused: _isClockPaused,
              isPauseButton: true,
              callback: () => _pauseButtonPressed()),
          ClockButton(
              x: screenW / 1.4 - buttonRadius,
              y: screenH / 2 - buttonRadius,
              icon: Iconify(
                Ci.color,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              isClockPaused: _isClockPaused,
              callback: () => _navigate(const ThemePickerScreen()))
        ],
      ),
    );
  }
}
