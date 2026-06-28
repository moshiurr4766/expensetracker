import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# Update the colors array to a more vibrant/premium palette
old_colors = """    final colors = [
      const Color(0xFF4361EE),
      const Color(0xFFF72585),
      const Color(0xFF7209B7),
      const Color(0xFF3A0CA3),
      const Color(0xFF4CC9F0),
      const Color(0xFFFF9F1C),
      const Color(0xFF2EC4B6),
      const Color(0xFFE71D36),
    ];"""

new_colors = """    final colors = [
      const Color(0xFF5E60CE), // Soft Indigo
      const Color(0xFFFF7096), // Soft Pink
      const Color(0xFF4EA8DE), // Soft Blue
      const Color(0xFF9D4EDD), // Soft Purple
      const Color(0xFF06D6A0), // Vibrant Mint
      const Color(0xFFFFD166), // Vibrant Yellow
      const Color(0xFFEF476F), // Vibrant Pink/Red
      const Color(0xFF118AB2), // Deep Teal
    ];"""

if old_colors in content:
    content = content.replace(old_colors, new_colors)

# Update interaction logic to be more apparent
old_section = """                return PieChartSectionData(
                  color: isTouched ? color : color.withValues(alpha: 0.7),
                  value: point.amount,
                  title: '',
                  radius: radius,"""

new_section = """                return PieChartSectionData(
                  color: isTouched ? color : color.withValues(alpha: 0.6),
                  value: point.amount,
                  title: '',
                  radius: radius,
                  borderSide: isTouched 
                      ? BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 3)
                      : BorderSide.none,"""

if old_section in content:
    content = content.replace(old_section, new_section)
    print("Section interaction updated.")

# Let's also update the Income/Expense red and green to match the premium vibe.
# Income green: 0xFF2EC4B6 -> 0xFF06D6A0
# Expense red: 0xFFE71D36 -> 0xFFEF476F
content = content.replace("0xFF2EC4B6", "0xFF06D6A0")
content = content.replace("0xFFE71D36", "0xFFEF476F")

with open(path, 'w') as f:
    f.write(content)
print("Pie chart colors and interaction updated.")
