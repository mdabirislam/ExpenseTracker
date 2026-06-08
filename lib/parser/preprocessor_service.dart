class PreprocessedText {
  final List<String> lines;
  final List<List<String>> blocks;

  PreprocessedText(this.lines, this.blocks);
}

class PreprocessorService {
  static PreprocessedText process(String text) {
    final rawLines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    List<String> lines = [];
    List<List<String>> blocks = [];

    bool inBlock = false;
    List<String> currentBlock = [];

    for (final line in rawLines) {
      if (line.contains('"""')) {
        inBlock = !inBlock;
        if (!inBlock && currentBlock.isNotEmpty) {
          blocks.add(List.from(currentBlock));
          currentBlock.clear();
        }
        continue;
      }

      if (inBlock) {
        currentBlock.add(line);
      } else {
        lines.add(line);
      }
    }

    return PreprocessedText(lines, blocks);
  }
}