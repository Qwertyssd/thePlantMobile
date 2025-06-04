class PlantCareInstruction {
  final String plantCareInstructionId;
  final String plantId;
  final String description;
  final int frequencyRecommended;
  final String note;
  final String? plant;

  PlantCareInstruction({
    required this.plantCareInstructionId,
    required this.plantId,
    required this.description,
    required this.frequencyRecommended,
    required this.note,
    this.plant,
  });

  factory PlantCareInstruction.fromJson(Map<String, dynamic> json) => PlantCareInstruction(
    plantCareInstructionId: json['plantCareInstructionId'],
    plantId: json['plantId'],
    description: json['description'],
    frequencyRecommended: json['frequencyRecommended'],
    note: json['note'],
    plant: json['plant'],
  );

  Map<String, dynamic> toJson() => {
    'plantCareInstructionId': plantCareInstructionId,
    'plantId': plantId,
    'description': description,
    'frequencyRecommended': frequencyRecommended,
    'note': note,
    'plant': plant,
  };
}
