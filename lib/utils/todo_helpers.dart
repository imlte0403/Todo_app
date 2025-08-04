import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoHelpers {
  // 카테고리별 정보
  static Map<TodoCategory, CategoryInfo> categoryInfo = {
    TodoCategory.work: CategoryInfo(
      name: '업무',
      icon: Icons.work,
      color: const Color(0xFF3B82F6), // 파란색
    ),
    TodoCategory.personal: CategoryInfo(
      name: '개인',
      icon: Icons.person,
      color: const Color(0xFF10B981), // 초록색
    ),
    TodoCategory.study: CategoryInfo(
      name: '학습',
      icon: Icons.school,
      color: const Color(0xFF8B5CF6), // 보라색
    ),
    TodoCategory.health: CategoryInfo(
      name: '건강',
      icon: Icons.favorite,
      color: const Color(0xFFEF4444), // 빨간색
    ),
    TodoCategory.shopping: CategoryInfo(
      name: '쇼핑',
      icon: Icons.shopping_cart,
      color: const Color(0xFFF59E0B), // 주황색
    ),
    TodoCategory.other: CategoryInfo(
      name: '기타',
      icon: Icons.more_horiz,
      color: const Color(0xFF6B7280), // 회색
    ),
  };

  // 우선순위별 정보
  static Map<TodoPriority, PriorityInfo> priorityInfo = {
    TodoPriority.low: PriorityInfo(
      name: '낮음',
      color: const Color(0xFF10B981), // 초록색
      icon: Icons.arrow_downward,
    ),
    TodoPriority.medium: PriorityInfo(
      name: '보통',
      color: const Color(0xFFF59E0B), // 주황색
      icon: Icons.remove,
    ),
    TodoPriority.high: PriorityInfo(
      name: '높음',
      color: const Color(0xFFEF4444), // 빨간색
      icon: Icons.arrow_upward,
    ),
    TodoPriority.urgent: PriorityInfo(
      name: '긴급',
      color: const Color(0xFFDC2626), // 진한 빨간색
      icon: Icons.priority_high,
    ),
  };

  // 카테고리 정보 가져오기
  static CategoryInfo getCategoryInfo(TodoCategory category) {
    return categoryInfo[category] ?? categoryInfo[TodoCategory.other]!;
  }

  // 우선순위 정보 가져오기
  static PriorityInfo getPriorityInfo(TodoPriority priority) {
    return priorityInfo[priority] ?? priorityInfo[TodoPriority.medium]!;
  }

  // 우선순위 비교 함수 (높은 우선순위가 먼저)
  static int comparePriority(TodoPriority a, TodoPriority b) {
    final priorityOrder = {
      TodoPriority.urgent: 4, // 긴급 (가장 높음)
      TodoPriority.high: 3, // 높음
      TodoPriority.medium: 2, // 보통
      TodoPriority.low: 1, // 낮음 (가장 낮음)
    };

    return priorityOrder[b]!.compareTo(priorityOrder[a]!);
  }

  // Todo 리스트를 우선순위별로 정렬
  static List<Todo> sortTodosByPriority(List<Todo> todos) {
    final sortedTodos = List<Todo>.from(todos);
    sortedTodos.sort((a, b) {
      // 1. 우선순위로 정렬 (높은 우선순위가 먼저)
      final priorityComparison = comparePriority(a.priority, b.priority);
      if (priorityComparison != 0) {
        return priorityComparison;
      }

      // 2. 우선순위가 같으면 완료 상태로 정렬 (미완료가 먼저)
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }

      // 3. 완료 상태가 같으면 생성 시간으로 정렬 (최신이 먼저)
      return b.createdAt.compareTo(a.createdAt);
    });

    return sortedTodos;
  }

  // 날짜 포맷팅
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return '오늘';
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return '내일';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return '어제';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }

  // 시간 포맷팅
  static String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;

  CategoryInfo({required this.name, required this.icon, required this.color});
}

class PriorityInfo {
  final String name;
  final Color color;
  final IconData icon;

  PriorityInfo({required this.name, required this.color, required this.icon});
}
