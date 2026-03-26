import 'package:flutter/material.dart';
import '../../../data/local/app_state.dart';
// import '../../../models/month_range_model.dart';
import '../../../utils/date_utils.dart';
class MonthSettings {
  DateTime? startDate;
  String startMode; // now | tomorrow | yesterday | custom
  String endMode;   // auto | fixed
  int fixedDays;

  MonthSettings({
    this.startDate,
    this.startMode = 'now',
    this.endMode = 'auto',
    this.fixedDays = 30,
  });
}

class SetMonthScreen extends StatefulWidget {
  final MonthSettings? initialSettings;

  const SetMonthScreen({super.key, this.initialSettings});

  @override
  State<SetMonthScreen> createState() => _SetMonthScreenState();
}

class _SetMonthScreenState extends State<SetMonthScreen> {
  late MonthSettings settings;
  bool isCustomDays = false;

  @override
  void initState() {
    super.initState();

    // ১. যদি initialSettings আছে → use that
    if (widget.initialSettings != null) {
      settings = widget.initialSettings!;
    } else {
      // ২. Hive থেকে current month range read
      final current = AppState.getCurrentMonthRange();
      if (current != null) {
        settings = MonthSettings(
          startDate: current.start,
          startMode: 'custom',
          endMode: 'fixed',
          fixedDays: current.end.difference(current.start).inDays + 1,
        );
      } else {
        settings = MonthSettings(); // default
      }
    }

    if (settings.startDate != null) {
      settings.startMode = 'custom';
    }
    if (settings.fixedDays != 30) {
      isCustomDays = true;
    }
  }

  DateTime getCalculatedStartDate() {
    final now = DateTime.now();
    switch (settings.startMode) {
      case 'tomorrow':
        return now.add(const Duration(days: 1));
      case 'yesterday':
        return now.subtract(const Duration(days: 1));
      case 'custom':
        return settings.startDate ?? now;
      default:
        return now;
    }
  }

  DateTime getCalculatedEndDate() {
    final start = getCalculatedStartDate();
    switch (settings.endMode) {
      case 'fixed':
        return start.add(Duration(days: settings.fixedDays - 1));
      case 'auto':
        return start.add(Duration(days: settings.fixedDays - 1));
      default:
        return start.add(Duration(days: settings.fixedDays - 1));
    }
  }

  String getMonthNameFromRange(DateTime start, DateTime end) {
    return _monthName(start.month);
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month];
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: settings.startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        settings.startDate = picked;
        settings.startMode = 'custom';
      });
    }
  }

  bool get isCustomDaysValid =>
      !isCustomDays || (settings.fixedDays >= 20 && settings.fixedDays <= 40);

  void _save() async {
    if (!isCustomDaysValid) return;

    final start = getCalculatedStartDate();
    final end = getCalculatedEndDate();
    final name = getMonthNameFromRange(start, end);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Month Range"),
        content: Text(
          "Month: $name\nStart: ${formatDate(start)}\nEnd: ${formatDate(end)}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Hive এ save
              await AppState.addMonthRange(
                start: start,
                end: end,
                monthName: name,
              );
              // saved settings return
              Navigator.pop(context, MonthSettings(
                startDate: start,
                startMode: 'custom',
                endMode: settings.endMode,
                fixedDays: settings.fixedDays,
              ));
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startPreview = formatDate(getCalculatedStartDate());
    final endPreview = formatDate(getCalculatedEndDate());

    return Scaffold(
      appBar: AppBar(title: const Text("Set Month")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Start New Month", style: TextStyle(fontWeight: FontWeight.bold)),
          Column(
            children: [
              RadioListTile(
                value: 'now',
                groupValue: settings.startMode,
                onChanged: (val) => setState(() => settings.startMode = val!),
                title: const Text("Now"),
              ),
              RadioListTile(
                value: 'tomorrow',
                groupValue: settings.startMode,
                onChanged: (val) => setState(() => settings.startMode = val!),
                title: const Text("Tomorrow"),
              ),
              RadioListTile(
                value: 'yesterday',
                groupValue: settings.startMode,
                onChanged: (val) => setState(() => settings.startMode = val!),
                title: const Text("Yesterday"),
              ),
            ],
          ),
          ListTile(
            title: const Text("Custom Date"),
            subtitle: Text(settings.startMode == 'custom'
                ? formatDate(settings.startDate ?? DateTime.now())
                : "Select date"),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          const Divider(),
          const Text("End Of Month", style: TextStyle(fontWeight: FontWeight.bold)),
          Column(
            children: [
              RadioListTile(
                value: 'auto',
                groupValue: settings.endMode,
                onChanged: (val) => setState(() => settings.endMode = val!),
                title: const Text("Auto"),
              ),
              RadioListTile(
                value: 'fixed',
                groupValue: settings.endMode,
                onChanged: (val) => setState(() => settings.endMode = val!),
                title: const Text("Fixed Duration"),
              ),
            ],
          ),
          if (settings.endMode == 'fixed')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile(
                        value: false,
                        groupValue: isCustomDays,
                        onChanged: (val) => setState(() {
                          isCustomDays = val!;
                          if (!isCustomDays) settings.fixedDays = 30;
                        }),
                        title: const Text("Preset"),
                      ),
                      RadioListTile(
                        value: true,
                        groupValue: isCustomDays,
                        onChanged: (val) => setState(() => isCustomDays = val!),
                        title: const Text("Custom"),
                      ),
                      if (!isCustomDays)
                        DropdownButton<int>(
                          value: settings.fixedDays <= 31 ? settings.fixedDays : 30,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 28, child: Text("28 days")),
                            DropdownMenuItem(value: 29, child: Text("29 days")),
                            DropdownMenuItem(value: 30, child: Text("30 days")),
                            DropdownMenuItem(value: 31, child: Text("31 days")),
                          ],
                          onChanged: (val) => setState(() => settings.fixedDays = val!),
                        ),
                      if (isCustomDays)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Custom Days",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                final num = int.tryParse(val);
                                if (num != null && num > 0) setState(() => settings.fixedDays = num);
                              },
                            ),
                            if (!isCustomDaysValid)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  "Custom days must be between 20–40",
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          Text("Start: $startPreview"),
          Text("End: $endPreview"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isCustomDaysValid ? _save : null,
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}