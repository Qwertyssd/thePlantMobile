import 'package:theplantmobile/Models/Reminder.dart';
import 'package:theplantmobile/Models/Plant.dart';


class UserPlant {
  final String userPlantId;
  final String userId;
  final String plantId;
  final String? userPlantName;
  final Plant? plant;
  final List<Reminder>? reminders;

  UserPlant({
    required this.userPlantId,
    required this.userId,
    required this.plantId,
    this.userPlantName,
    this.plant,
    this.reminders,
  });

  factory UserPlant.fromJson(Map<String, dynamic> json) => UserPlant(
    userPlantId: json['userPlantId'],
    userId: json['userId'],
    plantId: json['plantId'],
    userPlantName: json['userPlantName'],
    plant: json['plant'] != null ? Plant.fromJson(json['plant']) : null,
    reminders: json['reminders'] != null
        ? List<Reminder>.from(json['reminders'].map((x) => Reminder.fromJson(x)))
        : null,
  );

  Map<String, dynamic> toJson() => {
    'userPlantId': userPlantId,
    'userId': userId,
    'plantId': plantId,
    'userPlantName': userPlantName,
    'plant': plant?.toJson(),
    'reminders': reminders?.map((x) => x.toJson()).toList(),
  };
}

