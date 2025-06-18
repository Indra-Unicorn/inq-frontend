import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';

class CustomerDashboardCategories extends StatelessWidget {
  final List<String> categories;
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
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == categories.length - 1 ? 16 : 0,
            ),
            child: ChoiceChip(
              label: Text(
                category,
                style: CommonStyle.bodyMedium.copyWith(
                  color:
                      isSelected ? AppColors.textWhite : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(category);
                }
              },
              backgroundColor: AppColors.backgroundLight,
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
