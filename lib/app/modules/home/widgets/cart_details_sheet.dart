import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/app/data/models/product_model.dart';
import 'package:pos_app/app/modules/home/controllers/home_controller.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_text_styles.dart';

class CartDetailsSheet extends GetView<HomeController> {
  const CartDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Obx(
                  () {
                    if (controller.cartItems.isEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Get.back();
                      });
                      return const Center(child: Text('Keranjang kosong.'));
                    }
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: controller.cartItems.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 20, endIndent: 20),
                      itemBuilder: (context, index) {
                        Product product = controller.cartItems.keys.elementAt(index);
                        int quantity = controller.cartItems[product]!;
                        return _buildDismissibleCartItem(product, quantity);
                      },
                    );
                  },
                ),
              ),
              _buildBottomSummary(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Text('Detail Pesanan', style: AppTextStyles.heading),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(
              () => controller.cartItems.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => controller.confirmClearCart(),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleCartItem(Product product, int quantity) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        controller.removeFromCart(product);
        Get.snackbar(
          'Dihapus',
          '${product.name} telah dihapus dari pesanan.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
        );
      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_sweep, color: Colors.white),
      ),
      child: _CartListItem(product: product, quantity: quantity),
    );
  }

  Widget _buildBottomSummary() {
    return Obx(
      () => controller.cartItems.isEmpty
          ? const SizedBox.shrink()
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                            .format(controller.totalCartPrice.value),
                        style: AppTextStyles.heading,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.goToCheckout(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Lanjut ke Pembayaran',
                        style: AppTextStyles.button.copyWith(color: AppColors.text),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CartListItem extends StatelessWidget {
  final Product product;
  final int quantity;
  const _CartListItem({required this.product, required this.quantity});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade200),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                      .format(product.price),
                  style: AppTextStyles.body.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: () => controller.decreaseQuantity(product),
                  color: AppColors.text,
                ),
                Text(
                  quantity.toString(),
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () => controller.increaseQuantity(product),
                  color: AppColors.text,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
