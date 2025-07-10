import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_app/app/data/product_model.dart';
import 'package:pos_app/app/modules/home/controllers/home_controller.dart';
import 'package:pos_app/app/modules/checkout/widgets/payment_method_sheet.dart';
import 'package:pos_app/app/routes/app_pages.dart';
import 'package:pos_app/core/theme/app_colors.dart';

enum OrderType { dineIn, takeAway }

enum DiscountType { none, percent, nominal }

enum PaymentMethod { none, cash, qris }

class CheckoutController extends GetxController {
  // Data Pesanan
  final RxMap<Product, int> orderItems = <Product, int>{}.obs;

  // Opsi Pesanan
  final Rx<OrderType> orderType = OrderType.dineIn.obs;
  final TextEditingController notesController = TextEditingController();

  // Kalkulasi Biaya
  final RxDouble subtotal = 0.0.obs;
  final RxDouble tax = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble grandTotal = 0.0.obs;

  // State Diskon
  final Rx<DiscountType> discountType = DiscountType.none.obs;
  final TextEditingController discountController = TextEditingController();

  // State Pembayaran
  final Rx<PaymentMethod> selectedPaymentMethod = PaymentMethod.none.obs;
  final TextEditingController cashAmountController = TextEditingController();
  final RxDouble cashChange = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final homeController = Get.find<HomeController>();
    orderItems.assignAll(homeController.cartItems);
    calculateCosts();

    cashAmountController.addListener(() {
      calculateChange();
    });
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
    Get.back(); // Tutup bottom sheet setelah memilih
  }

  void calculateChange() {
    final cashAmount = double.tryParse(cashAmountController.text) ?? 0;
    if (cashAmount > 0) {
      cashChange.value = cashAmount - grandTotal.value;
    } else {
      cashChange.value = 0.0;
    }
  }

  void setCashAmount(double amount) {
    cashAmountController.text = amount.toStringAsFixed(0);
  }

  void processTransaction() {
    // Di sini logika untuk menyimpan transaksi ke database/API
    // Untuk sekarang, kita hanya akan menampilkan dialog sukses

    // Reset keranjang di HomeController
    final homeController = Get.find<HomeController>();
    homeController.clearCart();

    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        title: const Text('Transaksi Berhasil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 60),
            const SizedBox(height: 16),
            const Text('Pembayaran telah berhasil diproses.'),
            if (selectedPaymentMethod.value == PaymentMethod.cash && cashChange.value > 0)
              Text('Kembalian: Rp ${cashChange.value.toStringAsFixed(0)}')
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Kembali ke halaman kasir
              Get.offAllNamed(Routes.HOME);
            },
            child: const Text('Transaksi Baru'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aksi untuk cetak struk
            },
            child: const Text('Cetak Struk'),
          ),
        ],
      ),
    );
  }
}
