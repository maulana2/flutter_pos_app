import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_app/app/data/product_model.dart';
import 'package:pos_app/app/modules/checkout/widgets/payment_method_sheet.dart';
import 'package:pos_app/app/modules/home/controllers/home_controller.dart';

enum OrderType { dineIn, takeAway }

enum DiscountType { none, percent, nominal }

class CheckoutController extends GetxController {
  final RxMap<Product, int> orderItems = <Product, int>{}.obs;

  final Rx<OrderType> orderType = OrderType.dineIn.obs;
  final TextEditingController notesController = TextEditingController();

  final RxDouble subtotal = 0.0.obs;
  final RxDouble tax = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble grandTotal = 0.0.obs;

  final Rx<DiscountType> discountType = DiscountType.none.obs;
  final TextEditingController discountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final homeController = Get.find<HomeController>();
    orderItems.assignAll(homeController.cartItems);
    calculateCosts();
  }

  @override
  void onClose() {
    notesController.dispose();
    discountController.dispose();
    super.onClose();
  }

  void calculateCosts() {
    double currentSubtotal = 0.0;
    orderItems.forEach((product, quantity) {
      currentSubtotal += product.price * quantity;
    });

    subtotal.value = currentSubtotal;

    if (discountType.value == DiscountType.percent) {
      final percentValue = double.tryParse(discountController.text) ?? 0;
      discount.value = subtotal.value * (percentValue / 100);
    } else if (discountType.value == DiscountType.nominal) {
      discount.value = double.tryParse(discountController.text) ?? 0;
    } else {
      discount.value = 0.0;
    }

    tax.value = (subtotal.value - discount.value) * 0.10;
    grandTotal.value = subtotal.value - discount.value + tax.value;
  }

  void setOrderType(OrderType type) {
    orderType.value = type;
  }

  void applyDiscount() {
    calculateCosts();
    Get.back();
  }

  void removeDiscount() {
    discountController.clear();
    discountType.value = DiscountType.none;
    calculateCosts();
  }

  void openDiscountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Gunakan Diskon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => SegmentedButton<DiscountType>(
                segments: const [
                  ButtonSegment(value: DiscountType.percent, label: Text('%')),
                  ButtonSegment(value: DiscountType.nominal, label: Text('Rp')),
                ],
                selected: {discountType.value},
                onSelectionChanged: (newSelection) {
                  discountType.value = newSelection.first;
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Diskon',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: applyDiscount,
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  void showPaymentMethodSheet() {
    Get.bottomSheet(
      const PaymentMethodSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}
