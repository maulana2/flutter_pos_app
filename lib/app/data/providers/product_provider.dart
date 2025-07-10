import 'package:pos_app/app/data/models/product_model.dart';

class ProductProvider {
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Product(
        id: 1,
        name: 'Es Dawet Original',
        price: 8000.0,
        imageUrl: 'https://i.imgur.com/Fm7yU9c.jpg', // Gambar es dawet asli
        category: 'Minuman Dingin',
      ),
      Product(
        id: 2,
        name: 'Es Dawet Durian',
        price: 12000.0,
        imageUrl: 'https://i.imgur.com/nVnRITq.jpg', // Es dawet durian
        category: 'Minuman Dingin',
      ),
      Product(
        id: 3,
        name: 'Es Dawet Alpukat',
        price: 10000.0,
        imageUrl: 'https://i.imgur.com/pbXwPfA.jpg', // Es dawet + alpukat
        category: 'Minuman Dingin',
      ),
      Product(
        id: 4,
        name: 'Tahu Bakso',
        price: 5000.0,
        imageUrl: 'https://i.imgur.com/4i1eVCv.jpg', // Tahu bakso goreng
        category: 'Camilan',
      ),
      Product(
        id: 5,
        name: 'Mendoan',
        price: 5000.0,
        imageUrl: 'https://i.imgur.com/13y6X5Y.jpg', // Tempe mendoan
        category: 'Camilan',
      ),
    ];
  }
}
