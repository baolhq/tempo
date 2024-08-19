class TimerOption {
  Duration initialTime;
  Duration bonusTime;

  TimerOption({required this.initialTime, required this.bonusTime});

  @override
  String toString() {
    return "${initialTime.inMinutes} + ${bonusTime.inSeconds}";
  }

  factory TimerOption.fromJson(Map<String, dynamic> json) {
    return TimerOption(
      initialTime: Duration(minutes: int.parse(json["startTime"])),
      bonusTime: Duration(minutes: int.parse(json["incTime"])),
    );
  }

  Map<String, dynamic> toJson() => {
        'startTime': initialTime.inMinutes,
        'incTime': bonusTime.inMinutes,
      };
}
