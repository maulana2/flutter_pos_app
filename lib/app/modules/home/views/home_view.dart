import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:pos_app/app/modules/home/widgets/product_card.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_text_styles.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildCategoryTabs(),
                _buildProductGrid(),
              ],
            ),
            _buildOrderSummaryPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Pesanan', style: AppTextStyles.heading),
          const SizedBox(height: 16),
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama produk...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Obx(
        () => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: controller.categoryList.length,
            itemBuilder: (context, index) {
              final category = controller.categoryList[index];
              return Obx(() {
                final isSelected = category.trim() == controller.selectedCategory.value.trim();
                print(
                    '[DEBUG] Build Tab: "$category" | Selected: "${controller.selectedCategory.value}" | isSelected: $isSelected');
                return GestureDetector(
                  key: ValueKey(category),
                  onTap: () {
                    controller.changeCategory(category);
                    HapticFeedback.lightImpact();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.text,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              });
            }),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerGrid();
        }
        if (controller.filteredProducts.isEmpty) {
          return const Center(child: Text('Produk tidak ditemukan.'));
        }
        return AnimationLimiter(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: controller.filteredProducts.length,
            itemBuilder: (context, index) {
              final product = controller.filteredProducts[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: ProductCard(product: product),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummaryPanel() {
    return Obx(() {
      if (controller.cartItems.isEmpty) {
        return const SizedBox.shrink();
      }
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            controller.openCartDetails();
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pesanan',
                      style: AppTextStyles.body.copyWith(color: AppColors.white.withOpacity(0.8)),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                          .format(controller.totalCartPrice.value),
                      style: AppTextStyles.heading.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Detail',
                        style: AppTextStyles.button.copyWith(color: AppColors.text),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.text),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
