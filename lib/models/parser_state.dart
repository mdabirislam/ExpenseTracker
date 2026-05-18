enum ParserState {
  idle,
  readingDate,
  readingTransaction,
  readingMultilineNote,
  completed,
  error,
}