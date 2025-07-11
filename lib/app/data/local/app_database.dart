import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// --- Mendefinisikan Tabel ---

@DataClassName('Product')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get imageUrl => text()();
  TextColumn get category => text()();
  IntColumn get stock => integer().withDefault(const Constant(0))(); // ✅ tambahkan ini
}

@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionId => text().unique()();
  DateTimeColumn get date => dateTime()();
  RealColumn get subtotal => real()();
  RealColumn get discount => real()();
  RealColumn get tax => real()();
  RealColumn get grandTotal => real()();
  TextColumn get paymentMethod => text()();
  RealColumn get cashAmount => real()();
  RealColumn get cashChange => real()();
  TextColumn get orderType => text()();
  TextColumn get notes => text().nullable()();
}

@DataClassName('TransactionItem')
class TransactionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id)();
  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  RealColumn get productPrice => real()();
  IntColumn get quantity => integer()();
}

// --- Class untuk menggabungkan data ---
class TransactionWithItems {
  final Transaction transaction;
  final List<TransactionItem> items;

  TransactionWithItems({required this.transaction, required this.items});
}

// --- Mendefinisikan Database Utama ---

@DriftDatabase(tables: [Products, Transactions, TransactionItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- Operasi Query ---

  Future<void> saveTransaction(TransactionWithItems transactionWithItems) {
    return transaction(() async {
      // PERBAIKAN: Membuat Companion secara manual dan MENGHILANGKAN ID.
      // Ini memungkinkan database untuk auto-increment.
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

      // Ini akan memasukkan baris baru dan mengembalikan ID yang baru dibuat.
      final insertedTransactionId = await into(transactions).insert(transactionCompanion);

      for (final item in transactionWithItems.items) {
        await into(transactionItems).insert(
          TransactionItemsCompanion.insert(
            transactionId: insertedTransactionId, // Gunakan ID yang baru dibuat
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
    // Mengurutkan berdasarkan tanggal terbaru di atas
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
