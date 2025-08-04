import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/todo_helpers.dart';
import '../theme/app_theme.dart';

class AddTodoDialog extends StatefulWidget {
  final Todo? todo; // 수정 시 사용

  const AddTodoDialog({super.key, this.todo});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TodoCategory _selectedCategory = TodoCategory.other;
  TodoPriority _selectedPriority = TodoPriority.medium;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      // 수정 모드
      _taskController.text = widget.todo!.task;
      _descriptionController.text = widget.todo!.description ?? '';
      _selectedCategory = widget.todo!.category;
      _selectedPriority = widget.todo!.priority;
      _selectedDueDate = widget.todo!.dueDate;
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    final isEditing = widget.todo != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              isEditing ? '할 일 수정' : '새로운 할 일',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors?.textPrimary ?? Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // 할 일 제목 입력
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: '할 일 제목',
                hintText: '할 일을 입력하세요',
                prefixIcon: Icon(Icons.task, color: colors?.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // 설명 입력
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: '설명 (선택사항)',
                hintText: '추가 설명을 입력하세요',
                prefixIcon: Icon(
                  Icons.description,
                  color: colors?.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // 마감일 선택
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDueDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors?.border ?? Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: colors?.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDueDate != null
                                ? TodoHelpers.formatDate(_selectedDueDate!)
                                : '마감일 선택',
                            style: TextStyle(
                              color: _selectedDueDate != null
                                  ? colors?.textPrimary
                                  : colors?.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDueTime(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors?.border ?? Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: colors?.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDueDate != null
                                ? TodoHelpers.formatTime(_selectedDueDate!)
                                : '시간 선택',
                            style: TextStyle(
                              color: _selectedDueDate != null
                                  ? colors?.textPrimary
                                  : colors?.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 카테고리 선택
            Text(
              '카테고리',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors?.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TodoCategory.values.map((category) {
                final categoryInfo = TodoHelpers.getCategoryInfo(category);
                final isSelected = _selectedCategory == category;

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? categoryInfo.color
                          : categoryInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? categoryInfo.color
                            : categoryInfo.color.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoryInfo.icon,
                          size: 16,
                          color: isSelected ? Colors.white : categoryInfo.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          categoryInfo.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : categoryInfo.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 우선순위 선택
            Text(
              '우선순위',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors?.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TodoPriority.values.map((priority) {
                final priorityInfo = TodoHelpers.getPriorityInfo(priority);
                final isSelected = _selectedPriority == priority;

                return GestureDetector(
                  onTap: () => setState(() => _selectedPriority = priority),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? priorityInfo.color
                          : priorityInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? priorityInfo.color
                            : priorityInfo.color.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          priorityInfo.icon,
                          size: 16,
                          color: isSelected ? Colors.white : priorityInfo.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          priorityInfo.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : priorityInfo.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTodo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors?.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isEditing ? '수정' : '저장'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDueDate?.hour ?? 0,
          _selectedDueDate?.minute ?? 0,
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
    if (task.isEmpty) return;

    final description = _descriptionController.text.trim();
    final finalDescription = description.isEmpty ? null : description;

    Navigator.pop(context, {
      'task': task,
      'description': finalDescription,
      'category': _selectedCategory,
      'priority': _selectedPriority,
      'dueDate': _selectedDueDate,
    });
  }
}
