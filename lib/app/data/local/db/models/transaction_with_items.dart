import 'package:pos_app/app/data/local/db/app_database.dart';

class TransactionWithItems {
  final Transaction transaction;
  final List<TransactionItem> items;

  TransactionWithItems({required this.transaction, required this.items});
}
