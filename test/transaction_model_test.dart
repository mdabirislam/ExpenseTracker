// File: test/transaction_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import '../lib/models/transaction_model.dart';
import '../lib/models/transaction_type.dart';

void main() {
  late Box<TransactionData> box;

  setUpAll(() async {
    // Temporary directory Hive এর জন্য
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    // Adapter register
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionDataAdapter());

    // Open test box
    box = await Hive.openBox<TransactionData>('test_transactions');
  });

  tearDownAll(() async {
    await box.clear();
    await box.close();
  });

  test('Save TransactionData', () async {
    final tx = TransactionData(
      type: TransactionType.income,
      amount: 1500,
      source: 'Salary',
      note: 'Monthly income',
      date: DateTime.now(),
    );

    // Save to Hive
    await box.add(tx);

    // Check values
    final stored = box.values.first;
    print('Stored Transaction: type=${stored.type}, amount=${stored.amount}, source=${stored.source}');

    expect(stored.type, TransactionType.income);
    expect(stored.amount, 1500);
    expect(stored.source, 'Salary');
  });
}