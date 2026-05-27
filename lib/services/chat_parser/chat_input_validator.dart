class ChatInputValidator {

  static List<String> validate(String input) {
    List<String> errors = [];

    if (input.trim().isEmpty) {
      errors.add("Empty message not allowed");
    }

    if (!input.contains('-')) {
      errors.add("Missing '-' transaction separator");
    }

    if (!RegExp(r'\d{1,2}[-/.]\d{1,2}').hasMatch(input)) {
      errors.add("No valid date found");
    }

    return errors;
  }
}