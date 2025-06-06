import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theplantmobile/global.dart';
import 'package:theplantmobile/Models/Plant.dart';
import 'package:theplantmobile/Models/PlantCareInstruction.dart';
import 'package:theplantmobile/Models/PlantImage.dart';
import 'package:theplantmobile/Models/Reminder.dart';
import 'package:theplantmobile/Services/PlantService.dart';
import 'package:theplantmobile/Services/ReminderService.dart';

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
  final ReminderService _reminderService = ReminderService();
  final String bearer = globalJwtToken ?? '';

  @override
  void initState() {
    super.initState();
    _plantFuture = PlantService().getPlantById(widget.plantId, bearer);
    _careInstructionFuture =
        PlantService().getPlantCareInstructions(widget.plantId, bearer);
    _plantImagesFuture = PlantService().getPlantImages(widget.plantId, bearer);
  }

  Future<void> _showReminderDialog(int type) async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
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
                leading: const Icon(Icons.date_range),
                title: Text('Date: ${DateFormat.yMd().format(selectedDate)}'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                    Navigator.of(context).pop();
                    _showReminderDialog(type);
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
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: () async {
                final durationDays =
                    int.tryParse(durationController.text) ?? 7;
                await _createReminder(type, selectedDate, durationDays);
                Navigator.of(context).pop();
              },
              child: const Text('Зберегти'),
            ),
          ],
        );
      },
    );
  }

  String _getReminderTypeLabel(int type) {
    switch (type) {
      case 1:
        return 'Полив';
      case 2:
        return 'Оприскування';
      case 3:
        return 'Сонце';
      case 4:
        return 'Удобрення';
      default:
        return 'Нагадування';
    }
  }

  Future<void> _createReminder(int type, DateTime date, int duration) async {
    try {

      final reminderStatus = ReminderStatus.Pending;

      final reminder = Reminder(
        reminderId: null,
        userPlantId: widget.userPlantId,
        dateOfReminder: date,
        reminderType: type,
        frequency: '$duration',
        status: 0, // pending
        completionType: null,
        previousDate: DateTime.now(),
        userPlant: null,
      );

      // Додамо лог для виводу JSON перед відправкою
      final jsonBody = reminder.toJson();
      debugPrint('🔎 Reminder JSON: ${jsonBody}');

      final success = await _reminderService.createReminder(reminder, bearer);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Нагадування створено!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Не вдалося створити нагадування.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Помилка: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Деталі рослини")),
      body: FutureBuilder<Plant>(
        future: _plantFuture,
        builder: (context, plantSnapshot) {
          if (plantSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (plantSnapshot.hasError) {
            return Center(child: Text('❌ Помилка: ${plantSnapshot.error}'));
          } else if (!plantSnapshot.hasData) {
            return const Center(child: Text('🌱 Рослину не знайдено'));
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
                          '❌ Помилка при завантаженні фото: ${imageSnapshot.error}'));
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
                            child:
                            Text('❌ Помилка: ${careSnapshot.error}'));
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
                                'Категорія: ${plant.category}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Divider(height: 32, thickness: 2),
                              Text(
                                "Нагадування:",
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
                                    label: const Text("Watering"),
                                    onPressed: () => _showReminderDialog(0),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.spa),
                                    label: const Text("Fertilizing"),
                                    onPressed: () => _showReminderDialog(1),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.wb_sunny),
                                    label: const Text("Pruning"),
                                    onPressed: () => _showReminderDialog(2),
                                  ),

                                ],
                              ),
                              const Divider(height: 32, thickness: 2),
                              Text(
                                "Інструкції по догляду:",
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
                                  'Рекомендована частота: ${instruction.frequencyRecommended}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                if (instruction.note.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Примітка: ${instruction.note}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ] else
                                const Text(
                                  '🌱 Інструкції відсутні',
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
      ),
    );
  }
}

// Функції-конвертери
int reminderTypeToInt(ReminderType type) {
  switch (type) {
    case ReminderType.Watering:
      return 0;
    case ReminderType.Fertilizing:
      return 1;
    case ReminderType.Pruning:
      return 2;

    default:
      return 3;
  }
}

ReminderType reminderTypeFromInt(int value) {
  switch (value) {
    case 0:
      return ReminderType.Watering;
    case 1:
      return ReminderType.Fertilizing;
    case 2:
      return ReminderType.Pruning;
    case 3:
      return ReminderType.Unknown;
    default:
      return ReminderType.Unknown;
  }
}

int reminderStatusToInt(ReminderStatus status) {
  switch (status) {
    case ReminderStatus.Pending:
      return 0;
    case ReminderStatus.Completed:
      return 1;
    default:
      return 0;
  }
}
