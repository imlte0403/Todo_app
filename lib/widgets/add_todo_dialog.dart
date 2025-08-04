import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/todo_helpers.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// 할 일 추가/수정 다이얼로그 위젯
///
/// 새로운 할 일을 추가하거나 기존 할 일을 수정할 수 있는 다이얼로그입니다.
/// 할 일 제목, 설명, 카테고리, 우선순위, 마감일을 입력받을 수 있습니다.
class AddTodoDialog extends StatefulWidget {
  final Todo? todo; // 수정할 할 일 객체 (새로 추가할 때는 null)

  const AddTodoDialog({super.key, this.todo});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  // 텍스트 입력 컨트롤러들
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // 선택된 옵션들
  TodoCategory _selectedCategory = TodoCategory.other;
  TodoPriority _selectedPriority = TodoPriority.medium;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    // 수정 모드일 때 기존 데이터로 초기화
    if (widget.todo != null) {
      _taskController.text = widget.todo!.task;
      _descriptionController.text = widget.todo!.description ?? '';
      _selectedCategory = widget.todo!.category;
      _selectedPriority = widget.todo!.priority;
      _selectedDueDate = widget.todo!.dueDate;
    }
  }

  @override
  void dispose() {
    // 컨트롤러 정리
    _taskController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    final isEditing = widget.todo != null; // 수정 모드인지 확인

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingExtraLarge),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 다이얼로그 제목
              Text(
                isEditing ? 'Edit Todo' : 'New Todo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors?.textPrimary ?? Colors.black87,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingExtraLarge),

              // 할 일 제목 입력 필드
              TextField(
                key: WidgetKeys.taskTextField,
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter your task',
                  prefixIcon: Icon(Icons.task, color: colors?.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                ),
                autofocus: true, // 자동 포커스
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // 할 일 설명 입력 필드 (선택사항)
              TextField(
                key: WidgetKeys.descriptionTextField,
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add more details',
                  prefixIcon: Icon(
                    Icons.description,
                    color: colors?.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                ),
                maxLines: 3, // 여러 줄 입력 가능
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              _buildDateTimePicker(context, colors),
              const SizedBox(height: AppDimensions.paddingLarge),

              _buildSectionTitle('Category', colors),
              const SizedBox(height: AppDimensions.paddingMedium),
              Wrap(
                spacing: AppDimensions.paddingMedium,
                runSpacing: AppDimensions.paddingMedium,
                children: TodoCategory.values.map((category) {
                  final info = TodoHelpers.getCategoryInfo(category);
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLarge,
                        vertical: AppDimensions.paddingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? info.color
                            : info.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? info.color
                              : info.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            info.icon,
                            size: 16,
                            color: isSelected ? Colors.white : info.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            info.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : info.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              _buildSectionTitle('Priority', colors),
              const SizedBox(height: AppDimensions.paddingMedium),
              Wrap(
                spacing: AppDimensions.paddingMedium,
                runSpacing: AppDimensions.paddingMedium,
                children: TodoPriority.values.map((priority) {
                  final info = TodoHelpers.getPriorityInfo(priority);
                  final isSelected = _selectedPriority == priority;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPriority = priority),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLarge,
                        vertical: AppDimensions.paddingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? info.color
                            : info.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? info.color
                              : info.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            info.icon,
                            size: 16,
                            color: isSelected ? Colors.white : info.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            info.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : info.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.paddingExtraLarge),

              _buildActionButtons(context, isEditing, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColors? colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors?.textPrimary,
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, AppColors? colors) {
    return Row(
      children: [
        Expanded(
          child: _buildPickerContainer(
            context,
            colors,
            icon: Icons.calendar_today,
            text: _selectedDueDate != null
                ? TodoHelpers.formatDate(_selectedDueDate!)
                : 'Select Date',
            onTap: () => _selectDueDate(context),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: _buildPickerContainer(
            context,
            colors,
            icon: Icons.schedule,
            text: _selectedDueDate != null
                ? TodoHelpers.formatTime(_selectedDueDate!)
                : 'Select Time',
            onTap: () => _selectDueTime(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerContainer(
    BuildContext context,
    AppColors? colors, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          border: Border.all(color: colors?.border ?? Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors?.textSecondary, size: 20),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: _selectedDueDate != null
                      ? colors?.textPrimary
                      : colors?.textSecondary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    bool isEditing,
    AppColors? colors,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            key: WidgetKeys.cancelTodoButton,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: ElevatedButton(
            key: WidgetKeys.saveTodoButton,
            onPressed: _saveTodo,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors?.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
            ),
            child: Text(isEditing ? 'Update' : 'Save'),
          ),
        ),
      ],
    );
  }

  void _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDueDate?.hour ?? DateTime.now().hour,
          _selectedDueDate?.minute ?? DateTime.now().minute,
        );
      });
    }
  }

  void _selectDueTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueDate != null
          ? TimeOfDay.fromDateTime(_selectedDueDate!)
          : TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = DateTime(
          _selectedDueDate?.year ?? DateTime.now().year,
          _selectedDueDate?.month ?? DateTime.now().month,
          _selectedDueDate?.day ?? DateTime.now().day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveTodo() {
    final task = _taskController.text.trim();
    if (task.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title cannot be empty.')),
      );
      return;
    }

    final description = _descriptionController.text.trim();

    Navigator.pop(context, {
      StringConstants.taskResult: task,
      StringConstants.descriptionResult: description.isNotEmpty
          ? description
          : null,
      StringConstants.categoryResult: _selectedCategory,
      StringConstants.priorityResult: _selectedPriority,
      StringConstants.dueDateResult: _selectedDueDate,
    });
  }
}
