import 'package:flutter/material.dart';
import 'package:todo_app/utils/constants.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../utils/todo_helpers.dart';
import '../theme/app_theme.dart';

/// 개별 할 일 항목을 표시하는 카드 위젯
///
/// 할 일의 제목, 설명, 카테고리, 우선순위, 마감일을 표시하고
/// 완료 상태에 따라 시각적 피드백을 제공합니다.
/// 완료된 할 일은 회색 처리되고 투명도가 적용됩니다.
class TodoCard extends StatefulWidget {
  final Todo todo; // 표시할 할 일 객체
  final TodoProvider todoProvider; // 상태 관리를 위한 Provider
  final VoidCallback? onEdit; // 수정 버튼 콜백
  final VoidCallback? onDelete; // 삭제 버튼 콜백

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

  @override
  void initState() {
    super.initState();
    // 카드 등장 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // 스케일 애니메이션 설정 (0.9에서 1.0으로 확대)
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    // 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    // 애니메이션 컨트롤러 정리
    _animationController.dispose();
    super.dispose();
  }

  // 완료 상태 헬퍼 메서드들
  bool get _isDone => widget.todo.isDone; // 할 일 완료 상태
  double get _opacity => TodoHelpers.getCompletedOpacity(_isDone); // 카드 투명도
  double get _tagOpacity =>
      TodoHelpers.getCompletedTagOpacity(_isDone); // 태그 투명도
  Color _getCompletedColor(Color? originalColor) =>
      TodoHelpers.getCompletedColor(
        originalColor ?? Colors.black87,
        _isDone,
      ); // 완료된 텍스트 색상
  Color _getCompletedIconColor(Color? originalColor) =>
      TodoHelpers.getCompletedIconColor(
        originalColor ?? Colors.grey.shade600,
        _isDone,
      ); // 완료된 아이콘 색상

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    final categoryInfo = TodoHelpers.getCategoryInfo(widget.todo.category);
    final priorityInfo = TodoHelpers.getPriorityInfo(widget.todo.priority);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Opacity(
        opacity: _opacity,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          decoration: BoxDecoration(
            color: _isDone ? colors?.card : colors?.surface,
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
                if (widget.todo.dueDate != null ||
                    (widget.todo.description?.isNotEmpty ?? false))
                  const SizedBox(height: AppDimensions.paddingMedium),
                if (widget.todo.dueDate != null)
                  _buildInfoRow(
                    Icons.event,
                    TodoHelpers.formatDate(widget.todo.dueDate!),
                    colors,
                  ),
                if (widget.todo.description?.isNotEmpty ?? false)
                  _buildDescription(widget.todo.description!, colors),
              ],
            ),
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
            color: _isDone
                ? (colors?.primary ?? Theme.of(context).colorScheme.primary)
                : Colors.grey.shade300,
            width: 2,
          ),
          color: _isDone
              ? (colors?.primary ?? Theme.of(context).colorScheme.primary)
              : Colors.transparent,
        ),
        child: _isDone
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
          decoration: _isDone ? TextDecoration.lineThrough : null,
          color: _getCompletedColor(colors?.textPrimary),
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
          color: _getCompletedIconColor(Colors.grey.shade600),
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 20),
          onPressed: widget.onDelete,
          color: _getCompletedIconColor(Colors.red.shade400),
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
        color: color.withAlpha((26 * _tagOpacity).round()),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: color.withAlpha((77 * _tagOpacity).round()),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.withValues(alpha: _tagOpacity)),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: _tagOpacity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, AppColors? colors) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: _getCompletedIconColor(colors?.textSecondary),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: _getCompletedIconColor(colors?.textSecondary),
          ),
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
          color: _getCompletedColor(colors?.textSecondary),
          fontStyle: FontStyle.italic,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
