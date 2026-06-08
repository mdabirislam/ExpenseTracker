class TransactionLexer {

  static List<String> tokenize(String input) {

    return input
        .split('\n')
        .map((e) => e.trimRight())
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }
}