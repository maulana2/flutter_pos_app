import 'package:drift/drift.dart';

@DataClassName('Product')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get imageUrl => text()();
  TextColumn get category => text()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
}
