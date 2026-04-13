import 'package:flutter/material.dart';

import '../constants/constants.dart';

class GroupedCategoryPicker extends StatelessWidget {
  final List<CategoryGroup> groups;
  final String selected;
  final Color typeColor;
  final Color typeBgColor;
  final ValueChanged<String> onSelect;

  const GroupedCategoryPicker({
    super.key,
    required this.groups,
    required this.selected,
    required this.typeColor,
    required this.typeBgColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups
          .map(
            (group) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group label
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Row(
                    children: [
                      Icon(
                        group.icon,
                        size: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        group.label,
                        style: tt.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.45),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Category chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(group.keys.length, (i) {
                    final key = group.keys[i];
                    final label = group.labels[i];
                    final isSelected = key == selected;
                    return GestureDetector(
                      onTap: () => onSelect(key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? typeBgColor
                              : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? typeColor
                                : Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.35),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Constants.categoryIcon(key),
                              size: 14,
                              color: isSelected
                                  ? typeColor
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.45),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              label,
                              style: tt.bodySmall?.copyWith(
                                fontSize: 12,
                                color: isSelected ? typeColor : null,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],
            ),
          )
          .toList(),
    );
  }
}
