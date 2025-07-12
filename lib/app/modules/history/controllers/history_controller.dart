import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_app/app/data/local/db/models/transaction_with_items.dart';
import 'package:pos_app/app/data/services/transaction_service.dart';
import 'package:pos_app/app/routes/app_pages.dart';

class HistoryController extends GetxController {
  final TransactionService transactionService = Get.find<TransactionService>();

  // Observable variables
  final RxList<TransactionWithItems> _allTransactions = <TransactionWithItems>[].obs;
  final RxList<TransactionWithItems> filteredTransactions = <TransactionWithItems>[].obs;
  final RxString selectedDateFilter = 'Hari ini'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  // Getter untuk transactions yang akan digunakan di View
  RxList<TransactionWithItems> get transactions => filteredTransactions;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  // Load transactions from TransactionService
  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;

      // Get transactions from service
      _allTransactions.value = transactionService.transactionList.toList();

      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat riwayat transaksi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh transactions
  Future<void> refreshTransactions() async {
    await loadTransactions();
  }

  // Set date filter
  void setDateFilter(String filter) {
    selectedDateFilter.value = filter;
    applyFilters();
  }

  // Apply filters to transactions
  void applyFilters() {
    var filtered = _allTransactions.toList();

    // Apply date filter
    final now = DateTime.now();
    DateTime startDate;

    switch (selectedDateFilter.value) {
      case 'Hari ini':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Minggu ini':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'Bulan ini':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = DateTime.now().subtract(const Duration(days: 30));
    }

    filtered = filtered.where((transactionWithItems) {
      return transactionWithItems.transaction.date.isAfter(startDate) ||
          transactionWithItems.transaction.date.isAtSameMomentAs(startDate);
    }).toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((transactionWithItems) {
        final transaction = transactionWithItems.transaction;
        return transaction.transactionId.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            transaction.paymentMethod.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            transaction.orderType.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.transaction.date.compareTo(a.transaction.date));

    filteredTransactions.value = filtered;
  }

  // Get transaction statistics
  Map<String, dynamic> getTransactionStats() {
    final totalTransactions = filteredTransactions.length;
    final totalRevenue = filteredTransactions.fold<double>(
      0,
      (sum, transactionWithItems) => sum + transactionWithItems.transaction.grandTotal,
    );

    return {
      'totalTransactions': totalTransactions,
      'totalRevenue': totalRevenue,
    };
  }

  // Show search dialog
  void showSearchDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cari Transaksi'),
        content: TextField(
          onChanged: (value) {
            searchQuery.value = value;
            applyFilters();
          },
          decoration: const InputDecoration(
            hintText: 'Masukkan ID transaksi atau metode pembayaran',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              searchQuery.value = '';
              applyFilters();
              Get.back();
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Show filter dialog
  void showFilterDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Periode:'),
            const SizedBox(height: 10),
            Obx(() => Column(
                  children: [
                    _buildFilterOption('Hari ini'),
                    _buildFilterOption('Minggu ini'),
                    _buildFilterOption('Bulan ini'),
                    _buildFilterOption('Semua'),
                  ],
                )),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String option) {
    return RadioListTile<String>(
      title: Text(option),
      value: option,
      groupValue: selectedDateFilter.value,
      onChanged: (value) {
        if (value != null) {
          setDateFilter(value);
        }
      },
    );
  }

  // View transaction detail
  void viewTransactionDetail(TransactionWithItems transaction) {
    Get.toNamed(Routes.TRANSACTION_SUCCESS, arguments: transaction);
  }
}
