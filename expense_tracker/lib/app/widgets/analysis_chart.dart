import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/analysis_models.dart';

class AnalysisChart extends StatelessWidget {
  final List<MonthlyFinancePoint> points;

  const AnalysisChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = points
        .map((item) => item.income > item.expense ? item.income : item.expense)
        .fold<double>(0, (prev, value) => value > prev ? value : prev);

    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          maxY: maxValue <= 0 ? 100 : maxValue * 1.25,
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            for (int index = 0; index < points.length; index++)
              BarChartGroupData(
                x: index,
                barsSpace: 6,
                barRods: [
                  BarChartRodData(
                    toY: points[index].income,
                    color: Colors.green,
                    width: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: points[index].expense,
                    color: Colors.red,
                    width: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      points[index].label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
