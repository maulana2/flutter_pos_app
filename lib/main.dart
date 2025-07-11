import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pos_app/app/data/services/database_service.dart';
import 'package:pos_app/app/data/services/transaction_service.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final dbService = DatabaseService();
  await dbService.init();
  Get.put<DatabaseService>(dbService);

  final trxService = TransactionService();
  await trxService.init();
  Get.put<TransactionService>(trxService);
  void deleteDb() async {
    final dbFolder = await getApplicationCacheDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    if (await file.exists()) {
      await file.delete();
      print('DB Deleted');
    }
  }

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
