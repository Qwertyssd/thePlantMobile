import 'package:flutter/material.dart';
import 'package:theplantmobile/Models/Reminder.dart';
import 'package:theplantmobile/Services/ReminderService.dart';
import 'package:theplantmobile/pages/add_remainder_dialog.dart';
class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  // Задаємо userId і token тут:
  final String _userId = 'A60647F6-C96A-45E4-B0B6-2641ED33CB8E'; // <-- замініть на свій userId
  final String _token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjgzYWIxNTRhLTcxOTItNGRkNC1iNzdiLTNiY2QxMDg4Y2I1NCIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlVzZXIiLCJleHAiOjE3ODA0NDQ4MTQsImlzcyI6Imh0dHBzOi8vbG9jYWxob3N0OjgwMDEiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdDo4MDAxIn0.SpaQtj-D3KLWJflNUPb1q3NZ0SwKRamCErC_mw99jUA'; // <-- замініть на свій токен

  late Future<List<Reminder>> _remindersFuture;
  final ReminderService _reminderService = ReminderService();
  @override
  void initState() {
    super.initState();
    _remindersFuture = ReminderService().getUserReminders(_userId, _token);
  }
  void _loadReminders() {
    setState(() {
      _remindersFuture = _reminderService.getUserReminders(_userId, _token);
    });
  }
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2,'0')}.${date.month.toString().padLeft(2,'0')}.${date.year}";
  }
  void _onAddReminder(Reminder reminder) async {
    final success = await _reminderService.createReminder(reminder, _token);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Нагадування додано')));
      _loadReminders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Не вдалося додати нагадування')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Нагадування'),
        backgroundColor: Colors.green[700],
    actions: [
    IconButton(
    icon: const Icon(Icons.add),
    onPressed: () {
    showDialog(context: context, builder: (context) => AddReminderDialog(onAdd: _onAddReminder),
    );
    },
    ),
    ],
      ),
      body: FutureBuilder<List<Reminder>>(
        future: _remindersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Помилка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('⏰ Немає нагадувань'));
          } else {
            final reminders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final r = reminders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    title: Text('Нагадування для рослини: ${r.userPlant}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Дата: ${_formatDate(r.dateOfReminder)}'),
                        Text('Тип нагадування: ${r.reminderType}'),
                        Text('Частота: ${r.frequency}'),
                        Text('Статус: ${r.status}'),
                        Text('Тип завершення: ${r.completionType}'),
                        Text('Попередня дата: ${_formatDate(r.previousDate)}'),
                      ],
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
