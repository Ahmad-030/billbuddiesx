// lib/screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../models/models.dart';

class ReportsScreen extends StatefulWidget {
  final String groupId;
  const ReportsScreen({super.key, required this.groupId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _touchedIndex = -1;
  String? _filterMemberId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, provider, _) {
      final group = provider.getGroup(widget.groupId);
      if (group == null) return const Scaffold();
      final isDark = provider.isDark;
      final sym = AppConstants.getCurrencySymbol(provider.currency);

      final filteredExpenses = _filterMemberId == null
          ? group.expenses
          : group.expenses.where((e) =>
              e.payerId == _filterMemberId ||
              e.participants.any((p) => p.memberId == _filterMemberId)).toList();

      return Scaffold(
        appBar: AppBar(
          title: Text('Reports – ${group.name}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(child: _StatCard(title: 'Total', value: '$sym${group.totalExpenses.toStringAsFixed(2)}', icon: '💰', color: AppTheme.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'Expenses', value: '${group.expenses.length}', icon: '🧾', color: AppTheme.accent)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'Members', value: '${group.members.length}', icon: '👥', color: AppTheme.success)),
                ],
              ).animate().slideY(begin: 0.1, duration: 400.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              // Member filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(label: 'All', selected: _filterMemberId == null, onTap: () => setState(() => _filterMemberId = null)),
                    ...group.members.map((m) => _FilterChip(
                      label: m.name,
                      selected: _filterMemberId == m.id,
                      onTap: () => setState(() => _filterMemberId = _filterMemberId == m.id ? null : m.id),
                    )),
                  ],
                ),
              ).animate().slideX(begin: 0.1, delay: 100.ms, duration: 400.ms).fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 24),

              // Pie chart - spending per member
              if (group.expenses.isNotEmpty) ...[
                _SectionTitle('Spending Per Member'),
                const SizedBox(height: 12),
                _MemberPieChart(group: group, isDark: isDark, sym: sym, touchedIndex: _touchedIndex,
                    onTouch: (i) => setState(() => _touchedIndex = i)),
                const SizedBox(height: 24),
                _SectionTitle('Category Breakdown'),
                const SizedBox(height: 12),
                _CategoryChart(expenses: filteredExpenses, isDark: isDark, sym: sym),
                const SizedBox(height: 24),
              ],

              // Expense history
              _SectionTitle('Expense History'),
              const SizedBox(height: 12),
              if (filteredExpenses.isEmpty)
                Center(child: Text('No expenses', style: GoogleFonts.poppins(color: AppTheme.darkTextSub)))
              else
                ...filteredExpenses.asMap().entries.map((entry) {
                  final i = entry.key;
                  final exp = entry.value;
                  final payer = group.getMember(exp.payerId);
                  return _HistoryItem(exp: exp, payer: payer, sym: sym, isDark: isDark)
                      .animate()
                      .slideX(begin: 0.1, delay: Duration(milliseconds: i * 40), duration: 300.ms)
                      .fadeIn(delay: Duration(milliseconds: i * 40), duration: 300.ms);
                }),
            ],
          ),
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          Text(title, style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : (isDark ? AppTheme.darkCardAlt : AppTheme.lightCard),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? AppTheme.primary : Colors.transparent),
        ),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : null)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700));
  }
}

class _MemberPieChart extends StatelessWidget {
  final Group group;
  final bool isDark;
  final String sym;
  final int touchedIndex;
  final Function(int) onTouch;

  const _MemberPieChart({
    required this.group, required this.isDark, required this.sym,
    required this.touchedIndex, required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [AppTheme.primary, AppTheme.accent, AppTheme.success, AppTheme.error, AppTheme.warning, const Color(0xFF00B4D8)];
    final memberSpend = <String, double>{};
    for (final exp in group.expenses) {
      memberSpend[exp.payerId] = (memberSpend[exp.payerId] ?? 0) + exp.amount;
    }
    if (memberSpend.isEmpty) return const SizedBox.shrink();
    final entries = memberSpend.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: entries.asMap().entries.map((e) {
                  final i = e.key;
                  final entry = e.value;
                  final isTouched = i == touchedIndex;
                  final member = group.getMember(entry.key);
                  return PieChartSectionData(
                    value: entry.value,
                    color: colors[i % colors.length],
                    radius: isTouched ? 90 : 75,
                    title: isTouched ? '$sym${entry.value.toStringAsFixed(0)}' : '',
                    titleStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    badgeWidget: isTouched ? null : Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors[i % colors.length].withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(member?.name.substring(0, 1) ?? '?',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: colors[i % colors.length])),
                    ),
                    badgePositionPercentageOffset: 1.2,
                  );
                }).toList(),
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (response?.touchedSection != null) {
                      onTouch(response!.touchedSection!.touchedSectionIndex);
                    } else {
                      onTouch(-1);
                    }
                  },
                ),
                centerSpaceRadius: 40,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: entries.asMap().entries.map((e) {
              final member = group.getMember(e.value.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('${member?.name ?? '?'} ($sym${e.value.value.toStringAsFixed(0)})',
                      style: GoogleFonts.poppins(fontSize: 11)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final List<Expense> expenses;
  final bool isDark;
  final String sym;
  const _CategoryChart({required this.expenses, required this.isDark, required this.sym});

  @override
  Widget build(BuildContext context) {
    final catSpend = <String, double>{};
    for (final exp in expenses) {
      final cat = exp.category ?? 'Other';
      catSpend[cat] = (catSpend[cat] ?? 0) + exp.amount;
    }
    if (catSpend.isEmpty) return const SizedBox.shrink();
    final sorted = catSpend.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value;
    final colors = [AppTheme.primary, AppTheme.accent, AppTheme.success, AppTheme.error, AppTheme.warning];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        children: sorted.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          final pct = max == 0 ? 0.0 : cat.value / max;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(width: 80, child: Text(cat.key, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: colors[i % colors.length].withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(colors[i % colors.length]),
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    '$sym${cat.value.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: colors[i % colors.length]),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final Expense exp;
  final AppMember? payer;
  final String sym;
  final bool isDark;
  const _HistoryItem({required this.exp, required this.payer, required this.sym, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp.description, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  'Paid by ${payer?.name ?? 'Unknown'} • ${DateFormat('MMM d, yyyy').format(exp.date)}',
                  style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub),
                ),
              ],
            ),
          ),
          Text('$sym${exp.amount.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppTheme.accent)),
        ],
      ),
    );
  }
}
