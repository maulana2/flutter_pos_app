import 'package:get/get.dart';
import 'package:pos_app/app/data/local/db/app_database.dart';

class DatabaseService extends GetxService {
  late final AppDatabase db;

  Future<DatabaseService> init() async {
    db = AppDatabase(); // koneksi Drift DB lokal
    return this;
  }
}
