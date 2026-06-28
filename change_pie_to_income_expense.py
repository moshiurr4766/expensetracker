import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

target = """          // 5. Top Expense Categories
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: 'Top Income Categories'),
          ),
          const SizedBox(height: 12),
          if (controller.personalIncomeCategoryPoints.isEmpty)
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

replacement = """          // 5. Income vs Expense
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: 'Income vs Expense'),
          ),
          const SizedBox(height: 12),
          if (controller.summary.value.totalIncome == 0 && controller.summary.value.totalExpense == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No data yet.',
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
              child: _CategoryPieChart(
                points: [
                  if (controller.summary.value.totalIncome > 0)
                    CategorySpendPoint(
                      label: 'Income',
                      amount: controller.summary.value.totalIncome,
                      count: 1,
                    ),
                  if (controller.summary.value.totalExpense > 0)
                    CategorySpendPoint(
                      label: 'Expense',
                      amount: controller.summary.value.totalExpense,
                      count: 1,
                    ),
                ],
              ),
            ),"""

if target in content:
    content = content.replace(target, replacement)
    
    # We should also ensure CategorySpendPoint is accessible. 
    # Let's add the import for analysis_models if it's missing.
    if "import '../../../models/analysis_models.dart';" not in content:
        content = content.replace("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport '../../../models/analysis_models.dart';")
        
    with open(path, 'w') as f:
        f.write(content)
    print("Replaced successfully")
else:
    print("Could not find target")
