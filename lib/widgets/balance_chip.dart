// lib/widgets/balance_chip.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class BalanceChip extends StatelessWidget {
  final double amount;
  final String symbol;
  final bool compact;

  const BalanceChip({
    super.key,
    required this.amount,
    required this.symbol,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isZero = amount.abs() < 0.01;
    final isPos = amount > 0;

    final Color color;
    final String label;
    final IconData icon;

    if (isZero) {
      color = AppTheme.darkTextSub;
      label = compact ? 'Settled' : 'Settled up ✓';
      icon = Icons.check_circle_outline_rounded;
    } else if (isPos) {
      color = AppTheme.success;
      label = compact ? '+$symbol${amount.toStringAsFixed(2)}' : 'Gets $symbol${amount.toStringAsFixed(2)}';
      icon = Icons.arrow_downward_rounded;
    } else {
      color = AppTheme.error;
      label = compact ? '-$symbol${amount.abs().toStringAsFixed(2)}' : 'Owes $symbol${amount.abs().toStringAsFixed(2)}';
      icon = Icons.arrow_upward_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 11 : 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
