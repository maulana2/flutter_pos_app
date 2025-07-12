import 'package:get/get.dart';
import 'package:pos_app/app/data/local/db/app_database.dart';
import 'package:pos_app/app/data/local/db/models/transaction_with_items.dart';
import 'package:pos_app/app/routes/app_pages.dart';

class TransactionSuccessController extends GetxController {
  late final TransactionWithItems transactionWithItems;

  @override
  void onInit() {
    super.onInit();
    transactionWithItems = Get.arguments as TransactionWithItems;
  }

  void createNewTransaction() {
    Get.offAllNamed(Routes.HOME);
  }

  void printReceipt() {
    Get.snackbar('Fitur Dalam Pengembangan', 'Fungsi cetak struk akan segera hadir.');
  }
}
