import 'package:flutter/material.dart';

class Palette {
  final Color topBgColor;
  final Color bottomBgColor;
  final Color topTextColor;
  final Color bottomTextColor;

  Palette(
      {required this.topBgColor,
      required this.bottomBgColor,
      required this.topTextColor,
      required this.bottomTextColor});

  factory Palette.fromJson(Map<String, dynamic> json) {
    return Palette(
      topBgColor: Color(json["topBgColor"]),
      bottomBgColor: Color(json["bottomBgColor"]),
      topTextColor: Color(json["topTextColor"]),
      bottomTextColor: Color(json["bottomTextColor"]),
    );
  }

  Map<String, dynamic> toJson() => {
        'topBgColor': topBgColor.value,
        'bottomBgColor': bottomBgColor.value,
        'topTextColor': topTextColor.value,
        'bottomTextColor': bottomTextColor.value,
      };
}
