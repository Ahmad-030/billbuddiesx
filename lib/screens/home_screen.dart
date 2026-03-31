// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, provider, _) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _currentIndex == 0
            ? _buildDashboard(provider)
            : const SettingsScreen(),
        bottomNavigationBar: _buildBottomNav(provider),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton.extended(
          onPressed: () => _openCreateGroup(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'New Group',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.primary,
        ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.elasticOut)
            : null,
      );
    });
  }

  Widget _buildBottomNav(AppProvider provider) {
    final isDark = provider.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor:
        isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub,
        selectedLabelStyle:
        GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home_rounded, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            activeIcon: Icon(Icons.settings_rounded, size: 28),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(AppProvider provider) {
    final groups = provider.groups;
    final sym = AppConstants.getCurrencySymbol(provider.currency);

    double totalOwed = 0, totalOwe = 0;
    for (final g in groups) {
      for (final entry in g.balances.entries) {
        if (entry.value > 0) totalOwed += entry.value;
        if (entry.value < 0) totalOwe += entry.value.abs();
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeader(
                groups, sym, totalOwed, totalOwe, provider.isDark),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: provider.isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
          ),
        ),
        if (groups.isEmpty)
          SliverFillRemaining(child: _buildEmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) => _GroupCard(
                  group: groups[i],
                  symbol: sym,
                  index: i,
                )
                    .animate()
                    .slideX(
                  begin: 0.1,
                  delay: Duration(milliseconds: i * 60),
                  duration: 400.ms,
                  curve: Curves.easeOut,
                )
                    .fadeIn(
                  delay: Duration(milliseconds: i * 60),
                  duration: 400.ms,
                ),
                childCount: groups.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(List<Group> groups, String sym, double owed,
      double owe, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A35), const Color(0xFF0D0D1A)]
              : [const Color(0xFFEEEEFF), const Color(0xFFF5F5FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('💰', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                'BillBuddiesX',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'You are owed',
                  value: '$sym${owed.toStringAsFixed(2)}',
                  color: AppTheme.success,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'You owe',
                  value: '$sym${owe.toStringAsFixed(2)}',
                  color: AppTheme.error,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Groups',
                  value: '${groups.length}',
                  color: AppTheme.primary,
                  icon: Icons.group_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤝', style: TextStyle(fontSize: 72))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.9, end: 1.1, duration: 1500.ms, curve: Curves.easeInOut),
          const SizedBox(height: 24),
          Text(
            'No groups yet!',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first group to start\nsplitting expenses with friends.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.darkTextSub,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _openCreateGroup(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Group'),
          ),
        ],
      ),
    );
  }

  void _openCreateGroup(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CreateGroupScreen()));
  }
}

// ── Mini stat card ──────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Group card ──────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final Group group;
  final String symbol;
  final int index;

  const _GroupCard({
    required this.group,
    required this.symbol,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = group.totalExpenses;

    final List<Color> gradients = [
      AppTheme.primary,
      AppTheme.accent,
      AppTheme.success,
      const Color(0xFFFF6B9D),
      const Color(0xFF00B4D8),
    ];
    final color = gradients[index % gradients.length];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => GroupDetailScreen(groupId: group.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 20,
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
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child:
                      Text(group.emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.darkText : AppTheme.lightText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${group.members.length} members • ${group.expenses.length} expenses',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.darkTextSub
                                : AppTheme.lightTextSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$symbol${total.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      Text(
                        'total',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: isDark
                              ? AppTheme.darkTextSub
                              : AppTheme.lightTextSub,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (group.members.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(
                  children: [
                    ...group.members.take(5).map(
                          (m) => _MemberAvatar(name: m.name, color: color),
                    ),
                    if (group.members.length > 5)
                      Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '+${group.members.length - 5}',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d').format(group.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark
                            ? AppTheme.darkTextSub
                            : AppTheme.lightTextSub,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: isDark
                          ? AppTheme.darkTextSub
                          : AppTheme.lightTextSub,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final String name;
  final Color color;

  const _MemberAvatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}