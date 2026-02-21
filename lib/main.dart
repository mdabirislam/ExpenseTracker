
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './models/transaction_model.dart';
import 'ui/screens/main_screen.dart';
import './data/local/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
      // ───────── Hive Init ─────────
    await Hive.initFlutter();

  // ───────── Register Adapters ─────────
    Hive.registerAdapter(TransactionDataAdapter());

  // ───────── Open Boxes ─────────
    await Hive.openBox<TransactionData>('transactions');

  // ───────── Load App State from Hive ─────────
    await AppState.init();
  } catch (e) {
    debugPrint('Init error: $e');
  }

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
