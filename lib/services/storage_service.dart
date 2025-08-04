// lib/services/storage_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class StorageService {
  static const String _todosKey = 'todos';
  static StorageService? _instance;
  SharedPreferences? _prefs;

  // Private constructor
  StorageService._internal();

  // Singleton instance
  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  // Initialize SharedPreferences
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
      // Handle initialization error, maybe by using a fallback storage
    }
  }

  // Save all todos
  Future<bool> saveTodos(Map<DateTime, List<Todo>> todos) async {
    if (_prefs == null) return false;
    try {
      if (!_validateTodos(todos)) {
        throw Exception('Invalid todo data');
      }

      final Map<String, List<Map<String, dynamic>>> serializedTodos = {};
      todos.forEach((date, todoList) {
        final String dateKey = _dateToString(date);
        serializedTodos[dateKey] = todoList.map((todo) => todo.toJson()).toList();
      });

      final String jsonString = jsonEncode(serializedTodos);
      return await _prefs!.setString(_todosKey, jsonString);
    } catch (e) {
      debugPrint('Error saving todos: $e');
      return false;
    }
  }

  // Load all todos
  Future<Map<DateTime, List<Todo>>> loadTodos() async {
    if (_prefs == null) return {};
    try {
      final String? jsonString = _prefs!.getString(_todosKey);
      if (jsonString == null || jsonString.isEmpty) return {};

      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final Map<DateTime, List<Todo>> todos = {};

      decoded.forEach((dateString, todoListJson) {
        try {
          final DateTime date = _stringToDate(dateString);
          final List<dynamic> todoJsonList = todoListJson as List<dynamic>;

          todos[date] = todoJsonList
              .map<Todo>((json) => Todo.fromJson(json as Map<String, dynamic>))
              .toList();
        } catch (e) {
          debugPrint('Error parsing todos for date $dateString: $e');
          // Skip corrupted data for this date
        }
      });

      return todos;
    } catch (e) {
      debugPrint('Error loading todos: $e');
      // Consider clearing corrupted data
      // await clearAllTodos();
      return {};
    }
  }

  // Clear all data
  Future<bool> clearAllTodos() async {
    if (_prefs == null) return false;
    try {
      return await _prefs!.remove(_todosKey);
    } catch (e) {
      debugPrint('Error clearing data: $e');
      return false;
    }
  }

  // Convert DateTime to String
  String _dateToString(DateTime date) {
    return date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
  }

  // Convert String to DateTime
  DateTime _stringToDate(String dateString) {
    return DateTime.parse(dateString);
  }

  // Data validation method
  bool _validateTodos(Map<DateTime, List<Todo>> todos) {
    try {
      for (final entry in todos.entries) {
        if (entry.key.year < 2000 || entry.key.year > 2100) {
          debugPrint('Invalid date found: ${entry.key}');
          return false;
        }

        for (final todo in entry.value) {
          if (todo.id.trim().isEmpty) {
            debugPrint('Empty todo ID found for task: ${todo.task}');
            return false;
          }
          if (todo.task.trim().isEmpty) {
            debugPrint('Empty todo task found for id: ${todo.id}');
            return false;
          }
          if (todo.createdAt.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
            debugPrint('Future creation time found: ${todo.createdAt}');
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      debugPrint('Data validation error: $e');
      return false;
    }
  }
}

// Example usage:
// await StorageService.instance.init(); // Initialize in main.dart
// bool success = await StorageService.instance.saveTodos(todos);
// final todos = await StorageService.instance.loadTodos();
