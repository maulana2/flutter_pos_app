import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pos_app/app/data/services/database_service.dart';
import 'package:pos_app/app/data/services/transaction_service.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi DatabaseService dan tunggu init()
  final dbService = DatabaseService();
  await dbService.init();
  Get.put<DatabaseService>(dbService);

  // Inisialisasi TransactionService dan tunggu init()
  final trxService = TransactionService();
  await trxService.init();
  Get.put<TransactionService>(trxService);

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
