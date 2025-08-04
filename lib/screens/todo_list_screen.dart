// lib/screens/todo_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/screens/statistics_screen.dart';
import '../../providers/todo_provider.dart';
import '../../models/todo.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_todo_dialog.dart';
import '../theme/app_theme.dart';
import 'package:todo_app/widgets/custom_date_picker.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {

  void _addTodo() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );

    if (result != null) {
      final task = result['task'] as String;
      final description = result['description'] as String?;
      final category = result['category'] as TodoCategory;
      final priority = result['priority'] as TodoPriority;
      final dueDate = result['dueDate'] as DateTime?;

      context.read<TodoProvider>().addTodo(
        task,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
      );
    }
  }

  void _showEditDialog(Todo todo) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddTodoDialog(todo: todo),
    );

    if (result != null) {
      final task = result['task'] as String;
      final description = result['description'] as String?;
      final category = result['category'] as TodoCategory;
      final priority = result['priority'] as TodoPriority;
      final dueDate = result['dueDate'] as DateTime?;

      context.read<TodoProvider>().updateTodo(
        todo.id,
        task: task,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
      );
    }
  }

  void _showDeleteConfirmation(Todo todo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('할 일 삭제'),
          content: Text('"${todo.task}"를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                context.read<TodoProvider>().deleteTodo(todo.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
          ),
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              if (todoProvider.todosForSelectedDate.isEmpty) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'toggle_all':
                      final allCompleted = todoProvider.todosForSelectedDate
                          .every((todo) => todo.isDone);
                      todoProvider.toggleAllTodos(!allCompleted);
                      break;
                    case 'clear_completed':
                      todoProvider.clearCompletedTodos();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'toggle_all',
                    child: Text('모두 완료/해제'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'clear_completed',
                    child: Text('완료된 항목 삭제'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 달력
              const CustomDatePicker(),

              const Divider(),

              // 할 일 목록
              Expanded(
                child: todoProvider.todosForSelectedDate.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '할 일이 없습니다',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '새로운 할 일을 추가해보세요!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: todoProvider.todosForSelectedDate.length,
                        itemBuilder: (context, index) {
                          final todo = todoProvider.todosForSelectedDate[index];
                          return TodoCard(
                            todo: todo,
                            todoProvider: todoProvider,
                            onEdit: () => _showEditDialog(todo),
                            onDelete: () => _showDeleteConfirmation(todo),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
