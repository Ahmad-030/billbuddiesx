// lib/screens/add_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../models/models.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;
  const AddExpenseScreen({super.key, required this.groupId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _payerId;
  String _category = 'Other';
  bool _splitEqually = true;
  final Map<String, TextEditingController> _customSplits = {};
  final Set<String> _participants = {};
  bool _loading = false;

  final List<String> _categories = [
    'Food', 'Transport', 'Accommodation', 'Entertainment', 'Shopping', 'Utilities', 'Other',
  ];
  final Map<String, String> _catEmojis = {
    'Food': '🍔', 'Transport': '🚗', 'Accommodation': '🏨',
    'Entertainment': '🎉', 'Shopping': '🛒', 'Utilities': '⚡', 'Other': '💸',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final group = context.read<AppProvider>().getGroup(widget.groupId);
      if (group != null) {
        setState(() {
          _payerId = group.members.isNotEmpty ? group.members.first.id : null;
          for (final m in group.members) {
            _participants.add(m.id);
            _customSplits[m.id] = TextEditingController(text: '0');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    for (final c in _customSplits.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<ExpenseParticipant> _buildParticipants(List<AppMember> members) {
    final selected = members.where((m) => _participants.contains(m.id)).toList();
    if (_splitEqually) {
      final double share = selected.isEmpty
          ? 0.0
          : (double.tryParse(_amountCtrl.text) ?? 0.0) / selected.length.toDouble();
      return selected.map((m) => ExpenseParticipant(memberId: m.id, share: share)).toList();
    } else {
      return selected.map((m) {
        final double share = double.tryParse(_customSplits[m.id]?.text ?? '0') ?? 0.0;
        return ExpenseParticipant(memberId: m.id, share: share);
      }).toList();
    }
  }

  Future<void> _save(List<AppMember> members) async {
    final desc = _descCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (desc.isEmpty) { _snack('Enter a description'); return; }
    if (amount == null || amount <= 0) { _snack('Enter a valid amount'); return; }
    if (_payerId == null) { _snack('Select who paid'); return; }
    if (_participants.isEmpty) { _snack('Select at least one participant'); return; }

    if (!_splitEqually) {
      final double total = _participants.fold<double>(
        0.0,
            (sum, id) => sum + (double.tryParse(_customSplits[id]?.text ?? '0') ?? 0.0),
      );
      if ((total - amount).abs() > 0.01) {
        _snack('Custom splits must add up to $amount');
        return;
      }
    }

    setState(() => _loading = true);
    final expense = Expense(
      id: const Uuid().v4(),
      description: desc,
      amount: amount,
      payerId: _payerId!,
      participants: _buildParticipants(members),
      date: DateTime.now(),
      category: _category,
    );
    await context.read<AppProvider>().addExpense(widget.groupId, expense);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, provider, _) {
      final group = provider.getGroup(widget.groupId);
      if (group == null) return const Scaffold();
      final isDark = provider.isDark;
      final sym = AppConstants.getCurrencySymbol(provider.currency);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Add Expense'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Category ─────────────────────────────────────────────
              _Label('Category'),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final sel = cat == _category;
                    return GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppTheme.primary
                              : (isDark ? AppTheme.darkCardAlt : AppTheme.lightCard),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: sel ? AppTheme.primary : Colors.transparent,
                          ),
                          boxShadow: sel
                              ? [BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 10,
                          )]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Text(_catEmojis[cat] ?? '💸'),
                            const SizedBox(width: 6),
                            Text(
                              cat,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
                  .animate()
                  .slideX(begin: 0.1, duration: 350.ms)
                  .fadeIn(duration: 350.ms),
              const SizedBox(height: 20),

              // ── Description ──────────────────────────────────────────
              _Label('Description'),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g., Dinner at restaurant',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _catEmojis[_category] ?? '💸',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              )
                  .animate()
                  .slideX(begin: 0.1, delay: 50.ms, duration: 350.ms)
                  .fadeIn(delay: 50.ms, duration: 350.ms),
              const SizedBox(height: 16),

              // ── Amount ───────────────────────────────────────────────
              _Label('Amount'),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money_rounded, color: AppTheme.accent),
                  prefixText: '$sym ',
                  prefixStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent,
                  ),
                ),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
                onChanged: (_) => setState(() {}),
              )
                  .animate()
                  .slideX(begin: 0.1, delay: 100.ms, duration: 350.ms)
                  .fadeIn(delay: 100.ms, duration: 350.ms),
              const SizedBox(height: 20),

              // ── Paid by ──────────────────────────────────────────────
              _Label('Paid by'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCardAlt : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _payerId,
                    isExpanded: true,
                    dropdownColor: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    ),
                    items: group.members
                        .map((m) => DropdownMenuItem(value: m.id, child: Text(m.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _payerId = v),
                  ),
                ),
              )
                  .animate()
                  .slideX(begin: 0.1, delay: 150.ms, duration: 350.ms)
                  .fadeIn(delay: 150.ms, duration: 350.ms),
              const SizedBox(height: 20),

              // ── Split toggle ─────────────────────────────────────────
              Row(
                children: [
                  _Label('Split equally'),
                  const Spacer(),
                  Switch.adaptive(
                    value: _splitEqually,
                    onChanged: (v) => setState(() => _splitEqually = v),
                    activeColor: AppTheme.primary,
                    activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
                    inactiveTrackColor:
                    isDark ? AppTheme.darkCardAlt : AppTheme.lightCard,
                    inactiveThumbColor: AppTheme.darkTextSub,
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
              const SizedBox(height: 12),

              // ── Participants ─────────────────────────────────────────
              _Label('Split among'),
              const SizedBox(height: 8),
              ...group.members.map((m) {
                final included = _participants.contains(m.id);
                final double perPerson = (_participants.isNotEmpty && _splitEqually)
                    ? (double.tryParse(_amountCtrl.text) ?? 0.0) /
                    _participants.length.toDouble()
                    : 0.0;

                return GestureDetector(
                  onTap: () => setState(() {
                    if (included) {
                      _participants.remove(m.id);
                    } else {
                      _participants.add(m.id);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: included
                          ? AppTheme.primary.withValues(alpha: 0.1)
                          : (isDark ? AppTheme.darkCardAlt : AppTheme.lightCard),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: included
                            ? AppTheme.primary
                            : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: included ? AppTheme.primary : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: included ? AppTheme.primary : AppTheme.darkTextSub,
                              width: 2,
                            ),
                          ),
                          child: included
                              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            m.name,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (!_splitEqually && included)
                          SizedBox(
                            width: 90,
                            child: TextField(
                              controller: _customSplits[m.id],
                              keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                hintText: '0.00',
                                prefixText: '$sym ',
                              ),
                              style: GoogleFonts.poppins(fontSize: 12),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        if (_splitEqually && included) ...[
                          const SizedBox(width: 8),
                          Text(
                            '$sym${perPerson.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),

              // ── Save button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : () => _save(group.members),
                  child: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.save_rounded),
                      SizedBox(width: 8),
                      Text('Save Expense'),
                    ],
                  ),
                ),
              )
                  .animate()
                  .slideY(begin: 0.2, delay: 300.ms, duration: 400.ms)
                  .fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub,
        letterSpacing: 0.5,
      ),
    );
  }
}