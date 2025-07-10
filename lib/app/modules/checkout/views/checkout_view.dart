import 'package:dotted_line/dotted_line.dart';
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
      body: ListView(
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
                const Divider(height: 24),
                _buildNotesField(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Rincian Biaya',
            child: _buildCostDetails(),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodSection(),
          const SizedBox(height: 120),
        ],
      ),
      bottomNavigationBar: _buildFloatingSummaryBar(),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: DottedLine(dashColor: AppColors.grey),
            ),
            _buildCostRow('Total', controller.grandTotal.value, isTotal: true),
          ],
        ));
  }

  Widget _buildDiscountRow() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.openDiscountDialog(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diskon', style: AppTextStyles.body.copyWith(color: Colors.green)),
              Row(
                children: [
                  Text(
                    controller.discount.value > 0
                        ? '- ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(controller.discount.value)}'
                        : 'Gunakan',
                    style: AppTextStyles.body
                        .copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, double amount, {bool isTotal = false}) {
    final style = isTotal
        ? AppTextStyles.heading.copyWith(fontSize: 20)
        : AppTextStyles.body.copyWith(color: Colors.grey.shade700);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style.copyWith(fontWeight: isTotal ? FontWeight.bold : null)),
        Text(
          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
          style: style.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFloatingSummaryBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Total Pembayaran', style: TextStyle(color: AppColors.text)),
                Obx(() => Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                          .format(controller.grandTotal.value),
                      style: AppTextStyles.heading.copyWith(color: AppColors.primary),
                    )),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Obx(() {
            final isPaymentSelected = controller.selectedPaymentMethod.value != PaymentMethod.none;
            return ElevatedButton(
              onPressed: () => controller.processTransaction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPaymentSelected ? AppColors.primary : Colors.grey,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                textStyle: AppTextStyles.button.copyWith(fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Bayar Sekarang'),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return _buildSectionCard(
      title: 'Metode Pembayaran',
      child: Obx(() {
        if (controller.selectedPaymentMethod.value == PaymentMethod.none) {
          return Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('Pilih Metode Pembayaran'),
              onPressed: () => controller.showPaymentMethodSheet(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          );
        }

        // Tampilan setelah metode dipilih
        return Column(
          children: [
            ListTile(
              leading: Icon(
                controller.selectedPaymentMethod.value == PaymentMethod.cash
                    ? Icons.money_rounded
                    : Icons.qr_code_2_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                controller.selectedPaymentMethod.value == PaymentMethod.cash ? 'Tunai' : 'QRIS',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: TextButton(
                onPressed: () => controller.showPaymentMethodSheet(),
                child: const Text('Ganti'),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            if (controller.selectedPaymentMethod.value == PaymentMethod.cash)
              _buildCashPaymentSection(),
            if (controller.selectedPaymentMethod.value == PaymentMethod.qris)
              _buildQrisPaymentSection(),
          ],
        );
      }),
    );
  }

  Widget _buildCashPaymentSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          TextField(
            controller: controller.cashAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jumlah Uang Diterima',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickCashButton(controller.grandTotal.value),
                const SizedBox(width: 8),
                _buildQuickCashButton(50000),
                const SizedBox(width: 8),
                _buildQuickCashButton(100000),
              ],
            ),
          ),
          const Divider(height: 24),
          Obx(() => _buildCostRow('Kembalian', controller.cashChange.value, isTotal: true)),
        ],
      ),
    );
  }

  Widget _buildQuickCashButton(double amount) {
    if (amount < controller.grandTotal.value) return const SizedBox.shrink();

    return OutlinedButton(
      onPressed: () => controller.setCashAmount(amount),
      child: Text(NumberFormat.compact(locale: 'id').format(amount)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildQrisPaymentSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 200,
            color: Colors.grey.shade300,
            child: const Center(child: Icon(Icons.qr_code_2, size: 100)),
          ),
          const SizedBox(height: 16),
          Text(
            'Pindai kode QR untuk membayar',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
