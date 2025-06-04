import 'package:flutter/material.dart';
import 'package:theplantmobile/global.dart';
import 'package:theplantmobile/Models/PlantCareInstruction.dart'; // якщо така модель є
import 'package:theplantmobile/Services/PlantService.dart'; // або свій сервіс




class PlantCareInstructionsPage extends StatefulWidget {
  final String plantId;

  const PlantCareInstructionsPage({super.key, required this.plantId});

  @override
  State<PlantCareInstructionsPage> createState() => _PlantCareInstructionsPageState();
}

class _PlantCareInstructionsPageState extends State<PlantCareInstructionsPage> {
  late Future<PlantCareInstruction> _careInstructionFuture;

  @override
  void initState() {
    super.initState();
    _careInstructionFuture = PlantService().getPlantCareInstructions(widget.plantId, bearer);
  }
  final String bearer = globalJwtToken ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Інструкції по догляду")),
      body: FutureBuilder<PlantCareInstruction>(
        future: _careInstructionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Помилка: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('🌱 Інструкції відсутні'));
          } else {
            final instruction = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instruction.description,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Рекомендована частота: ${instruction.frequencyRecommended}'),
                  if (instruction.note.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Примітка: ${instruction.note}'),
                  ],
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
