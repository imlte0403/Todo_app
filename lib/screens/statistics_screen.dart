import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';

/// 할 일 통계 화면
///
/// 사용자의 할 일 완료 현황을 시각적으로 보여주는 화면입니다.
/// 총 할 일 개수, 완료된 할 일 개수, 완료 비율을 카드 형태로 표시합니다.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 TodoProvider 인스턴스 가져오기
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('할 일 통계')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 총 할 일 개수 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '총 할 일',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${todoProvider.totalTodosCount}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 완료된 할 일 개수 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '완료된 할 일',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${todoProvider.completedTodosCount}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 완료 비율 카드 (진행률 바 포함)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '완료 비율',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    // 진행률 바 표시
                    LinearProgressIndicator(
                      value: todoProvider.completionRate,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    // 완료 비율을 퍼센트로 표시 (소수점 첫째 자리까지)
                    Text(
                      '${(todoProvider.completionRate * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
