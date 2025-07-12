import 'package:get/get.dart';
import 'package:pos_app/app/data/services/product_service.dart';
import 'package:pos_app/app/modules/product_management/controllers/product_management_controller.dart';

class ProductManagementBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan ProductService sudah terdaftar
    if (!Get.isRegistered<ProductService>()) {
      Get.put(ProductService());
    }
    
    Get.lazyPut<ProductManagementController>(
      () => ProductManagementController(),
    );
  }
}