import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../models/analysis_models.dart';
import '../services/currency_service.dart';

class AnalysisLineChart extends StatelessWidget {
  final List<MonthlyFinancePoint> points;

  const AnalysisLineChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = points
        .map((item) => item.income > item.expense ? item.income : item.expense)
        .fold<double>(0, (prev, value) => value > prev ? value : prev);

    final maxChartY = maxValue <= 0 ? 100.0 : maxValue * 1.2;

    return AspectRatio(
      aspectRatio: 1.8,
      child: LineChart(
        LineChartData(
          maxY: maxChartY,
          minY: 0,
          lineTouchData: LineTouchData(
            enabled: true,
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  const FlLine(color: Colors.transparent),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 3,
                      color: barData.color ?? Theme.of(context).primaryColor,
                      strokeWidth: 0,
                    ),
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (group) => Colors.transparent,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  // Only show tooltip for the first spot to avoid duplicate boxes
                  if (spot.barIndex != 0) return null;

                  final dateLabel = points[spot.x.toInt()].label;
                  final income = points[spot.x.toInt()].income;
                  final expense = points[spot.x.toInt()].expense;
                  final symbol = Get.find<CurrencyService>().symbol;

                  return LineTooltipItem(
                    'Income: $symbol${income.toInt()}\n',
                    const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: 'Expense: $symbol${expense.toInt()}\n',
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: dateLabel,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxChartY / 4,
            getDrawingHorizontalLine: (value) {
              if (value == 0) return const FlLine(color: Colors.transparent, strokeWidth: 0);
              return FlLine(
                color: AppColors.muted.withValues(alpha: 0.15),
                strokeWidth: 1.5,
                dashArray: [6, 4],
              );
            },
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  if (value == maxChartY || value == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${Get.find<CurrencyService>().symbol}${value.toInt()}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: (points.length / 5).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      points[index].label,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].income)
              ],
              isCurved: true,
              color: AppColors.success,
              barWidth: 1,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: false,
              ),
            ),
            LineChartBarData(
              spots: [
                for (int i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].expense)
              ],
              isCurved: true,
              color: AppColors.danger,
              barWidth: 1,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
