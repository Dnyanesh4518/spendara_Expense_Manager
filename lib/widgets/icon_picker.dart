import 'package:flutter/material.dart';

class IconPicker extends StatelessWidget {
  final Map<String, IconData> options;
  final String selected;
  final Color activeColor;
  final ValueChanged<String> onSelect;

  const IconPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.activeColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.entries.map((e) {
        final isSelected = e.key == selected;
        return GestureDetector(
          onTap: () => onSelect(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.15)
                  : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? activeColor
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.4),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              e.value,
              color: isSelected
                  ? activeColor
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 22,
            ),
          ),
        );
      }).toList(),
    );
  }
}
