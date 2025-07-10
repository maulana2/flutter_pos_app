import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_app/app/data/local/app_database.dart';
import 'package:pos_app/app/data/services/transaction_service.dart';
import 'package:pos_app/app/modules/home/controllers/home_controller.dart';
import 'package:pos_app/app/modules/checkout/widgets/payment_method_sheet.dart';
import 'package:pos_app/app/routes/app_pages.dart';
import 'package:pos_app/core/theme/app_colors.dart';

enum OrderType { dineIn, takeAway }

enum DiscountType { none, percent, nominal }

enum PaymentMethod { none, cash, qris }

class CheckoutController extends GetxController {
  late final TransactionService _transactionService;
  final RxMap<Product, int> orderItems = <Product, int>{}.obs;

  final Rx<OrderType> orderType = OrderType.dineIn.obs;
  final TextEditingController notesController = TextEditingController();

  final RxDouble subtotal = 0.0.obs;
  final RxDouble tax = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble grandTotal = 0.0.obs;

  final Rx<DiscountType> discountType = DiscountType.none.obs;
  final TextEditingController discountController = TextEditingController();

  final Rx<PaymentMethod> selectedPaymentMethod = PaymentMethod.none.obs;
  final TextEditingController cashAmountController = TextEditingController();
  final RxDouble cashChange = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _transactionService = Get.find<TransactionService>();

    final homeController = Get.find<HomeController>();
    orderItems.assignAll(homeController.cartItems);
    calculateCosts();

    cashAmountController.addListener(calculateChange);
  }

  @override
  void onClose() {
    notesController.dispose();
    discountController.dispose();
    cashAmountController.dispose();
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
    calculateChange();
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

  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
    Get.back();
  }

  void calculateChange() {
    final cashAmount = double.tryParse(cashAmountController.text) ?? 0;
    if (cashAmount >= grandTotal.value) {
      cashChange.value = cashAmount - grandTotal.value;
    } else {
      cashChange.value = 0.0;
    }
  }

  void setCashAmount(double amount) {
    cashAmountController.text = amount.toStringAsFixed(0);
  }

  Future<void> processTransaction() async {
    if (selectedPaymentMethod.value == PaymentMethod.none) {
      Get.snackbar('Gagal', 'Silakan pilih metode pembayaran terlebih dahulu.',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final homeController = Get.find<HomeController>();

    final transactionData = Transaction(
      id: 0,
      transactionId: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      subtotal: subtotal.value,
      discount: discount.value,
      tax: tax.value,
      grandTotal: grandTotal.value,
      paymentMethod: selectedPaymentMethod.value.name,
      cashAmount: double.tryParse(cashAmountController.text) ?? 0.0,
      cashChange: cashChange.value,
      orderType: orderType.value.name,
      notes: notesController.text.isNotEmpty ? notesController.text : null,
    );

    final transactionItems = orderItems.entries.map((entry) {
      return TransactionItem(
        id: 0,
        transactionId: 0,
        productId: entry.key.id,
        productName: entry.key.name,
        productPrice: entry.key.price,
        quantity: entry.value,
      );
    }).toList();

    final transactionWithItems = TransactionWithItems(
      transaction: transactionData,
      items: transactionItems,
    );

    await _transactionService.addTransaction(transactionWithItems);

    homeController.clearCart();

    Get.offNamed(Routes.TRANSACTION_SUCCESS, arguments: transactionWithItems);
  }
}
