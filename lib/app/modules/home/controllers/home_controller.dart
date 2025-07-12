import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_app/app/data/local/db/app_database.dart';
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
      applyFilters();
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
      final products = await _productProvider.getProducts();
      productList.assignAll(products);
      _extractCategories(products);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat produk: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _extractCategories(List<Product> products) {
    final uniqueCategories = products
        .map((p) => (p.category ?? '').trim())
        .where((cat) => cat.isNotEmpty)
        .toSet()
        .toList();
    categoryList.assignAll(['Semua', ...uniqueCategories]);
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  List<Product> get filteredProducts {
    var filtered = productList.toList();

    if (selectedCategory.value != 'Semua') {
      filtered = filtered
          .where((p) =>
              (p.category ?? '').toLowerCase().trim() ==
              selectedCategory.value.toLowerCase().trim())
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((p) => (p.name ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    // Optional: Sort by name
    filtered.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    return filtered;
  }

  void applyFilters() {
    // Just triggers UI updates via Obx or UI watching `filteredProducts`
    update();
  }

  void addToCart(Product product) {
    cartItems.update(product, (qty) => qty + 1, ifAbsent: () => 1);
    calculateTotalPrice();
    Get.snackbar(
      'Berhasil',
      '${product.name} ditambahkan ke keranjang',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void increaseQuantity(Product product) {
    cartItems.update(product, (qty) => qty + 1);
    calculateTotalPrice();
  }

  void decreaseQuantity(Product product) {
    if (!cartItems.containsKey(product)) return;
    if (cartItems[product] == 1) {
      cartItems.remove(product);
    } else {
      cartItems.update(product, (qty) => qty - 1);
    }
    calculateTotalPrice();
  }

  void removeFromCart(Product product) {
    cartItems.remove(product);
    calculateTotalPrice();
  }

  void calculateTotalPrice() {
    double total = 0.0;
    cartItems.forEach((product, qty) {
      total += product.price * qty;
    });
    totalCartPrice.value = total;
  }

  void clearCart() {
    cartItems.clear();
    calculateTotalPrice();
  }

  void confirmClearCart() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Anda yakin ingin mengosongkan seluruh keranjang?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
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

  void openCartDetails() {
    if (cartItems.isEmpty) return;

    Get.bottomSheet(
      const CartDetailsSheet(),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  void goToCheckout() {
    if (cartItems.isEmpty) return;
    if (Get.isBottomSheetOpen ?? false) Get.back();
    Get.toNamed(Routes.CHECKOUT);
  }

  void showQuickActions() {
    Get.bottomSheet(
      Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifikasi'),
            onTap: () {
              Get.back();
              showNotifications();
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Riwayat Transaksi'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.HISTORY);
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  void showNotifications() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.notifications),
            SizedBox(width: 8),
            Text('Notifikasi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('Stok Rendah'),
              subtitle: Text('Beberapa produk memiliki stok kurang dari 5'),
            ),
            ListTile(
              leading: Icon(Icons.update, color: Colors.blue),
              title: Text('Update Sistem'),
              subtitle: Text('Aplikasi telah diperbarui ke versi terbaru'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
