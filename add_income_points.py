import re

path = 'lib/app/controllers/dashboard_controller.dart'
with open(path, 'r') as f:
    content = f.read()

# 1. Add variable
if 'final personalIncomeCategoryPoints' not in content:
    content = content.replace(
        '  final personalCategoryPoints = <CategorySpendPoint>[].obs;',
        '  final personalCategoryPoints = <CategorySpendPoint>[].obs;\n  final personalIncomeCategoryPoints = <CategorySpendPoint>[].obs;'
    )

# 2. Add to _recalculate
if 'personalIncomeCategoryPoints.assignAll(_buildPersonalIncomeCategoryPoints());' not in content:
    content = content.replace(
        '    personalCategoryPoints.assignAll(_buildPersonalCategoryPoints());',
        '    personalCategoryPoints.assignAll(_buildPersonalCategoryPoints());\n    personalIncomeCategoryPoints.assignAll(_buildPersonalIncomeCategoryPoints());'
    )

# 3. Add method
method = """
  List<CategorySpendPoint> _buildPersonalIncomeCategoryPoints() {
    final grouped = <String, CategorySpendPoint>{};
    for (final income in incomes) {
      final label = displayCategoryName(income);
      final current = grouped[label];
      if (current == null) {
        grouped[label] = CategorySpendPoint(
          label: label,
          amount: income.amount,
          count: 1,
        );
      } else {
        grouped[label] = CategorySpendPoint(
          label: current.label,
          amount: current.amount + income.amount,
          count: current.count + 1,
        );
      }
    }

    final points = grouped.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return points;
  }
"""
if '_buildPersonalIncomeCategoryPoints' not in content:
    content = content.replace(
        '  List<CategorySpendPoint> _buildPersonalCategoryPoints() {',
        method + '\n  List<CategorySpendPoint> _buildPersonalCategoryPoints() {'
    )

with open(path, 'w') as f:
    f.write(content)

# Now update overview_tab.dart
path2 = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path2, 'r') as f2:
    content2 = f2.read()

content2 = content2.replace("SectionHeader(title: 'Top Expense Categories')", "SectionHeader(title: 'Top Income Categories')")
# We only want to replace personalCategoryPoints in the pie chart section, not the bar chart.
# Let's locate the pie chart section
pie_section = """          if (controller.personalCategoryPoints.isEmpty)
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
              child: _CategoryPieChart(points: controller.personalCategoryPoints),
            ),"""

new_pie_section = """          if (controller.personalIncomeCategoryPoints.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No incomes yet.',
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
              child: _CategoryPieChart(points: controller.personalIncomeCategoryPoints),
            ),"""

content2 = content2.replace(pie_section, new_pie_section)

with open(path2, 'w') as f2:
    f2.write(content2)

print("Done updating")
