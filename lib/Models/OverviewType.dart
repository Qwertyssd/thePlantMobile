
enum OverviewType {
  typeA,
  typeB,
  typeC,
  unknown,
}

OverviewType overviewTypeFromString(String type) {
  switch (type) {
    case 'Water':
      return OverviewType.typeA;
    case 'Sunlight':
      return OverviewType.typeB;
    case 'Fertilizer':
      return OverviewType.typeC;
    default:
      return OverviewType.unknown;
  }
}

String overviewTypeToString(OverviewType type) {
  switch (type) {
    case OverviewType.typeA:
      return 'Water';
    case OverviewType.typeB:
      return 'Sunlight';
    case OverviewType.typeC:
      return 'Fertilizer';
    default:
      return 'Unknown';
  }
}

class PlantOverview {
  final String? plantOverviewId;
  final String plantId;
  final OverviewType overviewType;
  final String description;

  PlantOverview({
    required this.plantOverviewId,
    required this.plantId,
    required this.overviewType,
    required this.description,
  });

  factory PlantOverview.fromJson(Map<String, dynamic> json) {
    return PlantOverview(
      plantOverviewId: json['plantOverviewId'] as String,
      plantId: json['plantId'] as String,
      overviewType: overviewTypeFromString(json['overviewType'] ?? 'unknown'),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plantOverviewId': plantOverviewId,
      'plantId': plantId,
      'overviewType': overviewTypeToString(overviewType),
      'description': description,
    };
  }
}
