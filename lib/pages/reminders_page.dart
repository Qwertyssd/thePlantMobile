import 'package:flutter/material.dart';
import 'package:theplantmobile/Models/UserPlant.dart';
import 'package:theplantmobile/Models/Reminder.dart';
import 'package:theplantmobile/Services/UserPlantsService.dart';
import 'package:theplantmobile/Services/ReminderService.dart';
import 'package:theplantmobile/global.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => RemindersPageState();
}

class RemindersPageState extends State<RemindersPage> with RouteAware{




  final UserPlantService _userPlantService = UserPlantService(baseUrl: baseUrl!);
  final ReminderService _reminderService = ReminderService();

  late Future<List<_PlantWithReminders>> _plantsWithRemindersFuture;

  @override
  void initState() {
    super.initState();
    _plantsWithRemindersFuture = _loadData();
  }
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Регістрація у RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }
  void didPopNext() {

    setState(() {
      _plantsWithRemindersFuture = _loadData();
    });
  }

  @override
  void dispose() {
    // Відписуємося від RouteObserver
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  Future<List<_PlantWithReminders>> _loadData() async {
    final userPlants = await _userPlantService.getUserPlantsById();
    List<_PlantWithReminders> list = [];

    for (var plant in userPlants) {
      try {
        debugPrint('Отримуємо нагадування для рослини: ${plant.userPlantName} (${plant.userPlantId})');
        final reminders = await _reminderService.getUserPlantReminders(plant.userPlantId!, globalJwtToken!);
        list.add(_PlantWithReminders(plant, reminders));
      } catch (e) {
        debugPrint('❗ Помилка при отриманні нагадувань для ${plant.userPlantId}: $e');
        list.add(_PlantWithReminders(plant, []));
      }
    }

    return list;
  }


  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Нагадування по рослинам'),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<_PlantWithReminders>>(
        future: _plantsWithRemindersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Помилка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('⏰ Немає рослин або нагадувань'));
          } else {
            final plantsWithReminders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: plantsWithReminders.length,
              itemBuilder: (context, index) {
                final item = plantsWithReminders[index];
                final plantName = item.plant.userPlantName?.trim();
                final displayPlantName = (plantName != null && plantName.isNotEmpty)
                    ? plantName
                    : 'Невідома рослина';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Text(
                      '🌿 $displayPlantName',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: item.reminders.isEmpty
                        ? [
                      const ListTile(
                        title: Text('⏰ Немає нагадувань'),
                      )
                    ]
                        : item.reminders.map((r) {
                      // Валідація для кожного поля Reminder
                      final reminderType = r.reminderType ?? 'Невідомо';
                      final frequency = r.frequency ?? 'Невідомо';
                      final status = r.status ?? 'Невідомо';
                      final completionType = r.completionType ?? 'Невідомо';
                      final reminderDate = r.dateOfReminder;
                      final previousDate = r.previousDate;

                      final formattedReminderDate = (reminderDate != null)
                          ? _formatDate(reminderDate)
                          : 'Невідомо';
                      final formattedPreviousDate = (previousDate != null)
                          ? _formatDate(previousDate)
                          : 'Невідомо';

                      return ListTile(
                        title: Text('Тип: $reminderType'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Дата: $formattedReminderDate'),
                            Text('Частота: $frequency'),
                            Text('Статус: $status'),
                            Text('Тип завершення: $completionType'),
                            Text('Попередня дата: $formattedPreviousDate'),
                          ],
                        ),
                      );
                    }).toList(),
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

/// Модель-комбайн для тримання UserPlant і його нагадувань
class _PlantWithReminders {
  final UserPlant plant;
  final List<Reminder> reminders;

  _PlantWithReminders(this.plant, this.reminders);
}
