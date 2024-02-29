import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class ClockButton extends StatelessWidget {
  const ClockButton(
      {super.key,
      required this.x,
      required this.y,
      required this.icon,
      this.isPauseButton = false,
      required this.isClockPaused,
      required this.callback});

  final double x;
  final double y;
  final Iconify icon;
  final bool isPauseButton;
  final bool isClockPaused;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    double opacity = 1;

    if (!isClockPaused && !isPauseButton) {
      opacity = 0;
    }

    return Positioned(
        top: y,
        left: x,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 200),
          child: InkWell(
            onTap: () => callback(),
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
          ),
        ));
  }
}
