import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../utils/app_snackbar.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/primary_button.dart';

class ArchiveCalculationSheet extends StatefulWidget {
  const ArchiveCalculationSheet({super.key});

  @override
  State<ArchiveCalculationSheet> createState() => _ArchiveCalculationSheetState();
}

class _ArchiveCalculationSheetState extends State<ArchiveCalculationSheet> {
  final DashboardController controller = Get.find<DashboardController>();
  
  late DateTime startDate;
  late DateTime endDate;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 0);
  }

  Future<void> _handleArchive() async {
    setState(() => isSaving = true);
    try {
      final label = '${AppFormatters.shortDate.format(startDate)} - ${AppFormatters.shortDate.format(endDate)}';
      await controller.archiveSelectedRange(
        startDate: startDate,
        endDate: endDate,
        label: label,
      );
      Navigator.pop(Get.context!);
      AppSnackbar.success('Successfully archived selected range');
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Archive Monthly Ledger',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(Get.context!),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Select a date range to archive. This will move the expenses and incomes within this range into the history archive.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              _DateRow(
                label: 'Start date',
                value: startDate,
                onPick: (date) => setState(() => startDate = date),
              ),
              const SizedBox(height: 10),
              _DateRow(
                label: 'End date',
                value: endDate,
                onPick: (date) => setState(() => endDate = date),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Confirm and archive',
                icon: Icons.archive_rounded,
                loading: isSaving,
                onPressed: _handleArchive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPick;

  const _DateRow({
    required this.label,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(AppFormatters.shortDate.format(value)),
      ),
    );
  }
}
