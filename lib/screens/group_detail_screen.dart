// lib/screens/group_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent]),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(group.emoji,
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      group.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${group.members.length} members  •  $sym${group.totalExpenses.toStringAsFixed(2)} total',
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
            ],
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(49),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color:
                  isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
                TabBar(
                  controller: _tabCtrl,
                  indicatorColor: AppTheme.primary,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 13),
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
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _ExpensesTab(group: group, symbol: sym, provider: provider),
            _BalancesTab(group: group, symbol: sym, isDark: isDark),
            _SettleTab(
              group: group,
              symbol: sym,
              isDark: isDark,
              onRecordPayment: (fromId, toId, amount) =>
                  _recordPayment(context, provider, group, fromId, toId, amount),
            ),
          ],
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
        ).animate().scale(
            delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut),
      );
    });
  }

  Future<void> _recordPayment(
      BuildContext context,
      AppProvider provider,
      Group group,
      String fromId,
      String toId,
      double suggestedAmount,
      ) async {
    final TextEditingController amountCtrl =
    TextEditingController(text: suggestedAmount.toStringAsFixed(2));
    final sym = AppConstants.getCurrencySymbol(provider.currency);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
        provider.isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.handshake_rounded,
                  color: AppTheme.success, size: 20),
            ),
            const SizedBox(width: 10),
            Text('Record Payment',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: provider.isDark
                    ? AppTheme.darkCardAlt
                    : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SmallAvatar(
                      name: group.getMember(fromId)?.name ?? '?',
                      color: AppTheme.error),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: AppTheme.darkTextSub),
                      Text('pays',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: AppTheme.darkTextSub)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  _SmallAvatar(
                      name: group.getMember(toId)?.name ?? '?',
                      color: AppTheme.success),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Amount paid',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: provider.isDark
                        ? AppTheme.darkTextSub
                        : AppTheme.lightTextSub)),
            const SizedBox(height: 6),
            TextField(
              controller: amountCtrl,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                prefixText: '$sym ',
                prefixStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, color: AppTheme.success),
                hintText: '0.00',
              ),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppTheme.darkTextSub)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: Text('Record',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final amount = double.tryParse(amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;

    final settlement = Expense(
      id: const Uuid().v4(),
      description:
      '${group.getMember(fromId)?.name ?? '?'} → ${group.getMember(toId)?.name ?? '?'} (Settlement)',
      amount: amount,
      payerId: fromId,
      participants: [ExpenseParticipant(memberId: toId, share: amount)],
      date: DateTime.now(),
      category: 'Settlement',
      isSettlement: true,
    );

    await provider.addExpense(group.id, settlement);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Payment recorded!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
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

// ── Small Avatar for dialog ───────────────────────────────────────────────────

class _SmallAvatar extends StatelessWidget {
  final String name;
  final Color color;
  const _SmallAvatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4), width: 2),
          ),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800, color: color, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(name,
            style: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w600)),
      ],
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
    final allExpenses = group.expenses;

    if (allExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Lottie coin animation for empty expenses state ──
            SizedBox(
              width: 180,
              height: 180,
              child: Lottie.asset(
                'assets/coin.json',
                repeat: true,
                fit: BoxFit.contain,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 8),
            Text('No expenses yet',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700))
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.2, delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 8),
            Text('Tap + to add your first expense',
                style: GoogleFonts.poppins(
                    color: AppTheme.darkTextSub, fontSize: 13))
                .animate()
                .fadeIn(delay: 350.ms, duration: 400.ms),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: allExpenses.length,
      itemBuilder: (context, i) {
        final exp = allExpenses[i];
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
    'Food': '🍔',
    'Transport': '🚗',
    'Accommodation': '🏨',
    'Entertainment': '🎉',
    'Shopping': '🛒',
    'Utilities': '⚡',
    'Settlement': '🤝',
    'Other': '💸',
  };

  @override
  Widget build(BuildContext context) {
    final isSettlement = expense.isSettlement;
    final emoji = _catEmojis[expense.category] ?? '💸';
    final accentColor = isSettlement ? AppTheme.success : AppTheme.accent;

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
          color: isSettlement
              ? AppTheme.success.withOpacity(0.05)
              : (isDark ? AppTheme.darkCard : AppTheme.lightSurface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSettlement
                  ? AppTheme.success.withOpacity(0.3)
                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          expense.description,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSettlement)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Settled',
                              style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.success)),
                        ),
                    ],
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
                color: accentColor,
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
                'across ${group.expenses.where((e) => !e.isSettlement).length} expenses',
                style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: 11),
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
  final Function(String fromId, String toId, double amount) onRecordPayment;

  const _SettleTab({
    required this.group,
    required this.symbol,
    required this.isDark,
    required this.onRecordPayment,
  });

  @override
  Widget build(BuildContext context) {
    final settlements = group.settlements;
    if (settlements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Lottie coin animation for "all settled" state ──
            SizedBox(
              width: 180,
              height: 180,
              child: Lottie.asset(
                'assets/coin.json',
                repeat: true,
                fit: BoxFit.contain,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 8),
            Text('All settled up!',
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.w700))
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.2, delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 8),
            Text('No debts to settle in this group.',
                style: GoogleFonts.poppins(color: AppTheme.darkTextSub))
                .animate()
                .fadeIn(delay: 350.ms, duration: 400.ms),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
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
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: isDark
                            ? AppTheme.darkBorder
                            : AppTheme.lightBorder),
                  ),
                ),
                child: TextButton.icon(
                  onPressed: () => onRecordPayment(
                    s['from'] as String,
                    s['to'] as String,
                    amount,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded,
                      color: AppTheme.success, size: 18),
                  label: Text(
                    'Mark as Paid',
                    style: GoogleFonts.poppins(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16)),
                    ),
                  ),
                ),
              ),
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
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800, color: color),
        ),
      ),
    );
  }
}