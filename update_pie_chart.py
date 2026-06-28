import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# Define the new class content
new_class = """class _CategoryPieChart extends StatefulWidget {
  final List<dynamic> points;
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
      const Color(0xFFFF9F1C),
      const Color(0xFF2EC4B6),
      const Color(0xFFE71D36),
    ];

    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 10,
                  spreadRadius: -5,
                ),
              ],
            ),
          ),
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      if (event is FlTapUpEvent) {
                         touchedIndex = -1;
                      }
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 4,
              centerSpaceRadius: 70,
              sections: List.generate(widget.points.length, (i) {
                final isTouched = i == touchedIndex;
                final radius = isTouched ? 50.0 : 35.0;
                final point = widget.points[i];
                final color = colors[i % colors.length];
                
                return PieChartSectionData(
                  color: isTouched ? color : color.withValues(alpha: 0.7),
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
            swapAnimationDuration: const Duration(milliseconds: 350),
            swapAnimationCurve: Curves.easeOutCubic,
          ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: touchedIndex != -1 
                  ? Column(
                      key: ValueKey(touchedIndex),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.points[touchedIndex].label,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(widget.points[touchedIndex].amount / total * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 30, 
                            fontWeight: FontWeight.w900, 
                            color: colors[touchedIndex % colors.length],
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppFormatters.currency.format(widget.points[touchedIndex].amount),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('empty'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded, color: Colors.grey.shade400, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          'Tap a slice\\nto view details', 
                          textAlign: TextAlign.center, 
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}"""

# Find the old class and replace it
match = re.search(r'class _CategoryPieChart extends StatefulWidget \{.*\}', content, re.DOTALL)
if match:
    content = content.replace(match.group(0), new_class)
    with open(path, 'w') as f:
        f.write(content)
    print("Pie chart updated.")
else:
    print("Class not found.")
