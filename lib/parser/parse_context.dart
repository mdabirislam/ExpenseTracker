class ParseContext {
  DateTime currentDate = DateTime.now();
  String? currentGroup;

  void setDate(DateTime d) {
    currentDate = d;
    currentGroup = null;
  }

  void setGroup(String? g) {
    currentGroup = g;
  }
}