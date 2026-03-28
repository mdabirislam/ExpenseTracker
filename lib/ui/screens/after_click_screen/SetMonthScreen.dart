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

  DateTime? suggestedStartDate;
  int lastCycleDays = 30;

  bool _isSaving = false;
  bool autoNextMonth = false; // UI toggle for next month auto set

  @override
  void initState() {
    super.initState();
    existingMonths = AppState.allMonths;
    existingMonths.sort((a, b) => a.start.compareTo(b.start));

    final now = DateTime.now();

    // 🔥 detect running month
    runningMonth = existingMonths.where((m) {
      return now.isAfter(m.start.subtract(const Duration(days: 1))) &&
          now.isBefore(m.end.add(const Duration(days: 1)));
    }).isNotEmpty
        ? existingMonths.firstWhere((m) {
            return now.isAfter(m.start.subtract(const Duration(days: 1))) &&
                now.isBefore(m.end.add(const Duration(days: 1)));
          })
        : null;

    if (existingMonths.isNotEmpty) {
      final last = existingMonths.last;
      suggestedStartDate = last.end.add(const Duration(days: 1));
      lastCycleDays = detectBestCycle(existingMonths);

      if (runningMonth == null) {
        customStartDate = suggestedStartDate;
        startMode = 'custom';
        applyAutoEnd(customStartDate!);
      }
    }

    if (runningMonth != null) {
      startMode = 'custom';
      customStartDate = runningMonth!.start;
      final days = runningMonth!.end.difference(runningMonth!.start).inDays + 1;
      if (days >= 28 && days <= 31) {
        endSelection = days.toString();
      } else {
        endSelection = 'custom';
        customEndDate = runningMonth!.end;
      }
    }
  }

  // ================= SMART CYCLE =================
  int detectBestCycle(List<MonthRange> months) {
    if (months.isEmpty) return 30;
    final freq = <int, int>{};
    final cycles = <int>[];

    for (final m in months) {
      final days = m.end.difference(m.start).inDays + 1;
      cycles.add(days);
      freq[days] = (freq[days] ?? 0) + 1;
    }

    int best = cycles.first;
    int maxCount = 0;
    freq.forEach((days, count) {
      if (count > maxCount) {
        maxCount = count;
        best = days;
      }
    });

    if (maxCount == 1) {
      final avg = cycles.reduce((a, b) => a + b) / cycles.length;
      best = avg.round();
    }

    if (best < 25) best = 25;
    if (best > 35) best = 35;

    return best;
  }

  void applyAutoEnd(DateTime start) {
    if (lastCycleDays >= 28 && lastCycleDays <= 31) {
      endSelection = lastCycleDays.toString();
      customEndDate = null;
    } else {
      endSelection = 'custom';
      customEndDate = start.add(Duration(days: lastCycleDays - 1));
    }
  }

  // ================= HELPERS =================
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

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String format(DateTime? d) =>
      d == null ? "Not selected" : DateFormat('dd MMM yyyy').format(d);

  Future<bool> confirm(String msg) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Warning"),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Continue")),
        ],
      ),
    );
    return res ?? false;
  }

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

  // ================= LOGIC CHECK MODULES =================

  /// Logic Check 1: Current Month Conflict
  Future<bool> checkCurrentMonthConflict(DateTime start, DateTime end) async {
    final currentMonth = AppState.getCurrentMonthRange();
    if (currentMonth == null) return true;

    final newMonthName = DateFormat('MMMM yyyy').format(start);
    final currentMonthName = DateFormat('MMMM yyyy').format(currentMonth.start);

    if (newMonthName == currentMonthName) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Conflict"),
          content: Text(
              "Current month range already set:\nStart: ${format(currentMonth.start)}\nEnd: ${format(currentMonth.end)}\nYou can only change the end date."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Change End")),
          ],
        ),
      );
      return ok ?? false;
    }
    return true;
  }

  /// Logic Check 2: Overlap with existing months
  Future<bool> checkOverlap(DateTime start, DateTime end) async {
    for (final m in existingMonths) {
      if (runningMonth != null &&
          isSameDay(m.start, runningMonth!.start) &&
          isSameDay(m.end, runningMonth!.end)) continue;

      if (start.isBefore(m.end) && end.isAfter(m.start)) {
         showError(
            "Month ${DateFormat('MMMM yyyy').format(m.start)} already set.\nCannot change this range.");
        return false;
      }
    }
    return true;
  }

  /// Logic Check 3: Previous Month Gap
  Future<bool> checkPreviousMonthGap(DateTime start) async {
    if (existingMonths.isEmpty) return true;
    final previousMonth = existingMonths.lastWhere(
        (m) => m.end.isBefore(start),
        orElse: () => existingMonths.last);
    final expectedStart = previousMonth.end.add(const Duration(days: 1));
    if (!isSameDay(start, expectedStart)) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Gap Detected"),
          content: Text(
              "Previous month ended on ${format(previousMonth.end)}.\nYou have to start from ${format(expectedStart)}."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Start from ${format(expectedStart)}")),
          ],
        ),
      );
      if (ok ?? false) {
        setState(() {
          customStartDate = expectedStart;
          startMode = 'custom';
        });
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  /// Logic Check 4: Sequential Month Name Auto-fill
  Future<bool> checkSequentialMonthName(DateTime start, DateTime end) async {
    if (existingMonths.isEmpty) return true;

    final lastMonth = existingMonths.last;
    DateTime lastMonthPlusOne = DateTime(lastMonth.start.year, lastMonth.start.month + 1);

    if (!(start.year == lastMonthPlusOne.year &&
        start.month == lastMonthPlusOne.month)) {
      final missingMonths = <DateTime>[];
      DateTime temp = lastMonthPlusOne;
      while (temp.isBefore(start)) {
        missingMonths.add(temp);
        temp = DateTime(temp.year, temp.month + 1);
      }

      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Month Gap Detected"),
          content: Text(
              "Missing months: ${missingMonths.map((m) => DateFormat('MMMM yyyy').format(m)).join(', ')}\nDo you want to set them automatically?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Set Automatically")),
          ],
        ),
      );
      if (ok ?? false) {
        // Auto fill missing months
        DateTime fillStart = lastMonth.end.add(const Duration(days: 1));
        for (final mDate in missingMonths) {
          final endDate = DateTime(fillStart.year, fillStart.month + 1, 0);
          await AppState.saveMonth(MonthRange(
              start: fillStart,
              end: endDate,
              monthRef: DateTime(fillStart.year, fillStart.month)));
          fillStart = endDate.add(const Duration(days: 1));
        }
      }
    }
    return true;
  }

  // ================= SAVE =================
  void save() async {
    if (_isSaving) return;
    _isSaving = true;

    final start = getStartDate();
    final end = getEndDateSafe();

    if (end == null) {
      showError("Select end date");
      _isSaving = false;
      return;
    }

    final days = end.difference(start).inDays + 1;
    if (days < 25 || days > 35) {
      showError("Month must be 25–35 days");
      _isSaving = false;
      return;
    }

    // Run logic checks sequentially
    bool ok = await checkCurrentMonthConflict(start, end);
    if (!ok) {
      _isSaving = false;
      return;
    }

    ok = await checkOverlap(start, end);
    if (!ok) {
      _isSaving = false;
      return;
    }

    ok = await checkPreviousMonthGap(start);
    if (!ok) {
      _isSaving = false;
      return;
    }

    ok = await checkSequentialMonthName(start, end);
    if (!ok) {
      _isSaving = false;
      return;
    }

    // Save current month
    await AppState.saveMonth(MonthRange(
        start: start, end: end, monthRef: DateTime(start.year, start.month)));

    // Auto set next month if enabled
    if (autoNextMonth) {
      DateTime nextStart = end.add(const Duration(days: 1));
      final nextEnd = DateTime(nextStart.year, nextStart.month + 1, 0);
      await AppState.saveMonth(MonthRange(
          start: nextStart,
          end: nextEnd,
          monthRef: DateTime(nextStart.year, nextStart.month)));
    }

    _isSaving = false;
    Navigator.pop(context);
  }

  // ================= PICKERS =================
  Future<void> pickStartDate() async {
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
        applyAutoEnd(picked);
      });
    }
  }

  Future<void> handleEndDropdown(String val) async {
    if (val == 'custom') {
      final picked = await showDatePicker(
        context: context,
        initialDate: customEndDate ?? getStartDate(),
        firstDate: getStartDate(),
        lastDate: DateTime(2100),
      );
      if (picked == null) return;
      final days = picked.difference(getStartDate()).inDays + 1;
      if (days < 25 || days > 35) {
        showError("Month must be between 25–35 days");
        return;
      }
      setState(() {
        customEndDate = picked;
        endSelection = 'custom';
      });
    } else {
      setState(() {
        endSelection = val;
        customEndDate = null;
      });
    }
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
          const SizedBox(height: 10),
          if (suggestedStartDate != null && runningMonth == null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Smart Suggestion"),
                    Text("Start: ${format(suggestedStartDate)}"),
                    Text("Duration: $lastCycleDays days"),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            customStartDate = suggestedStartDate;
                            startMode = 'custom';
                            applyAutoEnd(suggestedStartDate!);
                          });
                        },
                        child: const Text("Apply"))
                  ]),
            ),
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
            onTap: pickStartDate,
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
            onChanged: (v) => handleEndDropdown(v!),
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