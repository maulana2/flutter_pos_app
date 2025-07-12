import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_app/app/data/local/db/app_database.dart';
import 'package:pos_app/app/modules/product_management/controllers/product_management_controller.dart';
import 'package:pos_app/app/modules/product_management/widgets/product_card.dart';
import 'package:pos_app/core/theme/app_colors.dart';

class ProductManagementView extends GetView<ProductManagementController> {
  const ProductManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildProductList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.showAddProductDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daftar Produk',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Obx(() => controller.isLoading.value
            ? const CircularProgressIndicator()
            : IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.fetchProducts,
                tooltip: 'Refresh',
              )),
      ],
    );
  }

  Widget _buildProductList() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory,
                  size: 64,
                  color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada produk',
                  style: Theme.of(Get.context!).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tambahkan produk baru dengan menekan tombol + di bawah',
                  style: Theme.of(Get.context!).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return ProductCard(
              product: product,
              onEdit: () => controller.showEditProductDialog(product),
              onDelete: () => controller.showDeleteConfirmation(product),
            );
          },
        );
      }),
    );
  }
}
