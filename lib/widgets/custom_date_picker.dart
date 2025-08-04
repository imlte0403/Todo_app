import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

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
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    final todoProvider = context.read<TodoProvider>();
    final today = DateTime.now();
    final index = todoProvider.selectedDate.difference(today).inDays + 30; // 30일 전부터 시작
    final position = index * 70.0; // 각 카드의 너비

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
        scrollDirection: Axis.horizontal,
        itemCount: 60, // 예: 오늘 기준 30일 전후
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index - 30));
          final isSelected = todoProvider.selectedDate.year == date.year &&
              todoProvider.selectedDate.month == date.month &&
              todoProvider.selectedDate.day == date.day;
          final isToday = today.year == date.year &&
              today.month == date.month &&
              today.day == date.day;

          return GestureDetector(
            onTap: () => todoProvider.selectDate(date),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : (isToday ? Colors.grey.shade200 : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E('ko_KR').format(date), // 요일 (월, 화, ...)
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.day.toString(), // 날짜 (1, 2, ...)
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
