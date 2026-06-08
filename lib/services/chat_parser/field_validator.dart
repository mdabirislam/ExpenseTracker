class FieldValidator {

  static String? validateAmount(String? amount) {
    if (amount == null) return "Missing amount";
    if (double.tryParse(amount) == null) return "Invalid amount";
    return null;
  }

  static String? validateSource(String source) {
    if (source.trim().isEmpty) return "Missing source";
    return null;
  }

  static String? validateCategory(String category) {
    if (category.trim().isEmpty) return "Missing category";
    return null;
  }
}