import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './models/transaction_model.dart';
import './models/transaction_type.dart';
import 'ui/screens/main_screen.dart';
import './data/local/app_state.dart';
import 'models/debt_data_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Adapter register
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionDataAdapter());
  Hive.registerAdapter(DebtDataAdapter());

  // Box open
  await Hive.openBox<TransactionData>('transactions');
  await Hive.openBox<DebtData>('debts');

  // Load App State
  await AppState.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}
