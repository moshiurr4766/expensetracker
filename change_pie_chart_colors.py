import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# Replace the sections part
old_sections = """              sections: List.generate(widget.points.length, (i) {
                final isTouched = i == touchedIndex;
                final radius = isTouched ? 50.0 : 35.0;
                final point = widget.points[i];
                final color = colors[i % colors.length];"""
new_sections = """              sections: List.generate(widget.points.length, (i) {
                final isTouched = i == touchedIndex;
                final radius = isTouched ? 50.0 : 35.0;
                final point = widget.points[i];
                Color color = colors[i % colors.length];
                if (point.label.toString().toLowerCase() == 'income') color = const Color(0xFF2EC4B6);
                if (point.label.toString().toLowerCase() == 'expense') color = const Color(0xFFE71D36);"""

if old_sections in content:
    content = content.replace(old_sections, new_sections)

# Replace the legend part
old_legend = """        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            widget.points.length > 3 ? 3 : widget.points.length,
            (i) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _Legend(
                  color: colors[i % colors.length],
                  label: widget.points[i].label,
                ),
              ),
            ),
          ),
        ),"""
new_legend = """        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            widget.points.length > 3 ? 3 : widget.points.length,
            (i) {
              final point = widget.points[i];
              Color color = colors[i % colors.length];
              if (point.label.toString().toLowerCase() == 'income') color = const Color(0xFF2EC4B6);
              if (point.label.toString().toLowerCase() == 'expense') color = const Color(0xFFE71D36);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _Legend(
                    color: color,
                    label: point.label,
                  ),
                ),
              );
            },
          ),
        ),"""

if old_legend in content:
    content = content.replace(old_legend, new_legend)

with open(path, 'w') as f:
    f.write(content)
print("Pie chart colors updated.")
