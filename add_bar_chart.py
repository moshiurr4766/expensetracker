import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# 1. Add the _CategoryBarChart class at the end
bar_chart_class = """
class _CategoryBarChart extends StatelessWidget {
  final List<dynamic> points;
  const _CategoryBarChart({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    
    final topPoints = points.take(5).toList();
    final maxAmount = topPoints.fold<double>(0.0, (m, e) => e.amount > m ? e.amount : m);
    if (maxAmount == 0) return const SizedBox.shrink();
    
    final colors = [
      const Color(0xFF4361EE),
      const Color(0xFFF72585),
      const Color(0xFF7209B7),
      const Color(0xFF3A0CA3),
      const Color(0xFF4CC9F0),
    ];

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAmount * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${topPoints[group.x].label}\\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  children: [
                    TextSpan(
                      text: AppFormatters.currency.format(rod.toY),
                      style: const TextStyle(color: Colors.yellowAccent, fontSize: 14),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < topPoints.length) {
                    final label = topPoints[index].label;
                    final shortLabel = label.length > 6 ? '${label.substring(0, 5)}..' : label;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        shortLabel,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxAmount / 4 > 0 ? maxAmount / 4 : 100,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(topPoints.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: topPoints[i].amount,
                  color: colors[i % colors.length],
                  width: 26,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxAmount * 1.2,
                    color: colors[i % colors.length].withValues(alpha: 0.1),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
"""

if '_CategoryBarChart' not in content:
    content += bar_chart_class

# 2. Insert into the UI right after the pie chart
insertion_target = """              child: _CategoryPieChart(points: controller.personalCategoryPoints),
            ),
          const SizedBox(height: 32),"""

insertion_replacement = """              child: _CategoryPieChart(points: controller.personalCategoryPoints),
            ),
          const SizedBox(height: 32),

          // 5.5. Top Expense Bar Chart
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: 'Top Expense (Bar Chart)'),
          ),
          const SizedBox(height: 12),
          if (controller.personalCategoryPoints.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No expenses yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.text.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _CategoryBarChart(points: controller.personalCategoryPoints),
            ),
          const SizedBox(height: 32),"""

if insertion_target in content:
    content = content.replace(insertion_target, insertion_replacement)
    with open(path, 'w') as f:
        f.write(content)
    print("Bar chart successfully added.")
else:
    print("Failed to find insertion target.")
