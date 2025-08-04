import 'package:flutter/material.dart';
import 'package:todo_app/utils/constants.dart';
import '../theme/app_theme.dart';

class StatisticsCards extends StatelessWidget {
  final int totalTodos;
  final int completedTodos;
  final double completionRate;

  const StatisticsCards({
    super.key,
    required this.totalTodos,
    required this.completedTodos,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              'Total',
              totalTodos.toString(),
              Icons.list_alt_rounded,
              colors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: _buildStatCard(
              context,
              'Completed',
              completedTodos.toString(),
              Icons.check_circle_rounded,
              colors.success,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: _buildStatCard(
              context,
              'Completion',
              '${(completionRate * 100).toInt()}%',
              Icons.trending_up_rounded,
              colors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
