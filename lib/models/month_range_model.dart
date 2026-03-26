import 'package:hive/hive.dart';

part 'month_range_model.g.dart';

@HiveType(typeId: 1)
class MonthRange extends HiveObject {
  @HiveField(0)
  DateTime start;

  @HiveField(1)
  DateTime end;

  @HiveField(2)
  String monthName;

  MonthRange({
    required this.start,
    required this.end,
    required this.monthName,
  });
}