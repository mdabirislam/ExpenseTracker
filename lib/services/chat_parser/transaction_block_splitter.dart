class TransactionBlockSplitter {

  static List<String> split(String input) {
    final lines = input
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    List<String> blocks = [];
    String buffer = "";

    for (final line in lines) {
      if (RegExp(r'^\d{1,2}[-/.]\d{1,2}').hasMatch(line)) {
        if (buffer.isNotEmpty) {
          blocks.add(buffer.trim());
          buffer = "";
        }
      }
      buffer += "$line\n";
    }

    if (buffer.isNotEmpty) {
      blocks.add(buffer.trim());
    }

    return blocks;
  }
}