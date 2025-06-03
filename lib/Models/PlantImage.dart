class PlantImage {
  final String plantImageId;
  final String plantId;
  final String url;
  final String? plant;

  PlantImage({
    required this.plantImageId,
    required this.plantId,
    required this.url,
    this.plant,
  });

  factory PlantImage.fromJson(Map<String, dynamic> json) => PlantImage(
    plantImageId: json['plantImageId'],
    plantId: json['plantId'],
    url: json['url'],
    plant: json['plant'],
  );

  Map<String, dynamic> toJson() => {
    'plantImageId': plantImageId,
    'plantId': plantId,
    'url': url,
    'plant': plant,
  };
}
