import 'package:flutter/material.dart';
import 'package:theplantmobile/Models/Reminder.dart';



// Мапери
ReminderType reminderTypeFromInt(int value) {
  switch (value) {
    case 0:
      return ReminderType.Watering;
    case 1:
      return ReminderType.Fertilizing;
    case 2:
      return ReminderType.Pruning;
    default:
      return ReminderType.Unknown;
  }
}

int reminderTypeToInt(ReminderType type) {
  switch (type) {
    case ReminderType.Watering:
      return 0;
    case ReminderType.Fertilizing:
      return 1;
    case ReminderType.Pruning:
      return 2;
    default:
      return -1;
  }
}

String reminderTypeToString(ReminderType type) {
  switch (type) {
    case ReminderType.Watering:
      return 'Watering';
    case ReminderType.Fertilizing:
      return 'Fertilizing';
    case ReminderType.Pruning:
      return 'Pruning';
    default:
      return 'Unknown';
  }
}

ReminderStatus reminderStatusFromInt(int value) {
  switch (value) {
    case 0:
      return ReminderStatus.Pending;
    case 1:
      return ReminderStatus.Completed;
    case 2:
      return ReminderStatus.Snoozed;
    default:
      return ReminderStatus.Pending;
  }
}

int reminderStatusToInt(ReminderStatus status) {
  switch (status) {
    case ReminderStatus.Pending:
      return 0;
    case ReminderStatus.Completed:
      return 1;
    case ReminderStatus.Snoozed:
      return 2;
    default:
      return 0;
  }
}

String reminderStatusToString(ReminderStatus status) {
  switch (status) {
    case ReminderStatus.Pending:
      return 'Pending';
    case ReminderStatus.Completed:
      return 'Completed';
    case ReminderStatus.Snoozed:
      return 'Snoozed';
    default:
      return 'Pending';
  }
}

class AddReminderDialog extends StatefulWidget {
  final Function(Reminder) onAdd;

  const AddReminderDialog({super.key, required this.onAdd});

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _dateOfReminder;
  late DateTime _previousDate;
  ReminderType _reminderType = ReminderType.Unknown;
  ReminderStatus _status = ReminderStatus.Pending;
  String _frequency = '';
  String _completionType = '';
  String _userPlant = '';

  @override
  void initState() {
    super.initState();
    _dateOfReminder = DateTime.now();
    _previousDate = DateTime.now();
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
      title: const Text('Add reminder'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'User Plant ID'),
                validator: (value) => value == null || value.isEmpty ? 'Insert User Plant ID' : null,
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
              const SizedBox(height: 8),
              DropdownButtonFormField<ReminderType>(
                decoration: const InputDecoration(labelText: 'Reminder Type'),
                value: _reminderType,
                items: ReminderType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(reminderTypeToString(type)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _reminderType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReminderStatus>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _status,
                items: ReminderStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(reminderStatusToString(status)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _status = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('REminder Date: '),
                  TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text('${_dateOfReminder.toLocal()}'.split(' ')[0]),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Previous Date: '),
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
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Add'),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              int remType = reminderTypeToInt(_reminderType);
              int status = reminderStatusToInt(_status);
              final newReminder = Reminder(
                reminderId: '', // сервер створює ID
                userPlantId: _userPlant,
                dateOfReminder: _dateOfReminder,
                reminderType: (remType),
                frequency: _frequency,
                status: (status),
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
