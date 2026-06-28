import re

path = 'lib/app/modules/settlement/views/settlement_tab.dart'
with open(path, 'r') as f:
    content = f.read()

new_chips = """          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: controller.selectedFilter.value == 'all',
                  onSelected: (_) => controller.selectedFilter.value = 'all',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('This month'),
                  selected: controller.selectedFilter.value == 'month',
                  onSelected: (_) => controller.selectedFilter.value = 'month',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('3 Months'),
                  selected: controller.selectedFilter.value == '3_months',
                  onSelected: (_) => controller.selectedFilter.value = '3_months',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('6 Months'),
                  selected: controller.selectedFilter.value == '6_months',
                  onSelected: (_) => controller.selectedFilter.value = '6_months',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('1 Year'),
                  selected: controller.selectedFilter.value == '1_year',
                  onSelected: (_) => controller.selectedFilter.value = '1_year',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('3 Years'),
                  selected: controller.selectedFilter.value == '3_years',
                  onSelected: (_) => controller.selectedFilter.value = '3_years',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('5 Years'),
                  selected: controller.selectedFilter.value == '5_years',
                  onSelected: (_) => controller.selectedFilter.value = '5_years',
                ),
              ],
            ),
          ),"""

content = re.sub(r'          Wrap\(\s*spacing: 8,\s*children: \[.*?ChoiceChip\(.*?label: const Text\(\'This year\'\).*?\),\s*\],\s*\),', new_chips, content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(content)

print("SettlementTab Updated")
