// lib/widgets/reminder_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/models.dart';

class ReminderBanner extends StatelessWidget {
  final List<Group> groups;
  final String symbol;
  final VoidCallback? onDismiss;

  const ReminderBanner({
    super.key,
    required this.groups,
    required this.symbol,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    double totalOwe = 0;
    int groupCount = 0;

    for (final g in groups) {
      bool hasDebt = false;
      for (final entry in g.balances.entries) {
        if (entry.value < -0.01) {
          totalOwe += entry.value.abs();
          if (!hasDebt) { groupCount++; hasDebt = true; }
        }
      }
    }

    if (totalOwe < 0.01) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.warning.withOpacity(0.15), AppTheme.accent.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('⏰', style: TextStyle(fontSize: 24))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .rotate(begin: -0.05, end: 0.05, duration: 600.ms),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Settlements',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.warning,
                  ),
                ),
                Text(
                  'You owe $symbol${totalOwe.toStringAsFixed(2)} across $groupCount group${groupCount > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.darkTextSub,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close_rounded, size: 18, color: AppTheme.darkTextSub),
            ),
        ],
      ),
    ).animate().slideY(begin: -0.2, duration: 400.ms, curve: Curves.easeOut).fadeIn(duration: 400.ms);
  }
}
