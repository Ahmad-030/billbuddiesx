// lib/widgets/expense_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/models.dart';

class ExpenseDetailSheet extends StatelessWidget {
  final Expense expense;
  final Group group;
  final String symbol;
  final VoidCallback? onDelete;

  const ExpenseDetailSheet({
    super.key,
    required this.expense,
    required this.group,
    required this.symbol,
    this.onDelete,
  });

  static const _catEmojis = {
    'Food': '🍔', 'Transport': '🚗', 'Accommodation': '🏨',
    'Entertainment': '🎉', 'Shopping': '🛒', 'Utilities': '⚡', 'Other': '💸',
  };

  static Future<void> show(BuildContext context, {
    required Expense expense,
    required Group group,
    required String symbol,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseDetailSheet(
        expense: expense, group: group, symbol: symbol, onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final payer = group.getMember(expense.payerId);
    final emoji = _catEmojis[expense.category] ?? '💸';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
                        ),
                      ),
                      Text(
                        expense.category ?? 'Other',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$symbol${expense.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
          const SizedBox(height: 20),
          // Details
          _DetailRow(icon: Icons.person_rounded, label: 'Paid by', value: payer?.name ?? 'Unknown', isDark: isDark),
          _DetailRow(icon: Icons.calendar_today_rounded, label: 'Date', value: DateFormat('MMMM d, yyyy • h:mm a').format(expense.date), isDark: isDark),
          _DetailRow(icon: Icons.group_rounded, label: 'Split among', value: '${expense.participants.length} people', isDark: isDark),
          const SizedBox(height: 16),

          // Per-person breakdown
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Split Breakdown',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub),
                ),
                const SizedBox(height: 12),
                ...expense.participants.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  final member = group.getMember(p.memberId);
                  final pct = expense.amount > 0 ? (p.share / expense.amount) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (member?.name ?? '?')[0].toUpperCase(),
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member?.name ?? 'Unknown', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: pct.toDouble(),
                                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$symbol${p.share.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppTheme.primary),
                        ),
                      ],
                    ).animate().slideX(begin: 0.1, delay: Duration(milliseconds: i * 50), duration: 300.ms).fadeIn(delay: Duration(milliseconds: i * 50), duration: 300.ms),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (onDelete != null)
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete!();
                },
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                label: Text('Delete Expense', style: GoogleFonts.poppins(color: AppTheme.error, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.error.withOpacity(0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isDark;

  const _DetailRow({required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub)),
          const Spacer(),
          Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
