import 'package:get/get.dart';
import 'package:pos_app/app/data/local/app_database.dart';
import 'package:pos_app/app/data/services/database_service.dart';

class TransactionService extends GetxService {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  final RxList<TransactionWithItems> transactionList = <TransactionWithItems>[].obs;

  Future<TransactionService> init() async {
    await loadTransactionsFromDb();
    return this;
  }

  Future<void> loadTransactionsFromDb() async {
    final transactions = await _databaseService.db.getAllTransactionsWithItems();
    transactionList.assignAll(transactions);
  }

  Future<void> addTransaction(TransactionWithItems transaction) async {
    await _databaseService.db.saveTransaction(transaction);
    transactionList.insert(0, transaction);
  }
}
