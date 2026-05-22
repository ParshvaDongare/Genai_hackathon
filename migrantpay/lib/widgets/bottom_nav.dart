import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.auto_awesome_outlined, 'activeIcon': Icons.auto_awesome, 'label': 'AI Insights'},
      {'icon': Icons.receipt_long_outlined, 'activeIcon': Icons.receipt_long, 'label': 'History'},
      {'icon': Icons.person_outline_rounded, 'activeIcon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.07), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) {
                final isSelected = selectedIndex == index;
                final item = items[index];
                return GestureDetector(
                  onTap: () => onItemSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? item['activeIcon'] as IconData
                              : item['icon'] as IconData,
                          color: isSelected
                              ? AppTheme.primaryLight
                              : AppTheme.textMuted,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primaryLight
                                : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
