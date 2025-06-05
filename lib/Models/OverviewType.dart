
enum OverviewType {
  Water,
  Sunlight,
  Fertilizer,
  unknown,
}

OverviewType overviewTypeFromString(String type) {
  switch (type) {
    case '1':
      return OverviewType.Water;
    case '2':
      return OverviewType.Sunlight;
    case '3':
      return OverviewType.Fertilizer;
    default:
      return OverviewType.unknown;
  }
}

String overviewTypeToString(OverviewType type) {
  switch (type) {
    case OverviewType.Water:
      return '1';
    case OverviewType.Sunlight:
      return '2';
    case OverviewType.Fertilizer:
      return '3';
    default:
      return '0';
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
    dynamic overviewTypeValue = json['overviewType'];
    String overviewTypeString;

    if (overviewTypeValue is int) {
      overviewTypeString = overviewTypeValue.toString();
    } else if (overviewTypeValue is String) {
      overviewTypeString = overviewTypeValue;
    } else {
      overviewTypeString = 'unknown';
    }

    return PlantOverview(
      plantOverviewId: json['plantOverviewId'] as String?,
      plantId: json['plantId'] as String,
      overviewType: overviewTypeFromString(overviewTypeString),
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
