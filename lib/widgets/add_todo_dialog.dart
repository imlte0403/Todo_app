import 'package:flutter/material.dart';
import 'package:todo_app/widgets/choice_chip.dart';
import '../models/todo.dart';
import '../utils/todo_helpers.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class AddTodoDialog extends StatefulWidget {
  final Todo? todo; // For editing

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge)),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingExtraLarge),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Todo' : 'New Todo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors?.textPrimary ?? Colors.black87,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingExtraLarge),

              TextField(
                key: WidgetKeys.taskTextField,
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter your task',
                  prefixIcon: Icon(Icons.task, color: colors?.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

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
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                maxLines: 3,
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
                  return ChoiceChip<TodoCategory>(
                    value: category,
                    selectedValue: _selectedCategory,
                    onSelected: (c) => setState(() => _selectedCategory = c),
                    label: info.name,
                    icon: info.icon,
                    color: info.color,
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
                  return ChoiceChip<TodoPriority>(
                    value: priority,
                    selectedValue: _selectedPriority,
                    onSelected: (p) => setState(() => _selectedPriority = p),
                    label: info.name,
                    icon: info.icon,
                    color: info.color,
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

  Widget _buildPickerContainer(BuildContext context, AppColors? colors, {required IconData icon, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          border: Border.all(
            color: colors?.border ?? Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors?.textSecondary, size: 20),
            const SizedBox(width: AppDimensions.paddingMedium),
            Text(
              text,
              style: TextStyle(
                color: _selectedDueDate != null ? colors?.textPrimary : colors?.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isEditing, AppColors? colors) {
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
      StringConstants.descriptionResult: description.isNotEmpty ? description : null,
      StringConstants.categoryResult: _selectedCategory,
      StringConstants.priorityResult: _selectedPriority,
      StringConstants.dueDateResult: _selectedDueDate,
    });
  }
}
