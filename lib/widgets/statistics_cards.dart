import 'package:flutter/material.dart';
import 'package:todo_app/utils/constants.dart';
import '../theme/app_theme.dart';

/// 통계 정보를 카드 형태로 표시하는 위젯
///
/// 총 할 일 개수, 완료된 할 일 개수, 완료 비율을 시각적으로 보여줍니다.
/// 각 통계는 아이콘, 수치, 제목을 포함한 카드로 표시됩니다.
class StatisticsCards extends StatelessWidget {
  final int totalTodos; // 총 할 일 개수
  final int completedTodos; // 완료된 할 일 개수
  final double completionRate; // 완료 비율 (0.0 ~ 1.0)

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
          // 총 할 일 개수 카드
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
          // 완료된 할 일 개수 카드
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
          // 완료 비율 카드
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

  /// 개별 통계 카드를 빌드합니다.
  ///
  /// [context] - 빌드 컨텍스트
  /// [title] - 카드 제목
  /// [value] - 표시할 수치
  /// [icon] - 카드 아이콘
  /// [color] - 카드 색상
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
          // 아이콘 컨테이너
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(26), // 아이콘 배경색 (투명도 적용)
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          // 수치 텍스트
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          // 제목 텍스트
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
