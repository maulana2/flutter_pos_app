import 'package:get/get.dart';
import 'package:pos_app/app/data/local/db/app_database.dart';
import 'package:pos_app/app/data/providers/product_provider.dart';
import 'package:drift/drift.dart' as drift;

class ProductService {
  final ProductProvider _productProvider = Get.find<ProductProvider>();
  
  Future<List<Product>> getAllProducts() async {
    return await _productProvider.getProducts();
  }
  
  Future<Product> getProductById(int id) async {
    final products = await _productProvider.getProducts();
    return products.firstWhere((product) => product.id == id);
  }
  
  Future<int> addProduct(String name, double price, String imageUrl, String category, int stock) async {
    final db = Get.find<AppDatabase>();
    return await db.into(db.products).insert(
      ProductsCompanion.insert(
        name: name,
        price: price,
        imageUrl: imageUrl,
        category: category,
        stock: drift.Value(stock),
      ),
    );
  }
  
  Future<bool> updateProduct(int id, String name, double price, String imageUrl, String category, int stock) async {
    final db = Get.find<AppDatabase>();
    return await db.update(db.products).replace(
      Product(
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        category: category,
        stock: stock,
      ),
    );
  }
  
  Future<int> deleteProduct(int id) async {
    final db = Get.find<AppDatabase>();
    return await (db.delete(db.products)..where((tbl) => tbl.id.equals(id))).go();
  }
}