import 'package:get/get.dart';
import 'package:pos_app/app/data/local/db/models/transaction_with_items.dart';
import 'package:pos_app/app/data/services/database_service.dart';

class TransactionService extends GetxService {
  late final DatabaseService _databaseService;

  final RxList<TransactionWithItems> transactionList = <TransactionWithItems>[].obs;

  Future<TransactionService> init() async {
    _databaseService = Get.find<DatabaseService>(); // ✅ ambil dari Get.put sebelumnya
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
