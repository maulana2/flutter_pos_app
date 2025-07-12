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
  final RxList<Product> filteredProductList = <Product>[].obs; // ✅ Added separate filtered list
  final RxList<String> categoryList = <String>[].obs;
  final RxString selectedCategory = 'Semua'.obs;

  final RxMap<Product, int> cartItems = <Product, int>{}.obs;
  final RxDouble totalCartPrice = 0.0.obs;

  // ✅ Added debouncing for search
  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();
    _initializeSearchListener();
    fetchProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchWorker?.dispose(); // ✅ Properly dispose worker
    super.onClose();
  }

  // ✅ Separate method for search initialization
  void _initializeSearchListener() {
    _searchWorker = debounce(
      searchQuery,
      (_) => _applyFilters(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final products = await _productProvider.getProducts();
      productList.assignAll(products);
      _extractCategories(products);
      _applyFilters(); // ✅ Apply filters after fetching
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memuat produk: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _extractCategories(List<Product> products) {
    final uniqueCategories = products
        .map((p) => p.category?.trim() ?? '')
        .where((cat) => cat.isNotEmpty)
        .toSet()
        .toList();

    uniqueCategories.sort(); // Sort categories alphabetically

    final finalCategories = ['Semua', ...uniqueCategories];
    categoryList.assignAll(finalCategories);

    // ✅ Ensure default category is set
    if (selectedCategory.value.isEmpty || !finalCategories.contains(selectedCategory.value)) {
      selectedCategory.value = 'Semua';
    }

    print('Categories extracted: $finalCategories'); // Debug log
    print('Selected category: ${selectedCategory.value}'); // Debug log
  }

  void changeCategory(String category) {
    final normalizedCategory = category.trim();
    print('Changing category to: "$normalizedCategory"'); // ✅ Debug log
    print('Previous category: "${selectedCategory.value}"'); // ✅ Debug log

    selectedCategory.value = normalizedCategory;

    print('New category set: "${selectedCategory.value}"'); // ✅ Debug log

    _applyFilters();

    // ✅ Force UI update if needed
    update(['categoryTabs']);
  }

  // ✅ Updated search method
  void updateSearchQuery(String query) {
    searchQuery.value = query.trim();
  }

  // ✅ Improved filtering logic
  void _applyFilters() {
    print('Applying filters - Selected category: "${selectedCategory.value}"'); // Debug log
    print('Search query: "${searchQuery.value}"'); // Debug log

    var filtered = productList.toList();

    // Filter by category
    if (selectedCategory.value != 'Semua') {
      final selectedCat = selectedCategory.value.toLowerCase().trim();
      filtered =
          filtered.where((p) => (p.category?.toLowerCase().trim() ?? '') == selectedCat).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered
          .where((p) =>
              (p.name?.toLowerCase() ?? '').contains(query) ||
              (p.category?.toLowerCase() ?? '').contains(query))
          .toList();
    }

    // Sort by name
    filtered.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    filteredProductList.assignAll(filtered);

    print('Filtered products count: ${filtered.length}'); // Debug log

    // ✅ Force update for observers
    update(['productGrid', 'categoryTabs']);
  }

  // ✅ Getter for filtered products
  List<Product> get filteredProducts => filteredProductList.toList();

  // ✅ Improved add to cart with stock validation
  void addToCart(Product product) {
    // Validate stock
    if ((product.stock ?? 0) <= 0) {
      Get.snackbar(
        'Stok Habis',
        '${product.name} tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Check if adding one more exceeds stock
    final currentQty = cartItems[product] ?? 0;
    if (currentQty >= (product.stock ?? 0)) {
      Get.snackbar(
        'Stok Tidak Cukup',
        'Maksimal ${product.stock} item untuk ${product.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    cartItems.update(product, (qty) => qty + 1, ifAbsent: () => 1);
    _calculateTotalPrice();

    Get.snackbar(
      'Berhasil',
      '${product.name} ditambahkan ke keranjang',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // ✅ Improved quantity management with stock validation
  void increaseQuantity(Product product) {
    final currentQty = cartItems[product] ?? 0;
    if (currentQty >= (product.stock ?? 0)) {
      Get.snackbar(
        'Stok Tidak Cukup',
        'Maksimal ${product.stock} item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    cartItems.update(product, (qty) => qty + 1);
    _calculateTotalPrice();
  }

  void decreaseQuantity(Product product) {
    if (!cartItems.containsKey(product)) return;

    if (cartItems[product] == 1) {
      cartItems.remove(product);
    } else {
      cartItems.update(product, (qty) => qty - 1);
    }
    _calculateTotalPrice();
  }

  void removeFromCart(Product product) {
    cartItems.remove(product);
    _calculateTotalPrice();
  }

  // ✅ Private method with proper error handling
  void _calculateTotalPrice() {
    try {
      double total = 0.0;
      cartItems.forEach((product, qty) {
        total += (product.price ?? 0.0) * qty;
      });
      totalCartPrice.value = total;
    } catch (e) {
      print('Error calculating total price: $e');
      totalCartPrice.value = 0.0;
    }
  }

  void clearCart() {
    cartItems.clear();
    _calculateTotalPrice();
  }

  // ✅ Improved dialog
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
              Get.snackbar(
                'Berhasil',
                'Keranjang telah dikosongkan',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Ya, Kosongkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void openCartDetails() {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Keranjang Kosong',
        'Tambahkan produk ke keranjang terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

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
    if (cartItems.isEmpty) {
      Get.snackbar('Keranjang Kosong', 'Tidak ada item untuk checkout');
      return;
    }

    if (Get.isBottomSheetOpen ?? false) Get.back();
    Get.toNamed(Routes.CHECKOUT);
  }

  // ✅ Enhanced quick actions
  void showQuickActions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Data'),
              onTap: () {
                Get.back();
                fetchProducts();
              },
            ),
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
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Manajemen Produk'),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.PRODUCT_MANAGEMENT);
              },
            ),
            if (cartItems.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.clear_all, color: Colors.red),
                title: const Text('Kosongkan Keranjang', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  confirmClearCart();
                },
              ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  void showNotifications() {
    // ✅ Get low stock products
    final lowStockProducts = productList.where((p) => (p.stock ?? 0) <= 5).toList();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.notifications),
            SizedBox(width: 8),
            Text('Notifikasi'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lowStockProducts.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: const Text('Stok Rendah'),
                  subtitle: Text('${lowStockProducts.length} produk memiliki stok rendah'),
                ),
                ...lowStockProducts.take(3).map(
                      (product) => ListTile(
                        title: Text(product.name ?? ''),
                        subtitle: Text('Stok: ${product.stock}'),
                        trailing: Icon(
                          Icons.inventory_2,
                          color: (product.stock ?? 0) == 0 ? Colors.red : Colors.orange,
                        ),
                      ),
                    ),
                if (lowStockProducts.length > 3)
                  ListTile(
                    title: Text('dan ${lowStockProducts.length - 3} produk lainnya...'),
                  ),
              ] else
                const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Semua Stok Aman'),
                  subtitle: Text('Tidak ada produk dengan stok rendah'),
                ),
            ],
          ),
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
