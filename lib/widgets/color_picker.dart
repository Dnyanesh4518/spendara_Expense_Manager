import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final List<Color> colors;
  final int selectedIdx;
  final ValueChanged<int> onSelect;

  const ColorPicker({
    super.key,
    required this.colors,
    required this.selectedIdx,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.asMap().entries.map((e) {
        final isSelected = e.key == selectedIdx;
        return GestureDetector(
          onTap: () => onSelect(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: e.value,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 3,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: e.value.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
