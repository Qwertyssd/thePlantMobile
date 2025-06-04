import 'package:flutter/material.dart';
import 'package:theplantmobile/Services/PlantService.dart';
import 'package:theplantmobile/Models/Plant.dart';
import 'package:theplantmobile/pages/plant_care_instructions_page.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  late Future<List<Plant>> _plantsFuture;

  @override
  void initState() {
    super.initState();
    _plantsFuture = PlantService().getPlants(
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjgzYWIxNTRhLTcxOTItNGRkNC1iNzdiLTNiY2QxMDg4Y2I1NCIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlVzZXIiLCJleHAiOjE3ODA0NDQ4MTQsImlzcyI6Imh0dHBzOi8vbG9jYWxob3N0OjgwMDEiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdDo4MDAxIn0.SpaQtj-D3KLWJflNUPb1q3NZ0SwKRamCErC_mw99jUA"
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мій сад"),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<Plant>>(
        future: _plantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Помилка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('🌱 Немає рослин'));
          } else {
            final plants = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                final imageUrl = (plant.plantImages != null && plant.plantImages!.isNotEmpty)
                    ? plant.plantImages!.first.url
                    : null;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/placeholder_plant.png') as ImageProvider,
                      backgroundColor: Colors.grey[200],
                    ),
                    title: Text(
                      plant.plantName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${plant.category} • ${plant.scientificTitle}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.green),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantCareInstructionsPage(plantId: plant.plantId),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
