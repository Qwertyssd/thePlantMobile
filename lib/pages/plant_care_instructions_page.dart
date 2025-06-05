import 'package:flutter/material.dart';
import 'package:theplantmobile/Services/PlantOverviewService.dart';
import 'package:theplantmobile/global.dart';
import 'package:theplantmobile/Models/Plant.dart';
import 'package:theplantmobile/Models/PlantCareInstruction.dart';
import 'package:theplantmobile/Models/PlantImage.dart';
import 'package:theplantmobile/Services/PlantService.dart';
import 'package:theplantmobile/Models/PlantOverview.dart';
import 'package:theplantmobile/Models/OverviewType.dart';

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
  late Future<List<PlantOverview>> _plantOverviewFuture;

  final String bearer = globalJwtToken ?? '';

  Future<List<PlantOverview>> _fetchPlantOverview() async {
    try {
      final overviewList = await PlantOverviewService()
          .getPlantOverviewByPlantId(widget.plantId, bearer);
      return overviewList; // Очікуємо список!
    } catch (e) {
      print('❗ Error loading plant overview: $e');
      return [];
    }
  }

  IconData _getOverviewIcon(OverviewType type) {
    switch (type) {
      case OverviewType.Water:
        return Icons.water_drop;
      case OverviewType.Sunlight:
        return Icons.wb_sunny;
      case OverviewType.Fertilizer:
        return Icons.grass;
      default:
        return Icons.help_outline;
    }
  }

  Color _getOverviewColor(OverviewType type) {
    switch (type) {
      case OverviewType.Water:
        return Colors.blueAccent;
      case OverviewType.Sunlight:
        return Colors.orangeAccent;
      case OverviewType.Fertilizer:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getOverviewLabel(OverviewType type) {
    switch (type) {
      case OverviewType.Water:
        return 'Watering';
      case OverviewType.Sunlight:
        return 'Sunlight';
      case OverviewType.Fertilizer:
        return 'Fertilizing';
      default:
        return 'Unknown';
    }
  }



  @override
  void initState() {
    super.initState();
    _plantFuture = PlantService().getPlantById(widget.plantId, bearer);
    _careInstructionFuture = PlantService().getPlantCareInstructions(widget.plantId, bearer);
    _plantImagesFuture = PlantService().getPlantImages(widget.plantId, bearer);
    _plantOverviewFuture = _fetchPlantOverview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plant Details")),
      body: FutureBuilder<Plant>(
        future: _plantFuture,
        builder: (context, plantSnapshot) {
          if (plantSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (plantSnapshot.hasError) {
            return Center(child: Text('❌ Error: ${plantSnapshot.error}'));
          } else if (!plantSnapshot.hasData) {
            return const Center(child: Text('🌱 Plant not found'));
          } else {
            final plant = plantSnapshot.data!;
            return FutureBuilder<List<PlantImage>>(
              future: _plantImagesFuture,
              builder: (context, imageSnapshot) {
                if (imageSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (imageSnapshot.hasError) {
                  return Center(child: Text('❌ Error loading images: ${imageSnapshot.error}'));
                } else {
                  final images = imageSnapshot.data ?? [];
                  return FutureBuilder<PlantCareInstruction>(
                    future: _careInstructionFuture,
                    builder: (context, careSnapshot) {
                      if (careSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (careSnapshot.hasError) {
                        return Center(child: Text('❌ Error: ${careSnapshot.error}'));
                      } else {
                        final instruction = careSnapshot.data;
                        return FutureBuilder<List<PlantOverview>>(
                          future: _plantOverviewFuture,
                          builder: (context, overviewSnapshot) {
                            if (overviewSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (overviewSnapshot.hasError) {
                              return Center(child: Text('❌ Error loading overview: ${overviewSnapshot.error}'));
                            } else {
                              final overviews = overviewSnapshot.data ?? [];
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image
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
                                    // Name
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
                                      'Category: ${plant.category}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const Divider(height: 32, thickness: 2),
                                    // Care instructions
                                    Text(
                                      "Care Instructions:",
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
                                        'Recommended Frequency: ${instruction.frequencyRecommended}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      if (instruction.note.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Note: ${instruction.note}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ] else
                                      const Text(
                                        '🌱 No care instructions available',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    const Divider(height: 32, thickness: 2),
                                    // Overview
                                    Text(
                                      "Plant Overview:",
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    if (overviews.isNotEmpty)
                                      ...overviews.map((overview) => Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                _getOverviewIcon(overview.overviewType),
                                                color: _getOverviewColor(overview.overviewType),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _getOverviewLabel(overview.overviewType),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: _getOverviewColor(overview.overviewType),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            overview.description,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 12),
                                        ],

                                      ))
                                    else
                                      const Text(
                                        '🌱 No overview available',
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
            );
          }
        },
      ),
    );
  }
}
