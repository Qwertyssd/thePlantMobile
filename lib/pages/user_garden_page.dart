import 'package:flutter/material.dart';
import 'package:theplantmobile/Services/UserPlantsService.dart';
import 'package:theplantmobile/Models/UserPlant.dart';

class UserGardenPage extends StatefulWidget {
  final UserPlantService userPlantService;

  const UserGardenPage({Key? key, required this.userPlantService}) : super(key: key);

  @override
  State<UserGardenPage> createState() => _UserGardenPageState();
}

class _UserGardenPageState extends State<UserGardenPage> {
  late Future<List<UserPlant>> _futureUserPlants;

  @override
  void initState() {
    super.initState();
    // Викликаємо метод отримання рослин із сервісу
    _futureUserPlants = widget.userPlantService.getUserPlantsById();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мій сад'),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<UserPlant>>(
        future: _futureUserPlants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Помилка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('У вас поки що немає рослин у саду'));
          }

          final userPlants = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: userPlants.length,
            itemBuilder: (context, index) {
              final userPlant = userPlants[index];

              return GestureDetector(
                onTap: () {
                  // Тут можна додати відкриття деталей рослини
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: (userPlant.plant?.plantImages != null && userPlant.plant!.plantImages!.isNotEmpty)
                            ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.network(
                            userPlant.plant!.plantImages!.first.url,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                          ),
                          child: const Icon(Icons.local_florist, size: 80, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          userPlant.userPlantName ?? userPlant.plant?.plantName ?? 'Без назви',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
