//__________for automatic making of ....g.dart_______
// flutter packages pub run build_runner build --delete-conflicting-outputs

import 'package:hive/hive.dart';

part 'month_range_model.g.dart';

@HiveType(typeId: 1)
class MonthRange extends HiveObject {
  @HiveField(0)
  DateTime start;

  @HiveField(1)
  DateTime end;

  @HiveField(2)
  DateTime monthRef; // 🔥 main identifier

  MonthRange({
    required this.start,
    required this.end,
    required this.monthRef,
  });
}