import re

# 1. Update dashboard_controller.dart
path_ctrl = 'lib/app/controllers/dashboard_controller.dart'
with open(path_ctrl, 'r') as f:
    ctrl_content = f.read()

filter_var = "  final pieChartDateFilter = '30d'.obs;"
filter_method = """  List<CategorySpendPoint> get filteredIncomeExpensePoints {
    final now = DateTime.now();
    DateTime? startDate;
    switch (pieChartDateFilter.value) {
      case '7d': startDate = now.subtract(const Duration(days: 7)); break;
      case '30d': startDate = now.subtract(const Duration(days: 30)); break;
      case '90d': startDate = now.subtract(const Duration(days: 90)); break;
      case 'yearly': startDate = DateTime(now.year, 1, 1); break;
      default: startDate = null; // All
    }

    double inc = 0;
    for (var i in incomes) {
      if (startDate == null || i.date.isAfter(startDate)) inc += i.amount;
    }
    double exp = 0;
    for (var e in expenses) {
      if (startDate == null || e.date.isAfter(startDate)) exp += e.amount;
    }

    final list = <CategorySpendPoint>[];
    if (inc > 0) list.add(CategorySpendPoint(label: 'Income', amount: inc, count: 1));
    if (exp > 0) list.add(CategorySpendPoint(label: 'Expense', amount: exp, count: 1));
    return list;
  }
"""

if "pieChartDateFilter" not in ctrl_content:
    ctrl_content = ctrl_content.replace(
        "  final personalCategoryPoints = <CategorySpendPoint>[].obs;",
        "  final personalCategoryPoints = <CategorySpendPoint>[].obs;\n" + filter_var
    )
    ctrl_content = ctrl_content.replace(
        "  List<PersonPaymentPoint> _buildPersonPaymentPoints() {",
        filter_method + "\n  List<PersonPaymentPoint> _buildPersonPaymentPoints() {"
    )
    with open(path_ctrl, 'w') as f:
        f.write(ctrl_content)
    print("Updated DashboardController")

# 2. Update overview_tab.dart
path_view = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path_view, 'r') as f:
    view_content = f.read()

# Replace Income vs Expense section
old_pie_section = r'          // 5\. Income vs Expense.*?const SizedBox\(height: 32\),'
new_pie_section = """          // 5. Income vs Expense
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Income vs Expense'),
                Obx(() => DropdownButton<String>(
                  value: controller.pieChartDateFilter.value,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                  onChanged: (String? newValue) {
                    if (newValue != null) controller.pieChartDateFilter.value = newValue;
                  },
                  items: <String>['7d', '30d', '90d', 'yearly', 'All']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final points = controller.filteredIncomeExpensePoints;
            if (points.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No data yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              );
            }
            return Container(
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
              child: _CategoryPieChart(points: points),
            );
          }),
          const SizedBox(height: 32),"""

view_content = re.sub(old_pie_section, new_pie_section, view_content, flags=re.DOTALL)

# Fix the _CategoryPieChart colors
old_pie_chart = r'class _CategoryPieChartState extends State<_CategoryPieChart> \{.*?\n\}'

new_pie_chart = """class _CategoryPieChartState extends State<_CategoryPieChart> {
  int touchedIndex = -1;
  
  Color _getColorForPoint(dynamic point, int index, List<Color> fallbackColors) {
    final label = point.label.toString().toLowerCase();
    if (label == 'income') return const Color(0xFF06D6A0);
    if (label == 'expense') return const Color(0xFFEF476F);
    return fallbackColors[index % fallbackColors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();
    
    final total = widget.points.fold<double>(0, (sum, point) => sum + point.amount);
    
    final colors = [
      const Color(0xFF5E60CE), // Soft Indigo
      const Color(0xFFFF7096), // Soft Pink
      const Color(0xFF4EA8DE), // Soft Blue
      const Color(0xFF9D4EDD), // Soft Purple
      const Color(0xFF06D6A0), // Vibrant Mint
      const Color(0xFFFFD166), // Vibrant Yellow
      const Color(0xFFEF476F), // Vibrant Pink/Red
      const Color(0xFF118AB2), // Deep Teal
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
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
                final color = _getColorForPoint(point, i, colors);
                
                return PieChartSectionData(
                  color: isTouched ? color : color.withValues(alpha: 0.6),
                  value: point.amount,
                  title: '',
                  radius: radius,
                  borderSide: isTouched 
                      ? BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 3)
                      : BorderSide.none,
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
                            color: _getColorForPoint(widget.points[touchedIndex], touchedIndex, colors),
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
    ),
    if (widget.points.isNotEmpty) ...[
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          widget.points.length > 3 ? 3 : widget.points.length,
          (i) {
            final point = widget.points[i];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _Legend(
                  color: _getColorForPoint(point, i, colors),
                  label: point.label,
                ),
              ),
            );
          },
        ),
      ),
    ],
  ],
);
  }
}"""

view_content = re.sub(old_pie_chart, new_pie_chart, view_content, flags=re.DOTALL)

with open(path_view, 'w') as f:
    f.write(view_content)
print("Updated Overview Tab")

