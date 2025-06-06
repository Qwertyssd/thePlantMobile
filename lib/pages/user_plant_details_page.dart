import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theplantmobile/global.dart';
import 'package:theplantmobile/Models/Plant.dart';
import 'package:theplantmobile/Models/PlantCareInstruction.dart';
import 'package:theplantmobile/Models/PlantImage.dart';
import 'package:theplantmobile/Models/Reminder.dart';
import 'package:theplantmobile/Services/PlantService.dart';
import 'package:theplantmobile/Services/ReminderService.dart';
import 'package:theplantmobile/Services/PlantOverviewService.dart';
import 'package:theplantmobile/Models/OverviewType.dart';

class UserPlantDetailsPage extends StatefulWidget {
  final String plantId;
  final String userPlantId;

  const UserPlantDetailsPage({
    super.key,
    required this.plantId,
    required this.userPlantId,
  });

  @override
  State<UserPlantDetailsPage> createState() => _UserPlantDetailsPageState();
}

class _UserPlantDetailsPageState extends State<UserPlantDetailsPage> {
  late Future<Plant> _plantFuture;
  late Future<PlantCareInstruction> _careInstructionFuture;
  late Future<List<PlantImage>> _plantImagesFuture;
  late Future<List<PlantOverview>> _plantOverviewFuture;
  final ReminderService _reminderService = ReminderService();
  final String bearer = globalJwtToken ?? '';
  DateTime selectedDateTime = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedDateTime;
  @override
  void initState() {
    super.initState();
    _plantFuture = PlantService().getPlantById(widget.plantId, bearer);
    _careInstructionFuture =
        PlantService().getPlantCareInstructions(widget.plantId, bearer);
    _plantImagesFuture = PlantService().getPlantImages(widget.plantId, bearer);
    _plantOverviewFuture =
        PlantOverviewService().getPlantOverviewByPlantId(widget.plantId, bearer);


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
        return 'Water';
      case OverviewType.Sunlight:
        return 'Sunlight';
      case OverviewType.Fertilizer:
        return 'Fertilizer';
      default:
        return 'Unknown';
    }
  }

  Future<void> _showReminderDialog(int type) async {

    final durationController = TextEditingController(text: '7');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_getReminderTypeLabel(type)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.event),
                title: Text(
                  'Date & Time: ${DateFormat.yMd().add_Hm().format(selectedDateTime)}',
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (pickedTime != null) {
                      selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      Navigator.of(context).pop();
                      _showReminderDialog(type); // refresh dialog with updated dateTime
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Interval (days)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final durationDays = int.tryParse(durationController.text) ?? 7;
                await _createReminder(type, selectedDateTime, durationDays);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

  }

  String _getReminderTypeLabel(int type) {
    switch (type) {
      case 0:
        return 'Water';
      case 1:
        return 'Fertilizer';
      case 2:
        return 'Sunlight';
      default:
        return 'Reminder';
    }
  }

  Future<void> _createReminder(int type, DateTime date, int duration) async {
    try {
      final reminder = Reminder(
        reminderId: null,
        userPlantId: widget.userPlantId,
        dateOfReminder: date,
        reminderType: type,
        frequency: '$duration',
        status: 1,
        completionType: null,
        previousDate: DateTime.now(),
        userPlant: null,
      );

      final success = await _reminderService.createReminder(reminder, bearer);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Reminder created!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to create reminder.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
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
                  return Center(
                      child: Text(
                          '❌ Error loading images: ${imageSnapshot.error}'));
                } else {
                  final images = imageSnapshot.data ?? [];
                  return FutureBuilder<PlantCareInstruction>(
                    future: _careInstructionFuture,
                    builder: (context, careSnapshot) {
                      if (careSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (careSnapshot.hasError) {
                        return Center(
                            child: Text('❌ Error: ${careSnapshot.error}'));
                      } else {
                        final instruction = careSnapshot.data;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              Text(
                                plant.plantName,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
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
                              Text(
                                "Reminders:",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.water_drop),
                                    label: const Text("Water"),
                                    onPressed: () => _showReminderDialog(0),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.spa),
                                    label: const Text("Fertilizer"),
                                    onPressed: () => _showReminderDialog(1),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.wb_sunny),
                                    label: const Text("Sunlight"),
                                    onPressed: () => _showReminderDialog(2),
                                  ),
                                ],
                              ),
                              const Divider(height: 32, thickness: 2),
                              Text(
                                "Care Instructions:",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              if (instruction != null) ...[
                                Text(
                                  instruction.description,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Recommended frequency: ${instruction.frequencyRecommended}',
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
                                  '🌱 No instructions available',
                                  style: TextStyle(fontSize: 16),
                                ),
                              const Divider(height: 32, thickness: 2),
                              FutureBuilder<List<PlantOverview>>(
                                future: _plantOverviewFuture,
                                builder: (context, overviewSnapshot) {
                                  if (overviewSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (overviewSnapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            '❌ Error loading overview: ${overviewSnapshot.error}'));
                                  } else {
                                    final overviews =
                                        overviewSnapshot.data ?? [];
                                    return Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Plant Overview:",
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        if (overviews.isNotEmpty)
                                          ...overviews.map(
                                                (overview) => Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      _getOverviewIcon(
                                                          overview.overviewType),
                                                      color: _getOverviewColor(
                                                          overview.overviewType),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _getOverviewLabel(overview
                                                          .overviewType),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color:
                                                        _getOverviewColor(
                                                            overview
                                                                .overviewType),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  overview.description,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                const SizedBox(height: 12),
                                              ],
                                            ),
                                          )
                                        else
                                          const Text(
                                            '🌱 No overview available',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                      ],
                                    );
                                  }
                                },
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
