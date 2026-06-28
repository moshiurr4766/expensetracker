import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# 1. Add import
if 'package:fl_chart/fl_chart.dart' not in content:
    content = content.replace("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:fl_chart/fl_chart.dart';")

# 2. Replace the Top Expense Categories list with the PieChart
target_list = """          if (controller.personalCategoryPoints.isEmpty)
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
            ...controller.personalCategoryPoints.take(5).map(
              (point) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: _InteractiveRowCard(
                  title: point.label,
                  value: AppFormatters.currency.format(point.amount),
                  icon: Icons.category_rounded,
                  iconColor: const Color(0xFFE63946),
                  onTap: () => controller.changeTab(1),
                ),
              ),
            ),"""

replacement = """          if (controller.personalCategoryPoints.isEmpty)
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
                    color: AppColors.text.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _CategoryPieChart(points: controller.personalCategoryPoints),
            ),"""

content = content.replace(target_list, replacement)

# 3. Append the _CategoryPieChart class at the end
pie_chart_class = """
class _CategoryPieChart extends StatefulWidget {
  final List<CategorySpendPoint> points;
  const _CategoryPieChart({required this.points});

  @override
  State<_CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<_CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();
    
    final total = widget.points.fold<double>(0, (sum, point) => sum + point.amount);
    
    final colors = [
      const Color(0xFF4361EE),
      const Color(0xFFF72585),
      const Color(0xFF7209B7),
      const Color(0xFF3A0CA3),
      const Color(0xFF4CC9F0),
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 70,
              sections: List.generate(widget.points.length, (i) {
                final isTouched = i == touchedIndex;
                final radius = isTouched ? 40.0 : 30.0;
                final point = widget.points[i];
                
                return PieChartSectionData(
                  color: colors[i % colors.length],
                  value: point.amount,
                  title: '',
                  radius: radius,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
          Center(
            child: touchedIndex != -1 
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.points[touchedIndex].label,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(widget.points[touchedIndex].amount / total * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7209B7)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.currency.format(widget.points[touchedIndex].amount),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  )
                : const Text('Tap to view\\ndetails', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
"""

if '_CategoryPieChart' not in content:
    content += pie_chart_class

with open(path, 'w') as f:
    f.write(content)
