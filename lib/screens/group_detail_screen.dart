// lib/screens/group_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import 'add_expense_screen.dart';
import 'reports_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, provider, _) {
      final group = provider.getGroup(widget.groupId);
      if (group == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Group not found')),
        );
      }
      final isDark = provider.isDark;
      final sym = AppConstants.getCurrencySymbol(provider.currency);

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart_rounded),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReportsScreen(groupId: group.id)),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (val) async {
                    if (val == 'delete') {
                      final confirm = await _confirmDelete(context);
                      if (confirm == true) {
                        await provider.deleteGroup(group.id);
                        if (context.mounted) Navigator.pop(context);
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded,
                              color: AppTheme.error, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Delete Group',
                            style: GoogleFonts.poppins(
                                color: AppTheme.error, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildGroupHeader(group, sym, isDark),
              ),
              bottom: TabBar(
                controller: _tabCtrl,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                labelStyle:
                GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
                labelColor: AppTheme.primary,
                unselectedLabelColor:
                isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub,
                tabs: const [
                  Tab(text: 'Expenses'),
                  Tab(text: 'Balances'),
                  Tab(text: 'Settle Up'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _ExpensesTab(group: group, symbol: sym, provider: provider),
              _BalancesTab(group: group, symbol: sym, isDark: isDark),
              _SettleTab(group: group, symbol: sym, isDark: isDark),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddExpenseScreen(groupId: group.id)),
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'Add Expense',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut),
      );
    });
  }

  Widget _buildGroupHeader(Group group, String sym, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 56, 20, 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
                child: Text(group.emoji, style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  group.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
                Text(
                  '${group.members.length} members • $sym${group.totalExpenses.toStringAsFixed(2)} total',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                    isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Group',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete this group and all its expenses?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

// ── Expenses Tab ─────────────────────────────────────────────────────────────

class _ExpensesTab extends StatelessWidget {
  final Group group;
  final String symbol;
  final AppProvider provider;

  const _ExpensesTab(
      {required this.group, required this.symbol, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = provider.isDark;
    if (group.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧾', style: TextStyle(fontSize: 60))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.9, end: 1.1, duration: 1200.ms),
            const SizedBox(height: 16),
            Text('No expenses yet',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Tap + to add your first expense',
                style: GoogleFonts.poppins(
                    color: AppTheme.darkTextSub, fontSize: 13)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: group.expenses.length,
      itemBuilder: (context, i) {
        final exp = group.expenses[i];
        final payer = group.getMember(exp.payerId);
        return _ExpenseCard(
          expense: exp,
          payerName: payer?.name ?? 'Unknown',
          symbol: symbol,
          isDark: isDark,
          onDelete: () => provider.deleteExpense(group.id, exp.id),
        )
            .animate()
            .slideX(
          begin: 0.1,
          delay: Duration(milliseconds: i * 50),
          duration: 300.ms,
        )
            .fadeIn(
          delay: Duration(milliseconds: i * 50),
          duration: 300.ms,
        );
      },
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final String payerName, symbol;
  final bool isDark;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.payerName,
    required this.symbol,
    required this.isDark,
    required this.onDelete,
  });

  static const _catEmojis = {
    'Food': '🍔', 'Transport': '🚗', 'Accommodation': '🏨',
    'Entertainment': '🎉', 'Shopping': '🛒', 'Utilities': '⚡', 'Other': '💸',
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _catEmojis[expense.category] ?? '💸';
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Paid by $payerName • ${DateFormat('MMM d').format(expense.date)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark
                          ? AppTheme.darkTextSub
                          : AppTheme.lightTextSub,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$symbol${expense.amount.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Balances Tab ──────────────────────────────────────────────────────────────

class _BalancesTab extends StatelessWidget {
  final Group group;
  final String symbol;
  final bool isDark;

  const _BalancesTab(
      {required this.group, required this.symbol, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final balances = group.balances;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFF9D8FFF)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text('Total Expenses',
                  style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                '$symbol${group.totalExpenses.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                'across ${group.expenses.length} expenses',
                style:
                GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
        const SizedBox(height: 20),
        Text('Member Balances',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 12),
        ...group.members.asMap().entries.map((entry) {
          final i = entry.key;
          final m = entry.value;
          final bal = balances[m.id] ?? 0.0;
          final isPos = bal >= 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: bal.abs() < 0.01
                    ? (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                    : isPos
                    ? AppTheme.success.withValues(alpha: 0.3)
                    : AppTheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      m.name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600)),
                      Text(
                        bal.abs() < 0.01
                            ? 'Settled up ✓'
                            : isPos
                            ? 'Gets back $symbol${bal.toStringAsFixed(2)}'
                            : 'Owes $symbol${bal.abs().toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: bal.abs() < 0.01
                              ? AppTheme.darkTextSub
                              : isPos
                              ? AppTheme.success
                              : AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                _BalanceBar(value: bal, max: group.totalExpenses),
              ],
            ),
          )
              .animate()
              .slideX(
            begin: 0.15,
            delay: Duration(milliseconds: i * 60),
            duration: 350.ms,
          )
              .fadeIn(
            delay: Duration(milliseconds: i * 60),
            duration: 350.ms,
          );
        }),
      ],
    );
  }
}

class _BalanceBar extends StatelessWidget {
  final double value, max;
  const _BalanceBar({required this.value, required this.max});

  @override
  Widget build(BuildContext context) {
    final double pct =
    max == 0 ? 0.0 : (value.abs() / max).clamp(0.0, 1.0);
    final color = value >= 0 ? AppTheme.success : AppTheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.darkCardAlt,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment:
            value >= 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 60 * pct,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Settle Up Tab ─────────────────────────────────────────────────────────────

class _SettleTab extends StatelessWidget {
  final Group group;
  final String symbol;
  final bool isDark;

  const _SettleTab(
      {required this.group, required this.symbol, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final settlements = group.settlements;
    if (settlements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.9, end: 1.1, duration: 1000.ms),
            const SizedBox(height: 16),
            Text('All settled up!',
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('No debts to settle in this group.',
                style:
                GoogleFonts.poppins(color: AppTheme.darkTextSub)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: settlements.length,
      itemBuilder: (context, i) {
        final s = settlements[i];
        final from = group.getMember(s['from'] as String);
        final to = group.getMember(s['to'] as String);
        final amount = s['amount'] as double;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.warning.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.warning.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _Avatar(name: from?.name ?? '?', color: AppTheme.error),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$symbol${amount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppTheme.warning,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 14, color: AppTheme.darkTextSub),
                    Text(
                      '${from?.name ?? '?'} pays ${to?.name ?? '?'}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark
                            ? AppTheme.darkTextSub
                            : AppTheme.lightTextSub,
                      ),
                    ),
                  ],
                ),
              ),
              _Avatar(name: to?.name ?? '?', color: AppTheme.success),
            ],
          ),
        )
            .animate()
            .slideY(
          begin: 0.1,
          delay: Duration(milliseconds: i * 80),
          duration: 350.ms,
        )
            .fadeIn(
          delay: Duration(milliseconds: i * 80),
          duration: 350.ms,
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final Color color;
  const _Avatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: color),
        ),
      ),
    );
  }
}