class MultilineNoteHandler {

  static bool isMultilineToken(String line) {

    return line.trim() == '\"\"\"';
  }
}