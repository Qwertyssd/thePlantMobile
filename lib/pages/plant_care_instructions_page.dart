import 'package:flutter/material.dart';
import 'package:theplantmobile/Models/PlantCareInstruction.dart'; // якщо така модель є
import 'package:theplantmobile/Services/PlantService.dart'; // або свій сервіс
String bearer = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjgzYWIxNTRhLTcxOTItNGRkNC1iNzdiLTNiY2QxMDg4Y2I1NCIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlVzZXIiLCJleHAiOjE3ODA0NDQ4MTQsImlzcyI6Imh0dHBzOi8vbG9jYWxob3N0OjgwMDEiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdDo4MDAxIn0.SpaQtj-D3KLWJflNUPb1q3NZ0SwKRamCErC_mw99jUA";
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
