import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimerText extends StatelessWidget {
  const TimerText({super.key, required this.duration, required this.color});

  final Duration duration;
  final Color color;

  @override
  Widget build(BuildContext context) {
    var minuteStr = duration.inMinutes.toString().padLeft(2, '0');
    var second = duration.inSeconds % 60;
    var secondStr = second.toString().padLeft(2, '0');

    return Text(
      "$minuteStr:$secondStr",
      style: TextStyle(
          fontSize: 64,
          color: color,
          fontFamily: GoogleFonts.jetBrainsMono().fontFamily),
    );
  }
}
