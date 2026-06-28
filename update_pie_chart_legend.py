import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# I will replace the `return SizedBox(` with a `return Column(` in the build method of _CategoryPieChartState

target = """    return SizedBox(
      height: 280,"""

replacement = """    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 280,"""

if target in content:
    content = content.replace(target, replacement)
    
    # Next, I need to find the end of that SizedBox and add the Wrap for legends
    target2 = """            ),
          ),
        ],
      ),
    );
  }
}"""

    replacement2 = """            ),
          ),
        ],
      ),
    ),
    if (widget.points.isNotEmpty) ...[
      const SizedBox(height: 16),
      Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(
          widget.points.length > 3 ? 3 : widget.points.length,
          (i) => _Legend(
            color: colors[i % colors.length],
            label: widget.points[i].label,
          ),
        ),
      ),
    ],
  ],
);
  }
}"""
    if target2 in content:
        content = content.replace(target2, replacement2)
        with open(path, 'w') as f:
            f.write(content)
        print("Updated with legend.")
    else:
        print("Target 2 not found.")
else:
    print("Target 1 not found.")
