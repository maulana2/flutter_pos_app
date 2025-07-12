import 'package:get/get.dart';
import 'package:pos_app/app/data/local/db/app_database.dart';
import 'package:pos_app/app/data/services/database_service.dart';
import 'package:drift/drift.dart' as drift;

class ProductProvider {
  late final AppDatabase _db;

  ProductProvider() {
    _db = Get.find<DatabaseService>().db;
  }

  Future<List<Product>> getProducts() async {
    return await _db.select(_db.products).get();
  }

  Future<void> insertDummyProducts() async {
    final count = await _db.select(_db.products).get();
    if (count.isNotEmpty) return;

    await _db.batch((batch) {
      batch.insertAll(_db.products, [
        ProductsCompanion.insert(
          id: const drift.Value(1),
          name: 'Es Dawet Original',
          price: 8000.0,
          imageUrl: 'https://i.imgur.com/Fm7yU9c.jpg',
          category: 'Minuman Dingin',
          stock: const drift.Value(10),
        ),
        ProductsCompanion.insert(
          id: const drift.Value(2),
          name: 'Es Dawet Durian',
          price: 12000.0,
          imageUrl: 'https://i.imgur.com/nVnRITq.jpg',
          category: 'Minuman Dingin',
          stock: const drift.Value(5),
        ),
        ProductsCompanion.insert(
          id: const drift.Value(3),
          name: 'Es Dawet Alpukat',
          price: 10000.0,
          imageUrl: 'https://i.imgur.com/pbXwPfA.jpg',
          category: 'Minuman Dingin',
          stock: const drift.Value(0),
        ),
        ProductsCompanion.insert(
          id: const drift.Value(4),
          name: 'Tahu Bakso',
          price: 5000.0,
          imageUrl: 'https://i.imgur.com/4i1eVCv.jpg',
          category: 'Camilan',
          stock: const drift.Value(0),
        ),
        ProductsCompanion.insert(
          id: const drift.Value(5),
          name: 'Mendoan',
          price: 5000.0,
          imageUrl: 'https://i.imgur.com/13y6X5Y.jpg',
          category: 'Camilan',
          stock: const drift.Value(10),
        ),
      ]);
    });
  }
}
