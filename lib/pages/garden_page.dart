import 'package:flutter/material.dart';
import 'package:theplantmobile/Services/PlantService.dart';
import 'package:theplantmobile/Models/Plant.dart';

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
    _plantsFuture = PlantService().getPlants("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjgzYWIxNTRhLTcxOTItNGRkNC1iNzdiLTNiY2QxMDg4Y2I1NCIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlVzZXIiLCJleHAiOjE3ODA0NDQ4MTQsImlzcyI6Imh0dHBzOi8vbG9jYWxob3N0OjgwMDEiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdDo4MDAxIn0.SpaQtj-D3KLWJflNUPb1q3NZ0SwKRamCErC_mw99jUA" // полный токен
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Plant>>(
      future: _plantsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('❌ Ошибка: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('🌱 Нет растений'));
        } else {
          final plants = snapshot.data!;
          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return ListTile(
                title: Text(plant.plantName),
                subtitle: Text('${plant.category} | ${plant.scientificTitle}'),
              );
            },
          );
        }
      },
    );
  }
}
