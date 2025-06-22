import 'package:flutter/material.dart';

class CategoriesSelector extends StatelessWidget {
  final List<String> selectedCategories;
  final List<String> availableCategories;
  final ValueChanged<List<String>> onCategoriesChanged;
  final bool isEnabled;

  const CategoriesSelector({
    super.key,
    required this.selectedCategories,
    required this.availableCategories,
    required this.onCategoriesChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...selectedCategories.map((category) => InputChip(
              label: Text(category),
              selected: true,
              onDeleted: isEnabled
                  ? () {
                      final newCategories =
                          List<String>.from(selectedCategories)
                            ..remove(category);
                      onCategoriesChanged(newCategories);
                    }
                  : null,
              backgroundColor: const Color(0xFFE9B8BA),
              labelStyle: const TextStyle(
                  color: Color(0xFF191010), fontWeight: FontWeight.bold),
              deleteIcon: const Icon(Icons.close, size: 18),
            )),
        if (isEnabled)
          PopupMenuButton<String>(
            icon:
                const Icon(Icons.add_circle_outline, color: Color(0xFFE9B8BA)),
            tooltip: 'Add Category',
            itemBuilder: (context) => availableCategories
                .where((cat) => !selectedCategories.contains(cat))
                .map((cat) => PopupMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onSelected: (cat) {
              final newCategories = List<String>.from(selectedCategories)
                ..add(cat);
              onCategoriesChanged(newCategories);
            },
          ),
      ],
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE9B8BA) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFE9B8BA) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFF191010) : const Color(0xFF8B5B5C),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
