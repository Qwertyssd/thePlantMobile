import 'package:flutter/material.dart';
import 'package:theplantmobile/Services/UserPlantsService.dart';
import 'package:theplantmobile/Models/UserPlant.dart';
import 'package:theplantmobile/global.dart';
import 'package:theplantmobile/Models/Plant.dart';
import 'package:theplantmobile/Services/PlantService.dart';
import 'package:theplantmobile/pages/plant_care_instructions_page.dart';
import 'package:theplantmobile/pages/user_plant_details_page.dart';
import 'package:theplantmobile/Models/PlantImage.dart';

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
      _futureUserPlants = _loadUserPlantsWithImages();
    });
  }

  Future<List<UserPlant>> _loadUserPlantsWithImages() async {
    final userPlants = await widget.userPlantService.getUserPlantsById();

    final updatedUserPlants = <UserPlant>[];
    for (final userPlant in userPlants) {
      Plant? plant = userPlant.plant;
      if (plant == null && userPlant.plantId != null) {
        plant = await widget.plantService.getPlantById(
          userPlant.plantId!,
          globalJwtToken!,
        );
      }

      List<PlantImage>? images;
      if (plant != null) {
        images = await widget.plantService.getPlantImages(
          userPlant.plantId!,
          globalJwtToken!,
        );
        plant = plant.copyWith(plantImages: images);
      }

      updatedUserPlants.add(
        userPlant.copyWith(plant: plant),
      );
    }

    return updatedUserPlants;
  }

  Future<void> _showAddUserPlantDialog() async {
    final _formKey = GlobalKey<FormState>();
    String? userPlantName;
    Plant? selectedPlant;

    List<Plant> plants;
    try {
      plants = await _futurePlants;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load plants: $e')),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add plant'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Plant>(
                  decoration: const InputDecoration(labelText: 'Choose plant'),
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
                  validator: (value) => value == null ? 'Choose plant' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Plaant name'),
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Type plant name' : null,
                  onSaved: (value) => userPlantName = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Add'),
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
        final success = await widget.userPlantService.addUserPlant(newUserPlant);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plant was added sucessfully')),
          );
          _refreshUserPlants();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to add plant')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My garden'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddUserPlantDialog,
            tooltip: 'Add plant',
          ),
        ],
      ),
      body: FutureBuilder<List<UserPlant>>(
        future: _futureUserPlants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You don`t have any plants in the garden'));
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
                  if (userPlant.plantId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserPlantDetailsPage(
                          plantId: userPlant.plantId!,
                          userPlantId: userPlant.userPlantId!,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Plant identifyer is missing')),
                    );
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              child: (userPlant.plant?.plantImages != null &&
                                  userPlant.plant!.plantImages!.isNotEmpty)
                                  ? Image.network(
                                userPlant.plant!.plantImages!.first.url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                                  : Container(
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                ),
                                child: const Icon(Icons.local_florist,
                                    size: 80, color: Colors.white),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 0,
                              child: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'delete') {
                                      print(userPlant.userPlantId);
                                      if (userPlant.userPlantId == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Plant identifyer is missing')),
                                        );
                                        return;
                                      }
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete the plant?'),
                                          content: const Text('Confirm deleting the plant?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('No'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          final success = await widget.userPlantService.deleteUserPlant(userPlant.userPlantId!);
                                          if (success) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Plant was deleted successfully')),
                                            );
                                            _refreshUserPlants();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Unable to delete the plant')),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Delete error: $e')),
                                          );
                                        }
                                      }
                                    }
                                  },

                                  itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit name'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete plant'),
                                  ),
                                ],
                                icon: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4), // білий напівпрозорий фон
                                    borderRadius: BorderRadius.circular(100), // круглий фон
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: const Icon(Icons.more_vert, color: Colors.white),
                                ),

                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                        child: Text(
                          userPlant.userPlantName ??
                              userPlant.plant?.plantName ??
                              'No name',
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
