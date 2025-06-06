import 'package:flutter/material.dart';
import 'package:theplantmobile/Services/PlantService.dart';
import 'package:theplantmobile/Models/Plant.dart';
import 'package:theplantmobile/Models/PlantImage.dart';
import 'package:theplantmobile/pages/plant_care_instructions_page.dart';
import 'package:theplantmobile/global.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  List<Plant> _allPlants = [];
  List<Plant> _filteredPlants = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlants() async {
    try {
      String jwtToken = globalJwtToken ?? "";
      final plants = await PlantService().getPlants(jwtToken);

      for (final plant in plants) {
        try {
          final images = await PlantService().getPlantImages(plant.plantId, jwtToken);
          plant.plantImages = images;
        } catch (e) {
          print('⚠️ Не вдалося завантажити фото для рослини ${plant.plantName}: $e');
          plant.plantImages = [];
        }
      }

      setState(() {
        _allPlants = plants;
        _filteredPlants = plants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPlants = List.from(_allPlants);
      } else {
        _filteredPlants = _allPlants.where((plant) {
          return plant.plantName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("The Plant"),
        backgroundColor: Colors.green[700],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Searching plants...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('❌ Error: $_error'))
          : _filteredPlants.isEmpty
          ? const Center(child: Text('No results found'))
          : ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _filteredPlants.length,
        itemBuilder: (context, index) {
          final plant = _filteredPlants[index];
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
                      builder: (context) => PlantCareInstructionsPage(plantId: plant.plantId!),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
