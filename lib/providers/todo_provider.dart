// lib/providers/todo_provider.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import '../utils/todo_helpers.dart';

class TodoProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService.instance;
  final Uuid _uuid = const Uuid();

  // 메모리 관리를 위한 캐시 크기 제한
  static const int _maxCacheSize = 100;

  // 동시성 제어를 위한 플래그
  bool _isUpdating = false;

  // 날짜별 할 일 저장
  Map<DateTime, List<Todo>> _todos = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Getters
  Map<DateTime, List<Todo>> get todos => Map.unmodifiable(_todos);
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  // 선택된 날짜의 할 일 목록 (우선순위별 정렬)
  List<Todo> get todosForSelectedDate {
    final normalizedDate = _normalizeDate(_selectedDate);
    final todos = _todos[normalizedDate] ?? [];

    // TodoHelpers의 정렬 함수 사용
    return TodoHelpers.sortTodosByPriority(todos);
  }

  // 완료된 할 일 개수
  int get completedTodosCount {
    return todosForSelectedDate.where((todo) => todo.isDone).length;
  }

  // 전체 할 일 개수
  int get totalTodosCount {
    return todosForSelectedDate.length;
  }

  // 완료율
  double get completionRate {
    if (totalTodosCount == 0) return 0.0;
    return completedTodosCount / totalTodosCount;
  }

  // 초기화 - 저장된 데이터 불러오기
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _todos = await _storageService.loadTodos();
      _selectedDate = _normalizeDate(DateTime.now());
    } catch (e) {
      debugPrint('할 일 데이터 초기화 중 오류: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 날짜 선택
  void selectDate(DateTime date) {
    _selectedDate = _normalizeDate(date);
    notifyListeners();
  }

  // 할 일 추가
  Future<void> addTodo(
    String task, {
    DateTime? dueDate,
    TodoCategory category = TodoCategory.other,
    TodoPriority priority = TodoPriority.medium,
    String? description,
  }) async {
    if (task.trim().isEmpty) return;
    if (_isUpdating) return; // 중복 실행 방지

    _isUpdating = true;
    try {
      final newTodo = Todo(
        id: _uuid.v4(),
        task: task.trim(),
        createdAt: DateTime.now(),
        dueDate: dueDate,
        category: category,
        priority: priority,
        description: description,
      );

      final normalizedDate = _normalizeDate(_selectedDate);
      final currentTodos = _todos[normalizedDate] ?? [];

      _todos[normalizedDate] = [...currentTodos, newTodo];
      _cleanupCache(); // 캐시 정리
      notifyListeners();

      // 저장
      await _saveTodosForCurrentDate();
    } finally {
      _isUpdating = false;
    }
  }

  // 할 일 수정
  Future<void> updateTodo(
    String todoId, {
    String? task,
    bool? isDone,
    DateTime? dueDate,
    TodoCategory? category,
    TodoPriority? priority,
    String? description,
  }) async {
    if (_isUpdating) return; // 중복 실행 방지

    _isUpdating = true;
    try {
      final normalizedDate = _normalizeDate(_selectedDate);
      final currentTodos = _todos[normalizedDate];

      if (currentTodos == null) return;

      final todoIndex = currentTodos.indexWhere((todo) => todo.id == todoId);
      if (todoIndex == -1) return;

      final updatedTodo = currentTodos[todoIndex].copyWith(
        task: task,
        isDone: isDone,
        dueDate: dueDate,
        category: category,
        priority: priority,
        description: description,
      );

      _todos[normalizedDate] = [
        ...currentTodos.sublist(0, todoIndex),
        updatedTodo,
        ...currentTodos.sublist(todoIndex + 1),
      ];

      _cleanupCache(); // 캐시 정리
      notifyListeners();
      await _saveTodosForCurrentDate();
    } finally {
      _isUpdating = false;
    }
  }

  // 할 일 삭제
  Future<void> deleteTodo(String todoId) async {
    if (_isUpdating) return; // 중복 실행 방지

    _isUpdating = true;
    try {
      final normalizedDate = _normalizeDate(_selectedDate);
      final currentTodos = _todos[normalizedDate];

      if (currentTodos == null) return;

      _todos[normalizedDate] = currentTodos
          .where((todo) => todo.id != todoId)
          .toList();

      if (_todos[normalizedDate]!.isEmpty) {
        _todos.remove(normalizedDate);
      }

      _cleanupCache(); // 캐시 정리
      notifyListeners();
      await _saveTodosForCurrentDate();
    } finally {
      _isUpdating = false;
    }
  }

  // 할 일 완료 상태 토글
  Future<void> toggleTodoStatus(String todoId) async {
    final normalizedDate = _normalizeDate(_selectedDate);
    final currentTodos = _todos[normalizedDate];

    if (currentTodos == null) return;

    final todoIndex = currentTodos.indexWhere((todo) => todo.id == todoId);
    if (todoIndex == -1) return;

    final currentTodo = currentTodos[todoIndex];
    await updateTodo(todoId, isDone: !currentTodo.isDone);
  }

  // 모든 할 일 완료 상태 변경
  Future<void> toggleAllTodos(bool isDone) async {
    if (_isUpdating) return; // 중복 실행 방지

    _isUpdating = true;
    try {
      final normalizedDate = _normalizeDate(_selectedDate);
      final currentTodos = _todos[normalizedDate];

      if (currentTodos == null || currentTodos.isEmpty) return;

      _todos[normalizedDate] = currentTodos
          .map((todo) => todo.copyWith(isDone: isDone))
          .toList();

      _cleanupCache(); // 캐시 정리
      notifyListeners();
      await _saveTodosForCurrentDate();
    } finally {
      _isUpdating = false;
    }
  }

  // 완료된 할 일 모두 삭제
  Future<void> clearCompletedTodos() async {
    if (_isUpdating) return; // 중복 실행 방지

    _isUpdating = true;
    try {
      final normalizedDate = _normalizeDate(_selectedDate);
      final currentTodos = _todos[normalizedDate];

      if (currentTodos == null) return;

      _todos[normalizedDate] = currentTodos
          .where((todo) => !todo.isDone)
          .toList();

      if (_todos[normalizedDate]!.isEmpty) {
        _todos.remove(normalizedDate);
      }

      _cleanupCache(); // 캐시 정리
      notifyListeners();
      await _saveTodosForCurrentDate();
    } finally {
      _isUpdating = false;
    }
  }

  // 특정 날짜에 할 일이 있는지 확인
  bool hasTodosForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return _todos[normalizedDate]?.isNotEmpty ?? false;
  }

  // 특정 날짜의 할 일 개수
  int getTodoCountForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return _todos[normalizedDate]?.length ?? 0;
  }

  // Private 메서드들
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  // 캐시 정리 메서드
  void _cleanupCache() {
    if (_todos.length > _maxCacheSize) {
      final sortedDates = _todos.keys.toList()
        ..sort((a, b) => b.compareTo(a)); // 최신 날짜 우선

      // 오래된 데이터 제거 (최신 80개만 유지)
      final keepCount = (_maxCacheSize * 0.8).round();
      for (int i = keepCount; i < sortedDates.length; i++) {
        _todos.remove(sortedDates[i]);
      }

      debugPrint('캐시 정리 완료: ${_todos.length}개 항목 유지');
    }
  }

  Future<void> _saveTodosForCurrentDate() async {
    try {
      await _storageService.saveTodos(_todos);
    } catch (e) {
      debugPrint('할 일 저장 중 오류: $e');
    }
  }
}
