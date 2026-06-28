import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# Define the old _CategoryBarChart class
old_class_pattern = r'class _CategoryBarChart extends StatelessWidget \{.*?\}(?=\n\n|$)'

new_class = """class _CategoryBarChart extends StatelessWidget {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(topPoints.length, (index) {
        final point = topPoints[index];
        final color = colors[index % colors.length];
        final percentage = point.amount / maxAmount; 

        return Padding(
          padding: EdgeInsets.only(bottom: index == topPoints.length - 1 ? 0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    point.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600, 
                      fontSize: 13,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    AppFormatters.currency.format(point.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800, 
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 14,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutQuart,
                        height: 14,
                        width: constraints.maxWidth * percentage,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}"""

content = re.sub(old_class_pattern, new_class, content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(content)
print("Bar chart replaced with horizontal custom widget.")
