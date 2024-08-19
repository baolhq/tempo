import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimerSubText extends StatelessWidget {
  const TimerSubText(
      {super.key,
      required this.color,
      required this.isClockPaused,
      required this.isShowText,
      required this.isClockResetted,
      required this.text});

  final Color color;
  final bool isClockPaused;
  final bool isShowText;
  final bool isClockResetted;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: ((isClockPaused && isShowText) || isClockResetted) ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 16,
            color: color,
            fontFamily: GoogleFonts.jetBrainsMono().fontFamily),
      ),
    );
  }
}
