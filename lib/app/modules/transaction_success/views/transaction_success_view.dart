import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/app/data/models/product_model.dart';
import 'package:pos_app/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_text_styles.dart';

import '../controllers/transaction_success_controller.dart';

class TransactionSuccessView extends GetView<TransactionSuccessController> {
  const TransactionSuccessView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Berhasil'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildReceiptCard(),
              ],
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: AppColors.primary, size: 80),
        const SizedBox(height: 16),
        Text('Pembayaran Berhasil', style: AppTextStyles.heading),
        SizedBox(height: 4),
        const Text('Terima kasih atas pesanan Anda.'),
      ],
    );
  }

  Widget _buildReceiptCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReceiptHeader(),
            const Divider(height: 24),
            _buildOrderItemsList(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: DottedLine(dashColor: AppColors.grey),
            ),
            _buildCostDetails(),
            const Divider(height: 24),
            _buildPaymentDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INNI DAWEET',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('ID Transaksi: ${controller.transaction.id}'),
        Text('Tanggal: ${DateFormat('d MMM y, HH:mm').format(controller.transaction.date)}'),
      ],
    );
  }

  Widget _buildOrderItemsList() {
    return Column(
      children: controller.transaction.items.entries.map((entry) {
        final product = entry.key;
        final quantity = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Text('${product.name} x$quantity'),
              ),
              Text(
                NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                    .format(product.price * quantity),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCostDetails() {
    return Column(
      children: [
        _buildCostRow('Subtotal', controller.transaction.subtotal),
        const SizedBox(height: 8),
        _buildCostRow('Diskon', -controller.transaction.discount, color: Colors.green),
        const SizedBox(height: 8),
        _buildCostRow('Pajak (10%)', controller.transaction.tax),
        const Divider(height: 24, thickness: 1),
        _buildCostRow('Total', controller.transaction.grandTotal, isTotal: true),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    final transaction = controller.transaction;
    return Column(
      children: [
        _buildCostRow('Metode Bayar', 0,
            value: transaction.paymentMethod == PaymentMethod.cash ? 'Tunai' : 'QRIS'),
        if (transaction.paymentMethod == PaymentMethod.cash) ...[
          const SizedBox(height: 8),
          _buildCostRow('Uang Tunai', transaction.cashAmount),
          const SizedBox(height: 8),
          _buildCostRow('Kembalian', transaction.cashChange),
        ]
      ],
    );
  }

  Widget _buildCostRow(String label, double amount,
      {bool isTotal = false, String? value, Color? color}) {
    final style = isTotal ? AppTextStyles.heading.copyWith(fontSize: 18) : AppTextStyles.body;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value ??
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(amount),
          style: style.copyWith(fontWeight: FontWeight.bold, color: color ?? style.color),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.print_outlined),
              label: const Text('Cetak Struk'),
              onPressed: controller.printReceipt,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Transaksi Baru'),
              onPressed: controller.createNewTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
