import 'dart:convert';
enum ReminderType {
  Watering,
  Fertilizing,
  Pruning,
  Unknown,
}

ReminderType reminderTypeFromInt(int? value) {
  switch (value) {
    case 0:
      return ReminderType.Watering;
    case 1:
      return ReminderType.Fertilizing;
    case 2:
      return ReminderType.Pruning;
    default:
      return ReminderType.Unknown;
  }
}

int reminderTypeToInt(ReminderType type) {
  switch (type) {
    case ReminderType.Watering:
      return 0;
    case ReminderType.Fertilizing:
      return 1;
    case ReminderType.Pruning:
      return 2;
    default:
      return -1;
  }
}

enum ReminderStatus {
  Pending,
  Completed,
  Snoozed,
  Unknown,
}

ReminderStatus reminderStatusFromInt(int? value) {
  switch (value) {
    case 0:
      return ReminderStatus.Pending;
    case 1:
      return ReminderStatus.Completed;
    case 2:
      return ReminderStatus.Snoozed;
    default:
      return ReminderStatus.Unknown;
  }
}

int reminderStatusToInt(ReminderStatus status) {
  switch (status) {
    case ReminderStatus.Pending:
      return 0;
    case ReminderStatus.Completed:
      return 1;
    case ReminderStatus.Snoozed:
      return 2;
    default:
      return -1;
  }
}

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
      reminderType: (json['reminderType']),
      frequency: json['frequency'],
      status: (json['status']),
      completionType: json['completionType'],
      previousDate: DateTime.parse(json['previousDate']),
      userPlant: json['userPlant'],
    );
  }

  Map<String, dynamic> toJson() {


    final json = {

      'userPlantId': userPlantId,
      'dateOfReminder': dateOfReminder.toIso8601String(),
      'reminderType':reminderType ,
      'frequency': frequency,
      'status': status,
      'completionType': completionType,
      'previousDate': previousDate?.toIso8601String(),
    };

    // Логування для дебагу
    print('📦 Reminder toJson: $json');

    return json;
  }

  Map<String, dynamic> toJsonUpdate() {


    final json = {
      'reminderId': reminderId,
      'userPlantId': userPlantId,
      'dateOfReminder': dateOfReminder.toIso8601String(),
      'reminderType':reminderType ,
      'frequency': frequency,
      'status': status,
      'completionType': completionType,
      'previousDate': previousDate?.toIso8601String(),

    };

    // Логування для дебагу
    print('📦 Reminder toJson: $json');

    return json;
  }

  Reminder copyWith({
    String? reminderId,
    String? userPlantId,
    DateTime? dateOfReminder,
    int? reminderType,
    String? frequency,
    int? status,
    String? completionType,
    DateTime? previousDate,
    String? userPlant,
  }) {
    final updatedReminder = Reminder(
      reminderId: reminderId ?? this.reminderId,
      userPlantId: userPlantId ?? this.userPlantId,
      dateOfReminder: dateOfReminder ?? this.dateOfReminder,
      reminderType: reminderType ?? this.reminderType,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      completionType: completionType ?? this.completionType,
      previousDate: previousDate ?? this.previousDate,
      userPlant: userPlant ?? this.userPlant,
    );

    print("🔄 Reminder updated: $updatedReminder");
    return updatedReminder;
  }

}




