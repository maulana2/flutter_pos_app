import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/products.dart';
import 'tables/transactions.dart';
import 'tables/transaction_items.dart';
import 'models/transaction_with_items.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Products, Transactions, TransactionItems],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> saveTransaction(TransactionWithItems transactionWithItems) {
    return transaction(() async {
      final transactionCompanion = TransactionsCompanion.insert(
        transactionId: transactionWithItems.transaction.transactionId,
        date: transactionWithItems.transaction.date,
        subtotal: transactionWithItems.transaction.subtotal,
        discount: transactionWithItems.transaction.discount,
        tax: transactionWithItems.transaction.tax,
        grandTotal: transactionWithItems.transaction.grandTotal,
        paymentMethod: transactionWithItems.transaction.paymentMethod,
        cashAmount: transactionWithItems.transaction.cashAmount,
        cashChange: transactionWithItems.transaction.cashChange,
        orderType: transactionWithItems.transaction.orderType,
        notes: Value(transactionWithItems.transaction.notes),
      );

      final insertedTransactionId = await into(transactions).insert(transactionCompanion);

      for (final item in transactionWithItems.items) {
        await into(transactionItems).insert(
          TransactionItemsCompanion.insert(
            transactionId: insertedTransactionId,
            productId: item.productId,
            productName: item.productName,
            productPrice: item.productPrice,
            quantity: item.quantity,
          ),
        );
      }
    });
  }

  Future<List<TransactionWithItems>> getAllTransactionsWithItems() async {
    final transactionList = await (select(transactions)
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();

    final List<TransactionWithItems> result = [];

    for (final t in transactionList) {
      final items =
          await (select(transactionItems)..where((tbl) => tbl.transactionId.equals(t.id))).get();
      result.add(TransactionWithItems(transaction: t, items: items));
    }

    return result;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
