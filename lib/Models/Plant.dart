import 'package:theplantmobile/Models/PlantCareInstruction.dart';
import 'package:theplantmobile/Models/OverviewType.dart';
import 'package:theplantmobile/Models/PlantImage.dart';

class Plant {
  final String plantId;
  final String plantName;
  final String category;
  final String scientificTitle;
  final List<String>? userPlants;
  final List<PlantCareInstruction>? plantCareInstructions;
  final List<PlantOverview>? plantOverviews;
   List<PlantImage>? plantImages;

  Plant({
    required this.plantId,
    required this.plantName,
    required this.category,
    required this.scientificTitle,
    this.userPlants,
    this.plantCareInstructions,
    this.plantOverviews,
    this.plantImages,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
    plantId: json['plantId'],
    plantName: json['plantName'],
    category: json['category'],
    scientificTitle: json['scientificTitle'],
    userPlants: json['userPlants'] != null ? List<String>.from(json['userPlants']) : null,
    plantCareInstructions: json['plantCareInstructions'] != null
        ? (json['plantCareInstructions'] as List)
        .map((e) => PlantCareInstruction.fromJson(e))
        .toList()
        : null,
    plantOverviews: json['plantOverviews'] != null
        ? (json['plantOverviews'] as List)
        .map((e) => PlantOverview.fromJson(e))
        .toList()
        : null,
    plantImages: json['plantImages'] != null
        ? (json['plantImages'] as List)
        .map((e) => PlantImage.fromJson(e))
        .toList()
        : null,
  );

  Map<String, dynamic> toJson() => {
    'plantId': plantId,
    'plantName': plantName,
    'category': category,
    'scientificTitle': scientificTitle,
    'userPlants': userPlants,
    'plantCareInstructions': plantCareInstructions?.map((e) => e.toJson()).toList(),
    'plantOverviews': plantOverviews?.map((e) => e.toJson()).toList(),
    'plantImages': plantImages?.map((e) => e.toJson()).toList(),
  };
}