import 'package:flutter/material.dart';
import '../constants/constants.dart';

class CategoryGrid extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final Color typeColor;
  final Color typeBgColor;
  final ValueChanged<String> onSelect;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selected,
    required this.typeColor,
    required this.typeBgColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = cat == selected;
        final icon = Constants.categoryIcon(cat);
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? typeBgColor
                  : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? typeColor
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.4),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? typeColor
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 6),
                Text(
                  cat,
                  style: tt.bodyMedium?.copyWith(
                    color: isSelected ? typeColor : null,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
