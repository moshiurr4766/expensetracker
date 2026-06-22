import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/expense_model.dart';
import '../../../utils/formatters.dart';

class EditHistorySheet extends StatelessWidget {
  final SharedExpenseModel expense;

  const EditHistorySheet({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final history = expense.editHistory.reversed.toList();

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Edit History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('No edit history available.'),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final edit = history[index];
                    final date = (edit['timestamp'] as dynamic).toDate();
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Edited by ${edit['editorName']}'),
                      subtitle: Text('${edit['changes']}\n${AppFormatters.shortDate.format(date)}'),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
