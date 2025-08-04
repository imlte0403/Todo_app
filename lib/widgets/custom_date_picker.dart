import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

/// 커스텀 날짜 선택기 위젯
///
/// 가로 스크롤 형태의 날짜 선택기로, 오늘 기준 전후 30일을 표시합니다.
/// 선택된 날짜는 하이라이트되고, 오늘 날짜는 특별한 스타일로 표시됩니다.
class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({super.key});

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 오늘 날짜로 스크롤 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    // 스크롤 컨트롤러 정리
    _scrollController.dispose();
    super.dispose();
  }

  /// 선택된 날짜로 스크롤 이동하는 메서드
  void _scrollToSelectedDate() {
    final todoProvider = context.read<TodoProvider>();
    final today = DateTime.now();
    // 오늘 기준 30일 전부터 시작하므로 인덱스 계산
    final index = todoProvider.selectedDate.difference(today).inDays + 30;
    final position = index * 70.0; // 각 카드의 너비 (70px)

    // 부드러운 애니메이션으로 스크롤 이동
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final today = DateTime.now();

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal, // 가로 스크롤
        itemCount: 60, // 오늘 기준 전후 30일 (총 60일)
        itemBuilder: (context, index) {
          // 인덱스를 실제 날짜로 변환 (오늘 기준 -30일부터 +30일까지)
          final date = today.add(Duration(days: index - 30));

          // 현재 선택된 날짜인지 확인
          final isSelected =
              todoProvider.selectedDate.year == date.year &&
              todoProvider.selectedDate.month == date.month &&
              todoProvider.selectedDate.day == date.day;

          // 오늘 날짜인지 확인
          final isToday =
              today.year == date.year &&
              today.month == date.month &&
              today.day == date.day;

          return GestureDetector(
            onTap: () => todoProvider.selectDate(date), // 날짜 선택
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                // 선택된 날짜는 primary 색상, 오늘은 회색, 나머지는 투명
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : (isToday ? Colors.grey.shade200 : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 요일 표시 (월, 화, 수, ...)
                  Text(
                    DateFormat.E('ko_KR').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 날짜 표시 (1, 2, 3, ...)
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
