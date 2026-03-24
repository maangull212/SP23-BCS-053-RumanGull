import 'package:flutter/material.dart';

class AppBottomBar extends StatelessWidget {
  // 0=Today, 1=Repeated, 2=Completed, 3=Profile
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;

  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inactive = cs.onSurfaceVariant;
    final active = cs.primary;

    // Constrain each bottom item to avoid overflow on compact heights
    const double itemHeight =
        40; // matches BottomAppBar constraints in most themes
    const double iconSize = 20;
    const double vPad = 2; // keep padding minimal to fit icon+label

    Widget item({
      required IconData icon,
      required String label,
      required int index,
    }) {
      final sel = currentIndex == index;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap(index),
          child: SizedBox(
            height: itemHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: vPad),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: sel ? active : inactive, size: iconSize),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 10, // smaller to fit safely
                      height: 1.1,
                      color: sel ? active : inactive,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          item(icon: Icons.today_rounded, label: 'Today', index: 0),
          item(icon: Icons.repeat_rounded, label: 'Repeated', index: 1),
          // Space for the center-docked FAB
          const SizedBox(width: 64),
          item(icon: Icons.task_alt_rounded, label: 'Completed', index: 2),
          item(icon: Icons.person_rounded, label: 'Profile', index: 3),
        ],
      ),
    );
  }
}
