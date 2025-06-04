class PlantOverview {
  final String plantOverviewId;
  final String plantId;
  final int overviewType;
  final String description;
  final String? plant;

  PlantOverview({
    required this.plantOverviewId,
    required this.plantId,
    required this.overviewType,
    required this.description,
    this.plant,
  });

  factory PlantOverview.fromJson(Map<String, dynamic> json) => PlantOverview(
    plantOverviewId: json['plantOverviewId'],
    plantId: json['plantId'],
    overviewType: json['overviewType'],
    description: json['description'],
    plant: json['plant'],
  );

  Map<String, dynamic> toJson() => {
    'plantOverviewId': plantOverviewId,
    'plantId': plantId,
    'overviewType': overviewType,
    'description': description,
    'plant': plant,
  };
}