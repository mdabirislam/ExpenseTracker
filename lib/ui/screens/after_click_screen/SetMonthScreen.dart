import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/local/app_state.dart';
import '../../../models/month_range_model.dart';

class SetMonthScreen extends StatefulWidget {
  const SetMonthScreen({super.key});

  @override
  State<SetMonthScreen> createState() => _SetMonthScreenState();
}

class _SetMonthScreenState extends State<SetMonthScreen> {
  String startMode = 'now';
  DateTime? customStartDate;

  String endSelection = '30';
  DateTime? customEndDate;

  List<MonthRange> existingMonths = [];
  MonthRange? runningMonth;

  bool _isSaving = false;
  bool autoNextMonth = false;

  @override
  void initState() {
    super.initState();
    existingMonths = AppState.allMonths;
    existingMonths.sort((a, b) => a.start.compareTo(b.start));
  }

  // ================= UTILS =================
  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime getDominantMonth(DateTime start, DateTime end) {
    final Map<String, int> monthDays = {};
    DateTime temp = start;

    while (!temp.isAfter(end)) {
      final key = "${temp.year}-${temp.month}";
      monthDays[key] = (monthDays[key] ?? 0) + 1;
      temp = temp.add(const Duration(days: 1));
    }

    String bestKey = monthDays.keys.first;
    int maxDays = 0;

    monthDays.forEach((key, days) {
      if (days > maxDays) {
        maxDays = days;
        bestKey = key;
      }
    });

    final entries =
        monthDays.entries.where((e) => e.value == maxDays).toList();

    if (entries.length > 1) {
      final endKey = "${end.year}-${end.month}";
      bestKey = entries.any((e) => e.key == endKey)
          ? endKey
          : entries.first.key;
    }

    final parts = bestKey.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  DateTime getStartDate() {
    final now = DateTime.now();
    switch (startMode) {
      case 'tomorrow':
        return now.add(const Duration(days: 1));
      case 'yesterday':
        return now.subtract(const Duration(days: 1));
      case 'custom':
        return customStartDate ?? now;
      default:
        return now;
    }
  }

  DateTime? getEndDateSafe() {
    final start = getStartDate();
    if (endSelection == 'custom') return customEndDate;
    final days = int.tryParse(endSelection);
    if (days == null) return null;
    return start.add(Duration(days: days - 1));
  }

  String format(DateTime? d) =>
      d == null ? "Not selected" : DateFormat('dd MMM yyyy').format(d);

  void showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Warning"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  // ================= SAVE =================
  void save() async {
    if (_isSaving) return;
    _isSaving = true;

    final start = normalize(getStartDate());
    final endRaw = getEndDateSafe();

    if (endRaw == null) {
      showError("Select end date");
      _isSaving = false;
      return;
    }

    final end = normalize(endRaw);

    final days = end.difference(start).inDays + 1;
    if (days < 25 || days > 35) {
      showError("Month must be 25–35 days");
      _isSaving = false;
      return;
    }

    final dominantMonth = getDominantMonth(start, end);

    await AppState.saveMonth(MonthRange(
      start: start,
      end: end,
      monthRef: dominantMonth,
    ));

    if (autoNextMonth) {
      DateTime nextStart = end.add(const Duration(days: 1));
      final nextEnd =
          DateTime(nextStart.year, nextStart.month + 1, 0);

      final nextDominant =
          getDominantMonth(nextStart, nextEnd);

      await AppState.saveMonth(MonthRange(
        start: nextStart,
        end: nextEnd,
        monthRef: nextDominant,
      ));
    }

    _isSaving = false;
    Navigator.pop(context);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final start = getStartDate();
    final end = getEndDateSafe();

    return Scaffold(
      appBar: AppBar(title: const Text("Set Month")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Start: ${format(start)}"),
          Text("End: ${format(end)}"),

          const SizedBox(height: 20),

          const Text("Start Date"),
          RadioListTile(
              value: 'now',
              groupValue: startMode,
              onChanged: (v) => setState(() => startMode = v!),
              title: const Text("Now")),
          RadioListTile(
              value: 'tomorrow',
              groupValue: startMode,
              onChanged: (v) => setState(() => startMode = v!),
              title: const Text("Tomorrow")),
          RadioListTile(
              value: 'yesterday',
              groupValue: startMode,
              onChanged: (v) => setState(() => startMode = v!),
              title: const Text("Yesterday")),

          ListTile(
            title: const Text("Custom Start"),
            subtitle: Text(format(customStartDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: customStartDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  customStartDate = picked;
                  startMode = 'custom';
                });
              }
            },
          ),

          const Divider(),

          const Text("Duration"),
          DropdownButton<String>(
            value: endSelection,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: '28', child: Text("28 days")),
              DropdownMenuItem(value: '29', child: Text("29 days")),
              DropdownMenuItem(value: '30', child: Text("30 days")),
              DropdownMenuItem(value: '31', child: Text("31 days")),
              DropdownMenuItem(value: 'custom', child: Text("Select by Date")),
            ],
            onChanged: (v) async {
              if (v == 'custom') {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: getStartDate(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    customEndDate = picked;
                    endSelection = 'custom';
                  });
                }
              } else {
                setState(() {
                  endSelection = v!;
                  customEndDate = null;
                });
              }
            },
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Checkbox(
                  value: autoNextMonth,
                  onChanged: (v) => setState(() => autoNextMonth = v!)),
              const Text("Set Next Month Automatically")
            ],
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: _isSaving ? null : save,
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}