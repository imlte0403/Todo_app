import 'package:flutter/material.dart';
import 'package:todo_app/utils/constants.dart';

/// 선택 가능한 칩 위젯
///
/// 카테고리나 우선순위 선택에 사용되는 칩 위젯입니다.
/// 선택 상태에 따라 색상과 스타일이 변경되며, 터치로 선택할 수 있습니다.
class ChoiceChip<T> extends StatelessWidget {
  final T value; // 칩의 값
  final T selectedValue; // 현재 선택된 값
  final Function(T) onSelected; // 선택 시 호출될 콜백
  final String label; // 표시될 텍스트
  final IconData icon; // 표시될 아이콘
  final Color color; // 칩의 색상

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
    final isSelected = selectedValue == value; // 현재 선택된 상태인지 확인

    return GestureDetector(
      onTap: () => onSelected(value), // 터치 시 선택 콜백 호출
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          // 선택 상태에 따라 배경색 변경
          color: isSelected ? color : color.withAlpha(26),
          borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
          // 선택 상태에 따라 테두리 색상 변경
          border: Border.all(color: isSelected ? color : color.withAlpha(77)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 (선택 상태에 따라 색상 변경)
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: AppDimensions.paddingSmall),
            // 텍스트 라벨 (선택 상태에 따라 색상 변경)
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
