import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_app/app/data/local/db/app_database.dart';
import 'package:pos_app/app/data/services/product_service.dart';

class ProductManagementController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  // State untuk menyimpan daftar produk
  final RxList<Product> products = <Product>[].obs;

  // State untuk form
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final imageUrlController = TextEditingController();
  final categoryController = TextEditingController();
  final stockController = TextEditingController();

  // State untuk produk yang sedang diedit
  final Rx<Product?> selectedProduct = Rx<Product?>(null);

  // State untuk loading
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    categoryController.dispose();
    stockController.dispose();
    super.onClose();
  }

  // Mengambil semua produk
  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      products.value = await _productService.getAllProducts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil data produk: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Menambahkan produk baru
  Future<void> addProduct() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        await _productService.addProduct(
          nameController.text,
          double.parse(priceController.text),
          imageUrlController.text,
          categoryController.text,
          int.parse(stockController.text),
        );
        Get.back(); // Tutup dialog
        fetchProducts(); // Refresh daftar produk
        Get.snackbar(
          'Sukses',
          'Produk berhasil ditambahkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal menambahkan produk: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Memperbarui produk yang ada
  Future<void> updateProduct() async {
    if (formKey.currentState!.validate() && selectedProduct.value != null) {
      isLoading.value = true;
      try {
        await _productService.updateProduct(
          selectedProduct.value!.id,
          nameController.text,
          double.parse(priceController.text),
          imageUrlController.text,
          categoryController.text,
          int.parse(stockController.text),
        );
        Get.back(); // Tutup dialog
        fetchProducts(); // Refresh daftar produk
        Get.snackbar(
          'Sukses',
          'Produk berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal memperbarui produk: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Menghapus produk
  Future<void> deleteProduct(int id) async {
    isLoading.value = true;
    try {
      await _productService.deleteProduct(id);
      fetchProducts(); // Refresh daftar produk
      Get.snackbar(
        'Sukses',
        'Produk berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus produk: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Menampilkan dialog form tambah produk
  void showAddProductDialog() {
    // Reset form
    resetForm();
    selectedProduct.value = null;

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tambah Produk Baru',
                style: Get.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildProductForm(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: addProduct,
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menampilkan dialog form edit produk
  void showEditProductDialog(Product product) {
    // Set nilai form dari produk yang dipilih
    selectedProduct.value = product;
    nameController.text = product.name;
    priceController.text = product.price.toString();
    imageUrlController.text = product.imageUrl;
    categoryController.text = product.category;
    stockController.text = product.stock.toString();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Produk',
                style: Get.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildProductForm(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: updateProduct,
                    child: const Text('Perbarui'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menampilkan dialog konfirmasi hapus produk
  void showDeleteConfirmation(Product product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus produk ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Reset form
  void resetForm() {
    nameController.clear();
    priceController.clear();
    imageUrlController.clear();
    categoryController.clear();
    stockController.clear();
  }

  // Widget form produk
  Widget _buildProductForm() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nama Produk'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama produk tidak boleh kosong';
              }
              return null;
            },
          ),
          TextFormField(
            controller: priceController,
            decoration: const InputDecoration(labelText: 'Harga'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harga tidak boleh kosong';
              }
              if (double.tryParse(value) == null) {
                return 'Harga harus berupa angka';
              }
              return null;
            },
          ),
          TextFormField(
            controller: imageUrlController,
            decoration: const InputDecoration(labelText: 'URL Gambar'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'URL gambar tidak boleh kosong';
              }
              return null;
            },
          ),
          TextFormField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Kategori'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kategori tidak boleh kosong';
              }
              return null;
            },
          ),
          TextFormField(
            controller: stockController,
            decoration: const InputDecoration(labelText: 'Stok'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Stok tidak boleh kosong';
              }
              if (int.tryParse(value) == null) {
                return 'Stok harus berupa angka';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
