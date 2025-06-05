import 'package:flutter/material.dart';
import 'package:theplantmobile/global.dart';
import 'package:theplantmobile/Models/Plant.dart';
import 'package:theplantmobile/Models/PlantCareInstruction.dart';
import 'package:theplantmobile/Models/PlantImage.dart';
import 'package:theplantmobile/Services/PlantService.dart';

class PlantCareInstructionsPage extends StatefulWidget {
  final String plantId;

  const PlantCareInstructionsPage({super.key, required this.plantId});

  @override
  State<PlantCareInstructionsPage> createState() => _PlantCareInstructionsPageState();
}

class _PlantCareInstructionsPageState extends State<PlantCareInstructionsPage> {
  late Future<Plant> _plantFuture;
  late Future<PlantCareInstruction> _careInstructionFuture;
  late Future<List<PlantImage>> _plantImagesFuture;
  final String bearer = globalJwtToken ?? '';

  @override
  void initState() {
    super.initState();
    _plantFuture = PlantService().getPlantById(widget.plantId, bearer);
    _careInstructionFuture = PlantService().getPlantCareInstructions(widget.plantId, bearer);
    _plantImagesFuture = PlantService().getPlantImages(widget.plantId, bearer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Деталі рослини")),
      body: FutureBuilder<Plant>(
        future: _plantFuture,
        builder: (context, plantSnapshot) {
          if (plantSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (plantSnapshot.hasError) {
            return Center(child: Text('❌ Помилка: ${plantSnapshot.error}'));
          } else if (!plantSnapshot.hasData) {
            return const Center(child: Text('🌱 Рослину не знайдено'));
          } else {
            final plant = plantSnapshot.data!;
            return FutureBuilder<List<PlantImage>>(
              future: _plantImagesFuture,
              builder: (context, imageSnapshot) {
                if (imageSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (imageSnapshot.hasError) {
                  return Center(child: Text('❌ Помилка при завантаженні фото: ${imageSnapshot.error}'));
                } else {
                  final images = imageSnapshot.data ?? [];

                  return FutureBuilder<PlantCareInstruction>(
                    future: _careInstructionFuture,
                    builder: (context, careSnapshot) {
                      if (careSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (careSnapshot.hasError) {
                        return Center(child: Text('❌ Помилка: ${careSnapshot.error}'));
                      } else {
                        final instruction = careSnapshot.data;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Фото (слайдер або перше фото)
                              if (images.isNotEmpty)
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      images.first.url,
                                      height: 450,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              // Назва та деталі
                              Text(
                                plant.plantName,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                plant.scientificTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Категорія: ${plant.category}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Divider(height: 32, thickness: 2),

                              // Інструкції по догляду
                              Text(
                                "Інструкції по догляду:",
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              if (instruction != null) ...[
                                Text(
                                  instruction.description,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Рекомендована частота: ${instruction.frequencyRecommended}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                if (instruction.note.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Примітка: ${instruction.note}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ] else
                                const Text(
                                  '🌱 Інструкції відсутні',
                                  style: TextStyle(fontSize: 16),
                                ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
