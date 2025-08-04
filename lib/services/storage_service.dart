// lib/services/storage_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class StorageService {
  static const String _todosKey = 'todos';
  static StorageService? _instance;
  SharedPreferences? _prefs;

  // 싱글톤 패턴
  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  StorageService._internal();

  // SharedPreferences 초기화
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 모든 할 일 저장
  Future<void> saveTodos(Map<DateTime, List<Todo>> todos) async {
    try {
      // 데이터 검증
      if (!_validateTodos(todos)) {
        throw Exception('유효하지 않은 데이터');
      }

      final Map<String, List<Map<String, dynamic>>> serializedTodos = {};

      todos.forEach((date, todoList) {
        final String dateKey = _dateToString(date);
        serializedTodos[dateKey] = todoList
            .map((todo) => todo.toJson())
            .toList();
      });

      final String jsonString = jsonEncode(serializedTodos);
      await _prefs?.setString(_todosKey, jsonString);
    } catch (e) {
      debugPrint('할 일 저장 중 오류 발생: $e');
      rethrow; // 상위 레이어에서 처리하도록
    }
  }

  // 모든 할 일 불러오기
  Future<Map<DateTime, List<Todo>>> loadTodos() async {
    try {
      final String? jsonString = _prefs?.getString(_todosKey);
      if (jsonString == null) return {};

      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final Map<DateTime, List<Todo>> todos = {};

      decoded.forEach((dateString, todoListJson) {
        final DateTime date = _stringToDate(dateString);
        final List<dynamic> todoJsonList = todoListJson as List<dynamic>;

        todos[date] = todoJsonList
            .map<Todo>((json) => Todo.fromJson(json as Map<String, dynamic>))
            .toList();
      });

      return todos;
    } catch (e) {
      debugPrint('할 일 불러오기 중 오류 발생: $e');
      return {};
    }
  }

  // 특정 날짜의 할 일 저장
  Future<void> saveTodosForDate(DateTime date, List<Todo> todos) async {
    try {
      final Map<DateTime, List<Todo>> allTodos = await loadTodos();
      allTodos[_normalizeDate(date)] = todos;
      await saveTodos(allTodos);
    } catch (e) {
      debugPrint('특정 날짜 할 일 저장 중 오류 발생: $e');
    }
  }

  // 특정 날짜의 할 일 불러오기
  Future<List<Todo>> loadTodosForDate(DateTime date) async {
    try {
      final Map<DateTime, List<Todo>> allTodos = await loadTodos();
      return allTodos[_normalizeDate(date)] ?? [];
    } catch (e) {
      debugPrint('특정 날짜 할 일 불러오기 중 오류 발생: $e');
      return [];
    }
  }

  // 모든 데이터 삭제
  Future<void> clearAllTodos() async {
    try {
      await _prefs?.remove(_todosKey);
    } catch (e) {
      debugPrint('데이터 삭제 중 오류 발생: $e');
    }
  }

  // 날짜 정규화 (시간 정보 제거)
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  // DateTime을 문자열로 변환
  String _dateToString(DateTime date) {
    return date.toIso8601String().split('T')[0]; // YYYY-MM-DD 형식
  }

  // 문자열을 DateTime으로 변환
  DateTime _stringToDate(String dateString) {
    return DateTime.parse(dateString);
  }

  // 데이터 검증 메서드
  bool _validateTodos(Map<DateTime, List<Todo>> todos) {
    try {
      for (final entry in todos.entries) {
        // 날짜 검증
        if (entry.key.year < 1900 || entry.key.year > 2100) {
          debugPrint('유효하지 않은 날짜: ${entry.key}');
          return false;
        }

        // 할 일 목록 검증
        for (final todo in entry.value) {
          if (todo.task.trim().isEmpty) {
            debugPrint('빈 할 일 발견: ${todo.id}');
            return false;
          }
          if (todo.id.isEmpty) {
            debugPrint('빈 ID 발견: ${todo.task}');
            return false;
          }
          if (todo.createdAt.isAfter(
            DateTime.now().add(const Duration(days: 1)),
          )) {
            debugPrint('미래의 생성 시간: ${todo.createdAt}');
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      debugPrint('데이터 검증 중 오류: $e');
      return false;
    }
  }
}

// 사용 예시:
// await StorageService.instance.init(); // main.dart에서 초기화
// await StorageService.instance.saveTodosForDate(DateTime.now(), todos);
// final todos = await StorageService.instance.loadTodosForDate(DateTime.now());
