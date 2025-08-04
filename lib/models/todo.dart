// lib/models/todo.dart
//import 'dart:convert';
import 'package:flutter/foundation.dart';

enum TodoCategory { work, personal, study, health, shopping, other }

enum TodoPriority { low, medium, high, urgent }

class Todo {
  final String id;
  final String task;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TodoCategory category;
  final TodoPriority priority;
  final String? description;

  Todo({
    required this.id,
    required this.task,
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
    this.category = TodoCategory.other,
    this.priority = TodoPriority.medium,
    this.description,
  });

  // JSON 직렬화를 위한 메서드들
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task': task,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'category': category.name,
      'priority': priority.name,
      'description': description,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'];
      final task = json['task'];
      final isDone = json['isDone'];
      final createdAt = json['createdAt'];
      final dueDate = json['dueDate'];
      final category = json['category'];
      final priority = json['priority'];
      final description = json['description'];

      return Todo(
        id: id is String ? id : '',
        task: task is String ? task : '',
        isDone: isDone is bool ? isDone : false,
        createdAt: createdAt is String
            ? DateTime.tryParse(createdAt) ?? DateTime.now()
            : DateTime.now(),
        dueDate: dueDate is String ? DateTime.tryParse(dueDate) : null,
        category: category is String
            ? TodoCategory.values.firstWhere(
                (e) => e.name == category,
                orElse: () => TodoCategory.other,
              )
            : TodoCategory.other,
        priority: priority is String
            ? TodoPriority.values.firstWhere(
                (e) => e.name == priority,
                orElse: () => TodoPriority.medium,
              )
            : TodoPriority.medium,
        description: description is String ? description : null,
      );
    } catch (e) {
      debugPrint('Todo.fromJson 오류: $e, json: $json');
      // 기본값으로 안전한 Todo 객체 반환
      return Todo(
        id: '',
        task: '오류가 발생한 할 일',
        isDone: false,
        createdAt: DateTime.now(),
        dueDate: null,
        category: TodoCategory.other,
        priority: TodoPriority.medium,
        description: null,
      );
    }
  }

  // copyWith 메서드 (불변성 유지)
  Todo copyWith({
    String? id,
    String? task,
    bool? isDone,
    DateTime? createdAt,
    DateTime? dueDate,
    TodoCategory? category,
    TodoPriority? priority,
    String? description,
  }) {
    return Todo(
      id: id ?? this.id,
      task: task ?? this.task,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo &&
        other.id == id &&
        other.task == task &&
        other.isDone == isDone &&
        other.createdAt == createdAt &&
        other.dueDate == dueDate &&
        other.category == category &&
        other.priority == priority &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        task.hashCode ^
        isDone.hashCode ^
        createdAt.hashCode ^
        dueDate.hashCode ^
        category.hashCode ^
        priority.hashCode ^
        description.hashCode;
  }

  @override
  String toString() {
    return 'Todo(id: $id, task: $task, isDone: $isDone, createdAt: $createdAt, dueDate: $dueDate, category: $category, priority: $priority, description: $description)';
  }
}
