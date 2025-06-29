import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';

class CategoriesSection extends StatelessWidget {
  final List<String> categories;
  final List<String> selectedCategories;
  final Function(String, bool) onCategoryChanged;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.categoryFood.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: AppColors.categoryFood,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Business Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Select categories that best describe your business',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.map((category) {
              final isSelected = selectedCategories.contains(category);
              return _buildCategoryChip(category, isSelected);
            }).toList(),
          ),
          if (selectedCategories.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${selectedCategories.length} categor${selectedCategories.length == 1 ? 'y' : 'ies'} selected',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    final categoryColors = {
      'Restaurant': AppColors.categoryFood,
      'Cafe': AppColors.categoryGrocery,
      'Retail': AppColors.categoryClothing,
      'Salon': AppColors.categoryBeauty,
      'Gym': AppColors.categoryFitness,
      'Clinic': AppColors.categoryMedical,
    };

    final categoryIcons = {
      'Restaurant': Icons.restaurant,
      'Cafe': Icons.coffee,
      'Retail': Icons.shopping_bag,
      'Salon': Icons.content_cut,
      'Gym': Icons.fitness_center,
      'Clinic': Icons.local_hospital,
    };

    final color = categoryColors[category] ?? AppColors.categoryHome;
    final icon = categoryIcons[category] ?? Icons.category;

    return GestureDetector(
      onTap: () => onCategoryChanged(category, !isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.background,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textWhite : color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check,
                color: AppColors.textWhite,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
