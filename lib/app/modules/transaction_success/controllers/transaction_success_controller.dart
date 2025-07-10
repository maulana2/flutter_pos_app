import 'package:get/get.dart';
import 'package:pos_app/app/data/models/transaction_model.dart';
import 'package:pos_app/app/routes/app_pages.dart';

class TransactionSuccessController extends GetxController {
  late final TransactionModel transaction;

  @override
  void onInit() {
    super.onInit();
    transaction = Get.arguments as TransactionModel;
  }

  void createNewTransaction() {
    Get.offAllNamed(Routes.HOME);
  }

  void printReceipt() {
    // Logika untuk mencetak struk akan ditambahkan di sini
    Get.snackbar('Fitur Dalam Pengembangan', 'Fungsi cetak struk akan segera hadir.');
  }
}
