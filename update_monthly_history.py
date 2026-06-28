import re

path = 'lib/app/modules/history/views/history_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# I want to replace the part that renders dashboard.monthlyArchives with a new widget _MonthlyHistoryList.
# The code currently looks like this:
'''
          const SizedBox(height: 10),
          if (dashboard.monthlyArchives.isEmpty)
            const EmptyState(
              icon: Icons.history_rounded,
              title: 'No monthly history yet',
              subtitle: 'The app will calculate income and expense automatically each month.',
            )
          else
            ...dashboard.monthlyArchives.map(
              (item) => _ArchiveCard(item: item),
            ),
'''

new_widget_call = """          const SizedBox(height: 10),
          _MonthlyHistoryList(archives: dashboard.monthlyArchives),"""

content = re.sub(r'          const SizedBox\(height: 10\),\s*if \(dashboard\.monthlyArchives\.isEmpty\).*?\.\.\.dashboard\.monthlyArchives\.map\(\s*\(item\) => _ArchiveCard\(item: item\),\s*\),', new_widget_call, content, flags=re.DOTALL)

# Add the new widget class at the end of the file
new_widget_class = """
class _MonthlyHistoryList extends StatefulWidget {
  final List<MonthlyArchiveModel> archives;

  const _MonthlyHistoryList({required this.archives});

  @override
  State<_MonthlyHistoryList> createState() => _MonthlyHistoryListState();
}

class _MonthlyHistoryListState extends State<_MonthlyHistoryList> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    if (widget.archives.isEmpty) {
      return const EmptyState(
        icon: Icons.history_rounded,
        title: 'No monthly history yet',
        subtitle: 'The app will calculate income and expense automatically each month.',
      );
    }

    final filtered = widget.archives.where((a) {
      return a.monthLabel.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search month (e.g., Jun 2026)',
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('No results found.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          )
        else
          ...filtered.map((item) => _ArchiveCard(item: item)),
      ],
    );
  }
}
"""

content += new_widget_class

with open(path, 'w') as f:
    f.write(content)

print("MonthlyHistoryList Added")
