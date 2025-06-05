import 'package:flutter/material.dart';
import 'package:theplantmobile/Services/UserPlantsService.dart';
import 'package:theplantmobile/Models/UserPlant.dart';
import 'package:theplantmobile/global.dart';
import 'package:theplantmobile/Models/Plant.dart';
import 'package:theplantmobile/Services/PlantService.dart';
import 'package:theplantmobile/pages/plant_care_instructions_page.dart';
import 'package:theplantmobile/pages/user_plant_details_page.dart';

class UserGardenPage extends StatefulWidget {
  final PlantService plantService;
  final UserPlantService userPlantService;

  const UserGardenPage({
    Key? key,
    required this.plantService,
    required this.userPlantService,
  }) : super(key: key);

  @override
  State<UserGardenPage> createState() => _UserGardenPageState();
}

class _UserGardenPageState extends State<UserGardenPage> {
  late Future<List<UserPlant>> _futureUserPlants;
  late Future<List<Plant>> _futurePlants;

  @override
  void initState() {
    super.initState();
    _refreshUserPlants();
    _futurePlants = widget.plantService.getPlants(globalJwtToken!);
  }

  void _refreshUserPlants() {
    setState(() {
      _futureUserPlants = widget.userPlantService.getUserPlantsById();
    });
  }

  Future<void> _showAddUserPlantDialog() async {
    final _formKey = GlobalKey<FormState>();
    String? userPlantName;
    Plant? selectedPlant;

    // Завантажуємо список рослин, якщо ще не завантажено
    List<Plant> plants;
    try {
      plants = await _futurePlants;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка завантаження рослин: $e')),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Додати рослину'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Plant>(
                  decoration: const InputDecoration(labelText: 'Оберіть рослину'),
                  items: plants.map((plant) {
                    return DropdownMenuItem(
                      value: plant,
                      child: Text(plant.plantName),
                    );
                  }).toList(),
                  onChanged: (plant) {
                    setState(() {
                      selectedPlant = plant;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Виберіть рослину' : null,
                ),
                TextFormField(
                  decoration:
                  const InputDecoration(labelText: 'Назва рослини'),
                  validator: (value) =>
                  (value == null || value.isEmpty)
                      ? 'Введіть назву рослини'
                      : null,
                  onSaved: (value) => userPlantName = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Скасувати')),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Додати'),
            ),
          ],
        ),
      ),
    );

    if (result == true && selectedPlant != null && userPlantName != null) {
      final newUserPlant = UserPlant(
        userPlantId: null,
        userId: globalUserId ?? " ",
        plantId: selectedPlant!.plantId,
        userPlantName: userPlantName,
      );

      try {
        final success =
        await widget.userPlantService.addUserPlant(newUserPlant);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Рослину додано успішно')),
          );
          _refreshUserPlants();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не вдалося додати рослину')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мій сад'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddUserPlantDialog,
            tooltip: 'Додати рослину',
          ),
        ],
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
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
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
                  if (userPlant.plantId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserPlantDetailsPage(
                            plantId: userPlant.plantId!,
                          userPlantId: userPlant.userPlantId! ,

                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ідентифікатор рослини відсутній')),
                    );
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: (userPlant.plant?.plantImages != null &&
                            userPlant.plant!.plantImages!.isNotEmpty)
                            ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15)),
                          child: Image.network(
                            userPlant.plant!.plantImages!.first.url,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15)),
                          ),
                          child: const Icon(Icons.local_florist,
                              size: 80, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          userPlant.userPlantName ??
                              userPlant.plant?.plantName ??
                              'Без назви',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
