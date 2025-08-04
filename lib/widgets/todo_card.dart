import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../utils/todo_helpers.dart';
import '../theme/app_theme.dart';

class TodoCard extends StatefulWidget {
  final Todo todo;
  final TodoProvider todoProvider;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.todoProvider,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    final categoryInfo = TodoHelpers.getCategoryInfo(widget.todo.category);
    final priorityInfo = TodoHelpers.getPriorityInfo(widget.todo.priority);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.todo.isDone ? Colors.grey.shade200 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단: 체크박스, 제목, 액션 버튼
                    Row(
                      children: [
                        // 체크박스 (원형)
                        GestureDetector(
                          onTap: () {
                            widget.todoProvider.toggleTodoStatus(
                              widget.todo.id,
                            );
                            _animateCheck();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.todo.isDone
                                    ? (colors?.primary ??
                                          Theme.of(context).colorScheme.primary)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              color: widget.todo.isDone
                                  ? (colors?.primary ??
                                        Theme.of(context).colorScheme.primary)
                                  : Colors.transparent,
                            ),
                            child: widget.todo.isDone
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // 제목
                        Expanded(
                          child: Text(
                            widget.todo.task,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: widget.todo.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: widget.todo.isDone
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                            ),
                          ),
                        ),

                        // 액션 버튼들
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, size: 20),
                              onPressed: widget.onEdit,
                              color: Colors.grey.shade600,
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, size: 20),
                              onPressed: widget.onDelete,
                              color: Colors.red.shade400,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 중간: 카테고리와 우선순위
                    Row(
                      children: [
                        // 카테고리 태그
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryInfo.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: categoryInfo.color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                categoryInfo.icon,
                                size: 12,
                                color: categoryInfo.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                categoryInfo.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: categoryInfo.color,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // 우선순위 표시
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityInfo.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: priorityInfo.color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                priorityInfo.icon,
                                size: 12,
                                color: priorityInfo.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                priorityInfo.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: priorityInfo.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 하단: 시간 정보
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '생성: ${TodoHelpers.formatTime(widget.todo.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (widget.todo.dueDate != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.event,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '마감: ${TodoHelpers.formatDate(widget.todo.dueDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // 설명이 있는 경우
                    if (widget.todo.description != null &&
                        widget.todo.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.todo.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _animateCheck() {
    _animationController.reverse().then((_) {
      _animationController.forward();
    });
  }
}
