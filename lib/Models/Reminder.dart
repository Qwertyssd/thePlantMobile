class Reminder {
  final String? reminderId;
  final String userPlantId;
  final DateTime dateOfReminder;
  final int reminderType;
  final String? frequency;
  final int status;
  final String? completionType;
  final DateTime previousDate;
  final String? userPlant;

  Reminder({
    required this.reminderId,
    required this.userPlantId,
    required this.dateOfReminder,
    required this.reminderType,
    this.frequency,
    required this.status,
    this.completionType,
    required this.previousDate,
    this.userPlant,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      reminderId: json['reminderId'],
      userPlantId: json['userPlantId'],
      dateOfReminder: DateTime.parse(json['dateOfReminder']),
      reminderType: json['reminderType'],
      frequency: json['frequency'],
      status: json['status'],
      completionType: json['completionType'],
      previousDate: DateTime.parse(json['previousDate']),
      userPlant: json['userPlant'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userPlantId': userPlantId,
      'dateOfReminder': dateOfReminder.toIso8601String(),
      'reminderType': reminderType,
      'frequency': frequency,
      'status': status,
      'completionType': completionType,
      'previousDate': previousDate?.toIso8601String(),
    };
  }
}
