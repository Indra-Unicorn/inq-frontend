import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/api_endpoints.dart';

class CategoriesSection extends StatefulWidget {
  final List<String> selectedCategories;
  final Function(String, bool) onCategoryChanged;

  const CategoriesSection({
    super.key,
    required this.selectedCategories,
    required this.onCategoryChanged,
  });

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  List<String> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getAllCategories}'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final list = data['data'] as List<dynamic>;
        
        setState(() {
          _categories = list.map((json) {
            final name = json['name'] as String;
            return name.isEmpty ? name : '${name[0].toUpperCase()}${name.substring(1)}';
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to load categories';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch categories';
        _isLoading = false;
      });
    }
  }

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
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((category) {
                final isSelected = widget.selectedCategories.contains(category);
                return _buildCategoryChip(category, isSelected);
              }).toList(),
            ),
          if (widget.selectedCategories.isNotEmpty) ...[
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
                      '${widget.selectedCategories.length} categor${widget.selectedCategories.length == 1 ? 'y' : 'ies'} selected',
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
      onTap: () => widget.onCategoryChanged(category, !isSelected),
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
