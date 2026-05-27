import '../../data/local/app_state.dart';
import '../../models/transaction_model.dart';

class SaveAllTransactionsService {

  static Future<void> saveAll(List txs) async {

    for (final tx in txs) {

      await AppState.addTransaction(tx);
    }
  }
}