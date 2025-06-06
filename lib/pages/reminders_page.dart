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

class RemindersPageState extends State<RemindersPage> with RouteAware {
  final UserPlantService _userPlantService = UserPlantService(baseUrl: baseUrl!);
  final ReminderService _reminderService = ReminderService();

  late Future<List<_PlantWithReminders>> _plantsWithRemindersFuture;

  @override
  void initState() {
    super.initState();
    _plantsWithRemindersFuture = _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    setState(() {
      _plantsWithRemindersFuture = _loadData();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<List<_PlantWithReminders>> _loadData() async {
    final userPlants = await _userPlantService.getUserPlantsById();
    List<_PlantWithReminders> list = [];

    for (var plant in userPlants) {
      try {
        debugPrint('Fetching reminders for plant: ${plant.userPlantName} (${plant.userPlantId})');
        final reminders = await _reminderService.getUserPlantReminders(plant.userPlantId!, globalJwtToken!);

        for (var reminder in reminders) {
          await _reminderService.checkAndUpdateReminderStatus(reminder, globalJwtToken!);
        }

        list.add(_PlantWithReminders(plant, reminders));
      } catch (e) {
        debugPrint('❗ Error fetching reminders for ${plant.userPlantId}: $e');
        list.add(_PlantWithReminders(plant, []));
      }
    }

    return list;
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    try {
      bool success = await _reminderService.deleteReminder(reminder.reminderId!, globalJwtToken!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Reminder deleted')),
        );
        setState(() {
          _plantsWithRemindersFuture = _loadData();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error deleting reminder: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour}:${date.minute}";
  }

  String getReminderTypeLabel(int type) {
    switch (type) {
      case 0:
        return 'Watering';
      case 1:
        return 'Pruning';
      case 2:
        return 'Fertilizing';
      default:
        return 'Unknown';
    }
  }

  String getReminderStatusLabel(int status) {
    switch (status) {
      case 0:
        return 'Waiting';
      case 1:
        return 'Completed';
      case 2:
        return 'Overdue';
      default:
        return 'Unknown';
    }
  }

  Future<void> _markReminderCompleted(Reminder reminder) async {
    try {
      bool success = await _reminderService.updateReminderStatus(reminder, 1, globalJwtToken!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Reminder marked as completed')),
        );
        setState(() {
          _plantsWithRemindersFuture = _loadData();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error marking reminder: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Reminders'),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<_PlantWithReminders>>(
        future: _plantsWithRemindersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('⏰ No plants or reminders found'));
          } else {
            final plantsWithReminders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: plantsWithReminders.length,
              itemBuilder: (context, index) {
                final item = plantsWithReminders[index];
                final plantName = item.plant.userPlantName?.trim();
                final displayPlantName =
                (plantName != null && plantName.isNotEmpty)
                    ? plantName
                    : 'Unknown Plant';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Text(
                      '🌿 $displayPlantName',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: item.reminders.isEmpty
                        ? [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('⏰ No reminders for this plant.'),
                      )
                    ]
                        : List<Widget>.generate(
                      item.reminders.length * 2 - 1,
                          (i) {
                        if (i.isOdd) {
                          return const Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(
                              color: Colors.grey,
                              thickness: 0.5,
                            ),
                          );
                        }
                        final r = item.reminders[i ~/ 2];
                        final reminderType =
                        getReminderTypeLabel(r.reminderType);
                        final frequency =
                            r.frequency ?? 'Unknown';
                        final status =
                        getReminderStatusLabel(r.status);
                        final completionType =
                            r.completionType ?? 'Unknown';
                        final formattedReminderDate =
                        (r.dateOfReminder != null)
                            ? _formatDate(r.dateOfReminder!)
                            : 'Unknown';
                        final formattedPreviousDate =
                        (r.previousDate != null)
                            ? _formatDate(r.previousDate!)
                            : 'Unknown';

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              title: Text(
                                reminderType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 7),
                                  _buildRow(
                                    icon: Icons.calendar_today,
                                    text:
                                    'Next date: $formattedReminderDate',
                                  ),
                                  _buildRow(
                                    icon: Icons.history,
                                    text: 'Frequency: $frequency',
                                  ),
                                  _buildRow(
                                    icon: Icons.info,
                                    text: 'Status: $status',
                                  ),
                                  _buildRow(
                                    icon: Icons.event_repeat,
                                    text:
                                    'Completion type: $completionType',
                                  ),
                                  _buildRow(
                                    icon: Icons.access_time,
                                    text:
                                    'Last date: $formattedPreviousDate',
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.check_circle,
                                      color: (r.status == 0 ||
                                          r.status == 2)
                                          ? Colors.green[700]
                                          : Colors.grey,
                                    ),
                                    tooltip: 'Mark as Done',
                                    onPressed: (r.status == 0 ||
                                        r.status == 2)
                                        ? () =>
                                        _markReminderCompleted(r)
                                        : null,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red[400],
                                    ),
                                    tooltip: 'Delete reminder',
                                    onPressed: () {
                                      _deleteReminder(r);
                                    },
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantWithReminders {
  final UserPlant plant;
  final List<Reminder> reminders;

  _PlantWithReminders(this.plant, this.reminders);
}
