import 'package:flutter/material.dart';
import 'package:theplantmobile/Models/Reminder.dart';

class AddReminderDialog extends StatefulWidget {
  final Function(Reminder) onAdd;

  const AddReminderDialog({super.key, required this.onAdd});

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _dateOfReminder;
  late int _reminderType;
  String _frequency = '';
  int _status = 0;
  String _completionType = '';
  late DateTime _previousDate;
  String _userPlant = '';

  @override
  void initState() {
    super.initState();
    _dateOfReminder = DateTime.now();
    _previousDate = DateTime.now();
    _reminderType = 0;
  }

  Future<void> _selectDate(BuildContext context, bool isReminderDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isReminderDate ? _dateOfReminder : _previousDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isReminderDate) {
          _dateOfReminder = picked;
        } else {
          _previousDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Додати нагадування'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'User Plant ID'),
                validator: (value) => value == null || value.isEmpty ? 'Введіть User Plant ID' : null,
                onSaved: (value) => _userPlant = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Frequency'),
                onSaved: (value) => _frequency = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Completion Type'),
                onSaved: (value) => _completionType = value ?? '',
              ),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Reminder Type'),
                value: _reminderType,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Type 0')),
                  DropdownMenuItem(value: 1, child: Text('Type 1')),
                ],
                onChanged: (val) => setState(() => _reminderType = val ?? 0),
              ),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _status,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Status 0')),
                  DropdownMenuItem(value: 1, child: Text('Status 1')),
                ],
                onChanged: (val) => setState(() => _status = val ?? 0),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Дата нагадування: '),
                  TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text('${_dateOfReminder.toLocal()}'.split(' ')[0]),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Попередня дата: '),
                  TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text('${_previousDate.toLocal()}'.split(' ')[0]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Скасувати'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Додати'),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();

              final newReminder = Reminder(
                reminderId: '', // сервер сам створить ID
                userPlantId: _userPlant,
                dateOfReminder: _dateOfReminder,
                reminderType: _reminderType,
                frequency: _frequency,
                status: _status,
                completionType: _completionType,
                previousDate: _previousDate,
                userPlant: _userPlant,
              );

              widget.onAdd(newReminder);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}