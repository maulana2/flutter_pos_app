import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:pos_app/app/data/providers/product_provider.dart';
import 'package:pos_app/app/data/services/database_service.dart';
import 'package:pos_app/app/data/services/transaction_service.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/app/routes/app_pages.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  Future<void> deleteOldDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'db.sqlite'));
    if (await file.exists()) {
      await file.delete();
      print('✅ Old database deleted');
    }
  }

  await deleteOldDatabase();

  // Init & inject DatabaseService
  final dbService = DatabaseService();
  await dbService.init();
  Get.put<DatabaseService>(dbService); // ✅ WAJIB: agar bisa Get.find()

  // Init & inject TransactionService (bergantung pada DatabaseService)
  final trxService = TransactionService();
  await trxService.init();
  Get.put<TransactionService>(trxService);

  // Init & inject ProductProvider (opsional kalau mau pakai dummy dulu)
  final productProvider = ProductProvider();
  await productProvider.insertDummyProducts();
  Get.put<ProductProvider>(productProvider);

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.lightTheme,
    ),
  );
}
