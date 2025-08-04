import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/screens/statistics_screen.dart';
import 'package:todo_app/utils/constants.dart';
import '../../providers/todo_provider.dart';
import '../../models/todo.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_todo_dialog.dart';
import 'package:todo_app/widgets/custom_date_picker.dart';

/// 메인 할 일 목록 화면
///
/// 사용자가 할 일을 추가, 수정, 삭제하고 완료 상태를 관리할 수 있는 메인 화면입니다.
/// 통계 화면으로의 이동과 일괄 작업(전체 토글, 완료된 항목 삭제) 기능을 제공합니다.
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  /// 새로운 할 일 추가 다이얼로그를 표시하고 결과를 처리합니다.
  void _addTodo() async {
    // 할 일 추가 다이얼로그 표시
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );

    // 다이얼로그에서 반환된 데이터가 있으면 할 일 추가
    if (result != null) {
      final task = result[StringConstants.taskResult] as String;
      final description = result[StringConstants.descriptionResult] as String?;
      final category = result[StringConstants.categoryResult] as TodoCategory;
      final priority = result[StringConstants.priorityResult] as TodoPriority;
      final dueDate = result[StringConstants.dueDateResult] as DateTime?;

      // 위젯이 여전히 마운트되어 있는지 확인 (async gap 방지)
      if (!mounted) return;

      // TodoProvider를 통해 새로운 할 일 추가
      context.read<TodoProvider>().addTodo(
        task,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
      );
    }
  }

  /// 기존 할 일 수정 다이얼로그를 표시하고 결과를 처리합니다.
  void _showEditDialog(Todo todo) async {
    // 할 일 수정 다이얼로그 표시 (기존 데이터로 초기화)
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddTodoDialog(todo: todo),
    );

    // 다이얼로그에서 반환된 데이터가 있으면 할 일 수정
    if (result != null) {
      final task = result[StringConstants.taskResult] as String;
      final description = result[StringConstants.descriptionResult] as String?;
      final category = result[StringConstants.categoryResult] as TodoCategory;
      final priority = result[StringConstants.priorityResult] as TodoPriority;
      final dueDate = result[StringConstants.dueDateResult] as DateTime?;

      // 위젯이 여전히 마운트되어 있는지 확인 (async gap 방지)
      if (!mounted) return;

      // TodoProvider를 통해 할 일 수정
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

  /// 할 일 삭제 확인 다이얼로그를 표시합니다.
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
                // 할 일 삭제 후 다이얼로그 닫기
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
          // 통계 화면으로 이동하는 버튼
          IconButton(
            key: WidgetKeys.statsScreenButton,
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          // 일괄 작업 메뉴 (할 일이 있을 때만 표시)
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              // 할 일이 없으면 메뉴 버튼 숨기기
              if (todoProvider.todosForSelectedDate.isEmpty) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                key: WidgetKeys.moreActionsButton,
                onSelected: (value) {
                  switch (value) {
                    case StringConstants.toggleAll:
                      // 모든 할 일의 완료 상태를 토글
                      final allCompleted = todoProvider.todosForSelectedDate
                          .every((todo) => todo.isDone);
                      todoProvider.toggleAllTodos(!allCompleted);
                      break;
                    case StringConstants.clearCompleted:
                      // 완료된 할 일들 모두 삭제
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
          // 로딩 중일 때 로딩 인디케이터 표시
          if (todoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 날짜 선택기
              const CustomDatePicker(),
              const Divider(),
              Expanded(
                child: todoProvider.todosForSelectedDate.isEmpty
                    ? _buildEmptyState(context) // 할 일이 없을 때 빈 상태 표시
                    : ListView.builder(
                        // 할 일 목록 표시
                        key: WidgetKeys.todoList,
                        itemCount: todoProvider.todosForSelectedDate.length,
                        itemBuilder: (context, index) {
                          final todo = todoProvider.todosForSelectedDate[index];
                          return TodoCard(
                            key: Key(todo.id), // 각 할 일 항목에 고유 키 할당
                            todo: todo,
                            todoProvider: todoProvider,
                            onEdit: () => _showEditDialog(todo), // 수정 콜백
                            onDelete: () =>
                                _showDeleteConfirmation(todo), // 삭제 콜백
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      // 새로운 할 일 추가 버튼
      floatingActionButton: FloatingActionButton(
        key: WidgetKeys.addTodoFab,
        onPressed: _addTodo,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 할 일이 없을 때 표시할 빈 상태 위젯을 빌드합니다.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 빈 상태 아이콘
          Icon(
            Icons.task_alt,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          // 빈 상태 메시지
          Text(
            'No todos yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          // 안내 메시지
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
