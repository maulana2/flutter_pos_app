import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_app/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_text_styles.dart';

class PaymentMethodSheet extends StatelessWidget {
  const PaymentMethodSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckoutController>();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Metode Pembayaran', style: AppTextStyles.heading),
          const SizedBox(height: 20),
          _buildPaymentMethodTile(
            icon: Icons.money_rounded,
            label: 'Tunai',
            onTap: () {
              controller.selectPaymentMethod(PaymentMethod.cash);
            },
          ),
          const Divider(height: 24),
          _buildPaymentMethodTile(
            icon: Icons.qr_code_2_rounded,
            label: 'QRIS',
            onTap: () {
              controller.selectPaymentMethod(PaymentMethod.qris);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, size: 30, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
