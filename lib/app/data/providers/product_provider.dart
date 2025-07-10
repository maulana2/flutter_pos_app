import 'package:pos_app/app/data/local/app_database.dart';

class ProductProvider {
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      const Product(
        id: 1,
        name: 'Es Dawet Original',
        price: 8000.0,
        imageUrl: 'https://i.imgur.com/Fm7yU9c.jpg',
        category: 'Minuman Dingin',
      ),
      const Product(
        id: 2,
        name: 'Es Dawet Durian',
        price: 12000.0,
        imageUrl: 'https://i.imgur.com/nVnRITq.jpg',
        category: 'Minuman Dingin',
      ),
      const Product(
        id: 3,
        name: 'Es Dawet Alpukat',
        price: 10000.0,
        imageUrl: 'https://i.imgur.com/pbXwPfA.jpg',
        category: 'Minuman Dingin',
      ),
      const Product(
        id: 4,
        name: 'Tahu Bakso',
        price: 5000.0,
        imageUrl: 'https://i.imgur.com/4i1eVCv.jpg',
        category: 'Camilan',
      ),
      const Product(
        id: 5,
        name: 'Mendoan',
        price: 5000.0,
        imageUrl: 'https://i.imgur.com/13y6X5Y.jpg',
        category: 'Camilan',
      ),
    ];
  }
}
