class ParsedLine {
  final String source;
  final String raw;
  final String? note;

  ParsedLine({
    required this.source,
    required this.raw,
    this.note,
  });
}