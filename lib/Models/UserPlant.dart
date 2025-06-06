import 'package:theplantmobile/Models/Reminder.dart';
import 'package:theplantmobile/Models/Plant.dart';


class UserPlant {
  final String? userPlantId;
  final String userId;
  final String plantId;
  final String? userPlantName;
  final Plant? plant;
  final List<Reminder>? reminders;

  UserPlant({
     this.userPlantId,
    required this.userId,
    required this.plantId,
    this.userPlantName,
    this.plant,
    this.reminders,
  });
  UserPlant copyWith({
    String? userPlantId,
    String? userId,
    String? plantId,
    String? userPlantName,
    Plant? plant,
  }) {
    return UserPlant(
      userPlantId: userPlantId ?? this.userPlantId,
      userId: userId ?? this.userId,
      plantId: plantId ?? this.plantId,
      userPlantName: userPlantName ?? this.userPlantName,
      plant: plant ?? this.plant,
    );
  }
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

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'userId': userId,
      'plantId': plantId,
    };


      data['userPlantId'] = userPlantId;



      data['userPlantName'] = userPlantName;

    data['user']=null;

      data['plant'] = null ;



      data['reminders'] = null;

    print (data);
    return data;
  }


}

