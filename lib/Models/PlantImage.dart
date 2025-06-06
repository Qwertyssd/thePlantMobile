class PlantImage {
  final String plantImageId;
  final String plantId;
  final String url;


  PlantImage({
    required this.plantImageId,
    required this.plantId,
    required this.url,

  });

  factory PlantImage.fromJson(Map<String, dynamic> json) => PlantImage(
    plantImageId: json['plantImageId'],
    plantId: json['plantId'],
    url: json['url'],

  );

  Map<String, dynamic> toJson() => {
    'plantImageId': plantImageId,
    'plantId': plantId,
    'url': url,

  };
}
