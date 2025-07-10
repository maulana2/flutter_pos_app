import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_app/app/data/product_model.dart';
import 'package:pos_app/app/data/providers/product_provider.dart';
import 'package:pos_app/app/modules/home/widgets/cart_details_sheet.dart';
import 'package:pos_app/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final ProductProvider _productProvider = ProductProvider();

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = true.obs;
  final RxList<Product> productList = <Product>[].obs;
  final RxList<String> categoryList = <String>[].obs;
  final RxString selectedCategory = 'Semua'.obs;

  final RxMap<Product, int> cartItems = <Product, int>{}.obs;
  final RxDouble totalCartPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    fetchProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void fetchProducts() async {
    try {
      isLoading.value = true;
      var products = await _productProvider.getProducts();
      productList.assignAll(products);
      _extractCategories(products);
      if (categoryList.isNotEmpty) {
        selectedCategory.value = categoryList.first;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _extractCategories(List<Product> products) {
    var uniqueCategories = products.map((p) => p.category.trim()).toSet().toList();
    categoryList.assignAll(['Semua', ...uniqueCategories]);
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  List<Product> get filteredProducts {
    var filtered = productList.toList();

    if (selectedCategory.value != 'Semua') {
      filtered = filtered.where((p) => p.category == selectedCategory.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  void addToCart(Product product) {
    cartItems.update(
      product,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
    calculateTotalPrice();
  }

  void increaseQuantity(Product product) {
    cartItems.update(product, (value) => value + 1);
    calculateTotalPrice();
  }

  void decreaseQuantity(Product product) {
    if (cartItems[product] == 1) {
      cartItems.remove(product);
    } else {
      cartItems.update(product, (value) => value - 1);
    }
    calculateTotalPrice();
  }

  void removeFromCart(Product product) {
    cartItems.remove(product);
    calculateTotalPrice();
  }

  void confirmClearCart() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Anda yakin ingin mengosongkan seluruh keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              clearCart();
              Get.back();
            },
            child: const Text('Ya, Kosongkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void clearCart() {
    cartItems.clear();
    calculateTotalPrice();
  }

  void calculateTotalPrice() {
    double total = 0.0;
    cartItems.forEach((product, quantity) {
      total += product.price * quantity;
    });
    totalCartPrice.value = total;
  }

  void openCartDetails() {
    Get.bottomSheet(
      const CartDetailsSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }

  void goToCheckout() {
    if (cartItems.isEmpty) return;
    // Tidak perlu lagi mengirim argumen
    Get.toNamed(Routes.CHECKOUT);
  }
}
