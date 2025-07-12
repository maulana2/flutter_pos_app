import 'package:drift/drift.dart';
import 'transactions.dart';

@DataClassName('TransactionItem')
class TransactionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id)();
  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  RealColumn get productPrice => real()();
  IntColumn get quantity => integer()();
}
