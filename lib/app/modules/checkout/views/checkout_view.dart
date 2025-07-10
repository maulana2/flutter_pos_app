import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_text_styles.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Pembayaran'),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionCard(
                  title: 'Item Pesanan',
                  child: _buildOrderItemsList(),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Opsi Pesanan',
                  child: Column(
                    children: [
                      _buildOrderTypeSelector(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Rincian Biaya',
                  child: _buildCostDetails(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ],
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child, EdgeInsets? padding}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: (padding != null ? 0 : 0), bottom: (padding != null ? 8 : 0)),
              child: Text(title,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            if (padding == null) const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.orderItems.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final product = controller.orderItems.keys.elementAt(index);
        final quantity = controller.orderItems[product]!;
        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('x$quantity'),
                ],
              ),
            ),
            Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(product.price * quantity),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderTypeSelector() {
    return Obx(() => SegmentedButton<OrderType>(
          segments: const <ButtonSegment<OrderType>>[
            ButtonSegment<OrderType>(
              value: OrderType.dineIn,
              label: Text('Makan di Tempat'),
              icon: Icon(Icons.restaurant),
            ),
            ButtonSegment<OrderType>(
              value: OrderType.takeAway,
              label: Text('Bawa Pulang'),
              icon: Icon(Icons.shopping_bag),
            ),
          ],
          selected: <OrderType>{controller.orderType.value},
          onSelectionChanged: (Set<OrderType> newSelection) {
            controller.setOrderType(newSelection.first);
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.primary,
            selectedForegroundColor: AppColors.white,
            selectedBackgroundColor: AppColors.primary,
          ),
        ));
  }

  Widget _buildNotesField() {
    return TextField(
      controller: controller.notesController,
      decoration: InputDecoration(
        hintText: 'Contoh: Tidak pedas, bungkus terpisah',
        labelText: 'Catatan Pesanan (Opsional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      maxLines: 2,
    );
  }

  Widget _buildCostDetails() {
    return Obx(() => Column(
          children: [
            _buildCostRow('Subtotal', controller.subtotal.value),
            const SizedBox(height: 12),
            _buildDiscountRow(),
            const SizedBox(height: 12),
            _buildCostRow('Pajak (10%)', controller.tax.value),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildCostRow('Total Akhir', controller.grandTotal.value, isTotal: true),
            ),
          ],
        ));
  }

  Widget _buildDiscountRow() {
    return InkWell(
      onTap: () => controller.openDiscountDialog(),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Diskon', style: TextStyle(color: Colors.green)),
                if (controller.discount.value > 0)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                    onPressed: () => controller.removeDiscount(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
              ],
            ),
            Text(
              '- ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(controller.discount.value)}',
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, double amount, {bool isTotal = false}) {
    final style = isTotal
        ? AppTextStyles.heading.copyWith(fontSize: 20, color: AppColors.primary)
        : AppTextStyles.body.copyWith(color: Colors.grey.shade700);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: style.copyWith(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(
          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
          style: style.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Aksi selanjutnya: buka bottom sheet metode pembayaran
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: AppTextStyles.button.copyWith(fontSize: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Pilih Metode Pembayaran'),
        ),
      ),
    );
  }
}
