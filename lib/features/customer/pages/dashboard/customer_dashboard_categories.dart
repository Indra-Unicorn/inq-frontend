import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/widgets/category_svg_icon.dart';
import '../../models/category.dart';

class CustomerDashboardCategories extends StatelessWidget {
  /// Null / empty list while categories are loading from the API.
  final List<Category>? categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CustomerDashboardCategories({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // While loading, show a shimmer-style placeholder row
    if (categories == null) {
      return Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 4,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
        ),
      );
    }

    // "All" pill + one pill per API category
    final allItems = [null, ...categories!]; // null represents "All"

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: allItems.length,
        itemBuilder: (context, index) {
          final category = allItems[index];
          final label = category?.displayName ?? 'All';
          final isSelected = selectedCategory ==
              (category?.name ?? 'All');

          return Padding(
            padding: EdgeInsets.only(
              right: index < allItems.length - 1 ? 12 : 0,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () =>
                    onCategorySelected(category?.name ?? 'All'),
                borderRadius: BorderRadius.circular(25),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: category != null ? 12 : 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryLight,
                            ],
                          )
                        : null,
                    color:
                        isSelected ? null : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: AppColors.shadowLight
                                  .withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Vector icon for each API category
                      if (category != null) ...[
                        CategorySvgIcon(
                          categoryName: category.name,
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        label,
                        style: CommonStyle.bodyMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}
