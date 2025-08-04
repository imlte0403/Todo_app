
import 'package:flutter/material.dart';
import 'package:todo_app/utils/constants.dart';

class ChoiceChip<T> extends StatelessWidget {
  final T value;
  final T selectedValue;
  final Function(T) onSelected;
  final String label;
  final IconData icon;
  final Color color;

  const ChoiceChip({
    super.key,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == value;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(77),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
