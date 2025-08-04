import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/utils/constants.dart';
import '../providers/todo_provider.dart';
import '../widgets/statistics_cards.dart';
import '../theme/app_theme.dart';
import '../utils/todo_helpers.dart';
import '../models/todo.dart'; // Todo 모델 import 추가

/// 할 일 통계 화면
///
/// 사용자의 할 일 완료 현황을 시각적으로 보여주는 화면입니다.
/// 총 할 일 개수, 완료된 할 일 개수, 완료 비율을 카드 형태로 표시하고
/// 카테고리별, 우선순위별 분석도 제공합니다.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _cardController;
  late Animation<double> _progressAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

    // 진행률 애니메이션 컨트롤러 초기화
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 카드 등장 애니메이션 컨트롤러 초기화
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 진행률 애니메이션 (0에서 실제 값까지)
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    // 카드 스케일 애니메이션
    _cardAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );

    // 애니메이션 시작
    _cardController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('통계', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 메인 통계 카드들
                ScaleTransition(
                  scale: _cardAnimation,
                  child: StatisticsCards(
                    totalTodos: todoProvider.totalTodosCount,
                    completedTodos: todoProvider.completedTodosCount,
                    completionRate: todoProvider.completionRate,
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingExtraLarge),

                // 진행률 섹션
                _buildProgressSection(todoProvider),

                const SizedBox(height: AppDimensions.paddingExtraLarge),

                // 카테고리 분석
                _buildCategoryAnalysis(todoProvider),

                const SizedBox(height: AppDimensions.paddingExtraLarge),

                // 우선순위 분석
                _buildPriorityAnalysis(todoProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 진행률 섹션을 빌드합니다.
  Widget _buildProgressSection(TodoProvider todoProvider) {
    final colors = Theme.of(context).extension<AppColors>();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingExtraLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors?.primary.withValues(alpha: 0.1) ??
                Colors.blue.withValues(alpha: 0.1),
            colors?.accent.withValues(alpha: 0.1) ??
                Colors.purple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
        border: Border.all(
          color: colors?.border ?? Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '전체 진행률',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors?.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingExtraLarge),

          // 원형 진행률 표시기
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 배경 원
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                  ),
                  // 진행률 원
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value:
                              _progressAnimation.value *
                              todoProvider.completionRate,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors?.primary ?? Colors.blue,
                          ),
                        ),
                      );
                    },
                  ),
                  // 중앙 텍스트
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          final animatedRate =
                              _progressAnimation.value *
                              todoProvider.completionRate;
                          return Text(
                            '${(animatedRate * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: colors?.primary,
                            ),
                          );
                        },
                      ),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors?.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingExtraLarge),

          // 상세 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem(
                '완료',
                todoProvider.completedTodosCount.toString(),
                colors?.success ?? Colors.green,
              ),
              _buildDetailItem(
                '진행중',
                (todoProvider.totalTodosCount -
                        todoProvider.completedTodosCount)
                    .toString(),
                colors?.warning ?? Colors.orange,
              ),
              _buildDetailItem(
                '총 개수',
                todoProvider.totalTodosCount.toString(),
                colors?.primary ?? Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 상세 정보 아이템을 빌드합니다.
  Widget _buildDetailItem(String label, String value, Color color) {
    return Column(
      children: [
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
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// 카테고리 분석 섹션을 빌드합니다.
  Widget _buildCategoryAnalysis(TodoProvider todoProvider) {
    final colors = Theme.of(context).extension<AppColors>();
    final categoryStats = _getCategoryStats(todoProvider);

    return _buildAnalysisSection(
      title: '카테고리별 분석',
      items: categoryStats.map((stat) {
        final categoryInfo = TodoHelpers.getCategoryInfo(stat['category']);
        return _buildAnalysisItem(
          icon: categoryInfo.icon,
          label: categoryInfo.name,
          count: stat['count'],
          color: categoryInfo.color,
        );
      }).toList(),
      colors: colors,
    );
  }

  /// 우선순위 분석 섹션을 빌드합니다.
  Widget _buildPriorityAnalysis(TodoProvider todoProvider) {
    final colors = Theme.of(context).extension<AppColors>();
    final priorityStats = _getPriorityStats(todoProvider);

    return _buildAnalysisSection(
      title: '우선순위별 분석',
      items: priorityStats.map((stat) {
        final priorityInfo = TodoHelpers.getPriorityInfo(stat['priority']);
        return _buildAnalysisItem(
          icon: priorityInfo.icon,
          label: priorityInfo.name,
          count: stat['count'],
          color: priorityInfo.color,
        );
      }).toList(),
      colors: colors,
    );
  }

  /// 분석 섹션을 빌드합니다.
  Widget _buildAnalysisSection({
    required String title,
    required List<Widget> items,
    required AppColors? colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingExtraLarge),
      decoration: BoxDecoration(
        color: colors?.surface ?? Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
        border: Border.all(color: colors?.border ?? Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors?.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          ...items,
        ],
      ),
    );
  }

  /// 분석 아이템을 빌드합니다.
  Widget _buildAnalysisItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppDimensions.paddingLarge),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리별 통계를 계산합니다.
  List<Map<String, dynamic>> _getCategoryStats(TodoProvider todoProvider) {
    final stats = <TodoCategory, int>{};

    // 모든 할 일을 순회하며 카테고리별 개수 집계
    for (final todoList in todoProvider.todos.values) {
      for (final todo in todoList) {
        stats[todo.category] = (stats[todo.category] ?? 0) + 1;
      }
    }

    // 개수 기준으로 내림차순 정렬
    return stats.entries
        .map((entry) => {'category': entry.key, 'count': entry.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }

  /// 우선순위별 통계를 계산합니다.
  List<Map<String, dynamic>> _getPriorityStats(TodoProvider todoProvider) {
    final stats = <TodoPriority, int>{};

    // 모든 할 일을 순회하며 우선순위별 개수 집계
    for (final todoList in todoProvider.todos.values) {
      for (final todo in todoList) {
        stats[todo.priority] = (stats[todo.priority] ?? 0) + 1;
      }
    }

    // 개수 기준으로 내림차순 정렬
    return stats.entries
        .map((entry) => {'priority': entry.key, 'count': entry.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }
}
