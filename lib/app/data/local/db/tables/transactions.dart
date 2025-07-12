import 'package:drift/drift.dart';

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
