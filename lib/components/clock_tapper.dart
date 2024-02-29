import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tempo/components/timer_subtext.dart';
import 'package:tempo/components/timer_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tempo/models/timer_option.dart';

// ignore: must_be_immutable
class ClockTapper extends StatefulWidget {
  ClockTapper({
    super.key,
    required this.bgColor,
    required this.textColor,
    required this.durationTop,
    required this.durationBottom,
    required this.isShowText,
    required this.isClockPaused,
    required this.isClockResetted,
    required this.timer,
    required this.playerTurn,
    required this.callback,
    required this.timerOption,
    this.isTop = false,
  });

  final Color bgColor;
  final Color textColor;
  TimerOption durationTop;
  TimerOption durationBottom;
  final bool isTop;
  bool isShowText;
  bool isClockPaused;
  bool isClockResetted;
  Timer timer;
  int playerTurn;
  String timerOption;
  Function callback;

  @override
  State<ClockTapper> createState() => _ClockTapperState();
}

class _ClockTapperState extends State<ClockTapper> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => widget.callback(widget.isShowText, widget.isTop),
        child: Ink(
          color: widget.bgColor,
          child: Container(
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: widget.isTop ? math.pi : 0,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TimerSubText(
                      isClockPaused: widget.isClockPaused,
                      isClockResetted: widget.isClockResetted,
                      isShowText: widget.isShowText,
                      color: widget.textColor,
                      text: widget.timerOption,
                    ),
                    TimerText(
                        duration: widget.isTop
                            ? widget.durationTop.initialTime
                            : widget.durationBottom.initialTime,
                        color: widget.textColor),
                    TimerSubText(
                      isClockPaused: widget.isClockPaused,
                      isClockResetted: widget.isClockResetted,
                      isShowText: widget.isShowText,
                      color: widget.textColor,
                      text: AppLocalizations.of(context)!.tapToStart,
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
