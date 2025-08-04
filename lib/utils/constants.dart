
import 'package:flutter/material.dart';

// App Dimensions
class AppDimensions {
  static const double paddingSmall = 4.0;
  static const double paddingMedium = 8.0;
  static const double paddingLarge = 16.0;
  static const double paddingExtraLarge = 24.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 20.0;
}

// Keys for Widgets
class WidgetKeys {
  static const Key addTodoFab = Key('add_todo_fab');
  static const Key statsScreenButton = Key('stats_screen_button');
  static const Key moreActionsButton = Key('more_actions_button');
  static const Key toggleAllMenuItem = Key('toggle_all_menu_item');
  static const Key clearCompletedMenuItem = Key('clear_completed_menu_item');
  static const Key todoList = Key('todo_list');
  static const Key taskTextField = Key('task_text_field');
  static const Key descriptionTextField = Key('description_text_field');
  static const Key saveTodoButton = Key('save_todo_button');
  static const Key cancelTodoButton = Key('cancel_todo_button');
}

// String Constants
class StringConstants {
  // Dialog results
  static const String taskResult = 'task';
  static const String descriptionResult = 'description';
  static const String categoryResult = 'category';
  static const String priorityResult = 'priority';
  static const String dueDateResult = 'dueDate';

  // Popup Menu
  static const String toggleAll = 'toggle_all';
  static const String clearCompleted = 'clear_completed';
}
