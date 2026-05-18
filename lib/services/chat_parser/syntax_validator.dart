class SyntaxValidator {

  static bool isRandomMessage(String text) {

    final trimmed = text.trim();

    if (trimmed.isEmpty) return true;

    if (!trimmed.contains('-')) {
      return true;
    }

    return false;
  }
}