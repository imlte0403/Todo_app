import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/screens/statistics_screen.dart';
import 'package:todo_app/utils/constants.dart';
import '../../providers/todo_provider.dart';
import '../../models/todo.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_todo_dialog.dart';
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
      final task = result[StringConstants.taskResult] as String;
      final description = result[StringConstants.descriptionResult] as String?;
      final category = result[StringConstants.categoryResult] as TodoCategory;
      final priority = result[StringConstants.priorityResult] as TodoPriority;
      final dueDate = result[StringConstants.dueDateResult] as DateTime?;

      if (!mounted) return;
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
      final task = result[StringConstants.taskResult] as String;
      final description = result[StringConstants.descriptionResult] as String?;
      final category = result[StringConstants.categoryResult] as TodoCategory;
      final priority = result[StringConstants.priorityResult] as TodoPriority;
      final dueDate = result[StringConstants.dueDateResult] as DateTime?;

      if (!mounted) return;
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
          title: const Text('Delete Todo'),
          content: Text('Are you sure you want to delete "${todo.task}"?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
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
            key: WidgetKeys.statsScreenButton,
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
                key: WidgetKeys.moreActionsButton,
                onSelected: (value) {
                  switch (value) {
                    case StringConstants.toggleAll:
                      final allCompleted = todoProvider.todosForSelectedDate
                          .every((todo) => todo.isDone);
                      todoProvider.toggleAllTodos(!allCompleted);
                      break;
                    case StringConstants.clearCompleted:
                      todoProvider.clearCompletedTodos();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    key: WidgetKeys.toggleAllMenuItem,
                    value: StringConstants.toggleAll,
                    child: Text('Toggle All'),
                  ),
                  const PopupMenuItem<String>(
                    key: WidgetKeys.clearCompletedMenuItem,
                    value: StringConstants.clearCompleted,
                    child: Text('Clear Completed'),
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
              const CustomDatePicker(),
              const Divider(),
              Expanded(
                child: todoProvider.todosForSelectedDate.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        key: WidgetKeys.todoList,
                        itemCount: todoProvider.todosForSelectedDate.length,
                        itemBuilder: (context, index) {
                          final todo = todoProvider.todosForSelectedDate[index];
                          return TodoCard(
                            key: Key(todo.id), // Unique key for each todo item
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
        key: WidgetKeys.addTodoFab,
        onPressed: _addTodo,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            'No todos yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'Add a new todo to get started!',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
