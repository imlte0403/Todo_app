import 'package:flutter/material.dart';
import 'package:todo_app/utils/constants.dart';
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

class _TodoCardState extends State<TodoCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
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

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: widget.todo.isDone ? colors?.card : colors?.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(context, colors),
              const SizedBox(height: AppDimensions.paddingMedium),
              _buildTags(categoryInfo, priorityInfo),
              if (widget.todo.dueDate != null || (widget.todo.description?.isNotEmpty ?? false))
                const SizedBox(height: AppDimensions.paddingMedium),
              if (widget.todo.dueDate != null)
                _buildInfoRow(Icons.event, TodoHelpers.formatDate(widget.todo.dueDate!), colors),
              if (widget.todo.description?.isNotEmpty ?? false)
                _buildDescription(widget.todo.description!, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, AppColors? colors) {
    return Row(
      children: [
        _buildCheckbox(context, colors),
        const SizedBox(width: AppDimensions.paddingLarge),
        _buildTaskTitle(colors),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildCheckbox(BuildContext context, AppColors? colors) {
    return GestureDetector(
      onTap: () {
        widget.todoProvider.toggleTodoStatus(widget.todo.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.todo.isDone
                ? (colors?.primary ?? Theme.of(context).colorScheme.primary)
                : Colors.grey.shade300,
            width: 2,
          ),
          color: widget.todo.isDone
              ? (colors?.primary ?? Theme.of(context).colorScheme.primary)
              : Colors.transparent,
        ),
        child: widget.todo.isDone
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildTaskTitle(AppColors? colors) {
    return Expanded(
      child: Text(
        widget.todo.task,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          decoration: widget.todo.isDone ? TextDecoration.lineThrough : null,
          color: widget.todo.isDone ? colors?.textSecondary : colors?.textPrimary,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: widget.onEdit,
          color: Colors.grey.shade600,
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 20),
          onPressed: widget.onDelete,
          color: Colors.red.shade400,
        ),
      ],
    );
  }

  Widget _buildTags(CategoryInfo categoryInfo, PriorityInfo priorityInfo) {
    return Row(
      children: [
        _buildTag(categoryInfo.icon, categoryInfo.name, categoryInfo.color),
        const SizedBox(width: AppDimensions.paddingMedium),
        _buildTag(priorityInfo.icon, priorityInfo.name, priorityInfo.color),
      ],
    );
  }

  Widget _buildTag(IconData icon, String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color.withAlpha(77), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, AppColors? colors) {
    return Row(
      children: [
        Icon(icon, size: 14, color: colors?.textSecondary),
        const SizedBox(width: AppDimensions.paddingSmall),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: colors?.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDescription(String description, AppColors? colors) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 12,
          color: colors?.textSecondary,
          fontStyle: FontStyle.italic,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
