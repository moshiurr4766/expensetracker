import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../models/household_models.dart';
import '../../../utils/formatters.dart';

class HistorySummaryCard extends StatefulWidget {
  const HistorySummaryCard({super.key});

  @override
  State<HistorySummaryCard> createState() => _HistorySummaryCardState();
}

class _HistorySummaryCardState extends State<HistorySummaryCard> {
  String _selectedFilter = '6 Months';

  final List<String> _filters = [
    '1 Month',
    '3 Months',
    '6 Months',
    '1 Year',
    '2 Years',
    '3 Years',
    '5 Years',
    'All Time'
  ];

  DateTime? _getCutoffDate() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case '1 Month':
        return DateTime(now.year, now.month - 1, now.day);
      case '3 Months':
        return DateTime(now.year, now.month - 3, now.day);
      case '6 Months':
        return DateTime(now.year, now.month - 6, now.day);
      case '1 Year':
        return DateTime(now.year - 1, now.month, now.day);
      case '2 Years':
        return DateTime(now.year - 2, now.month, now.day);
      case '3 Years':
        return DateTime(now.year - 3, now.month, now.day);
      case '5 Years':
        return DateTime(now.year - 5, now.month, now.day);
      case 'All Time':
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();

    return Obx(() {
      final archives = dashboard.monthlyArchives;
      final cutoff = _getCutoffDate();

      List<MonthlyArchiveModel> filteredArchives = archives.toList();
      if (cutoff != null) {
        filteredArchives = filteredArchives.where((a) => a.createdAt.isAfter(cutoff)).toList();
      }

      double totalIncome = 0;
      double totalExpense = 0;
      for (var a in filteredArchives) {
        totalIncome += a.totalIncome;
        totalExpense += a.totalExpense;
      }
      final double totalBalance = totalIncome - totalExpense;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedFilter = newValue;
                          });
                        }
                      },
                      items: _filters.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Income', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(AppFormatters.currency.format(totalIncome), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Expense', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(AppFormatters.currency.format(totalExpense), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Balance', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  AppFormatters.currency.format(totalBalance),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: totalBalance < 0 ? Theme.of(context).colorScheme.error : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
