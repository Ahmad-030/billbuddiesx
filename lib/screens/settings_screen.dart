// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, provider, _) {
      final isDark = provider.isDark;

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 8),
              Text('Settings', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800))
                  .animate().slideY(begin: -0.1, duration: 400.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              // Appearance
              _SectionHeader('Appearance'),
              _SettingCard(
                children: [
                  _SettingRow(
                    icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    iconColor: AppTheme.primary,
                    title: 'Dark Mode',
                    subtitle: isDark ? 'Currently dark' : 'Currently light',
                    trailing: Switch.adaptive(
                      value: isDark,
                      onChanged: (_) => provider.toggleTheme(),
                      activeColor: AppTheme.primary,
                    ),
                    isDark: isDark,
                  ),
                ],
                isDark: isDark,
              ).animate().slideX(begin: 0.1, delay: 100.ms, duration: 350.ms).fadeIn(delay: 100.ms, duration: 350.ms),
              const SizedBox(height: 16),

              // Currency
              _SectionHeader('Currency'),
              _SettingCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.currency_exchange_rounded, color: AppTheme.accent, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Text('Select Currency', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCardAlt : AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: provider.currency,
                              isExpanded: true,
                              dropdownColor: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isDark ? AppTheme.darkText : AppTheme.lightText),
                              items: AppConstants.currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) { if (v != null) provider.setCurrency(v); },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                isDark: isDark,
              ).animate().slideX(begin: 0.1, delay: 150.ms, duration: 350.ms).fadeIn(delay: 150.ms, duration: 350.ms),
              const SizedBox(height: 16),

              // About & Info
              _SectionHeader('Info'),
              _SettingCard(
                children: [
                  _SettingRow(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppTheme.primary,
                    title: 'About BillBuddiesX',
                    subtitle: 'Version & developer info',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    isDark: isDark,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                  Divider(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder, height: 1, indent: 14, endIndent: 14),
                  _SettingRow(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppTheme.success,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    isDark: isDark,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  ),
                ],
                isDark: isDark,
              ).animate().slideX(begin: 0.1, delay: 200.ms, duration: 350.ms).fadeIn(delay: 200.ms, duration: 350.ms),
              const SizedBox(height: 16),

              // Danger zone
              _SectionHeader('Danger Zone'),
              _SettingCard(
                children: [
                  _SettingRow(
                    icon: Icons.delete_forever_rounded,
                    iconColor: AppTheme.error,
                    title: 'Reset All Data',
                    subtitle: 'Delete all groups and expenses',
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.error),
                    isDark: isDark,
                    onTap: () => _confirmReset(context, provider),
                  ),
                ],
                isDark: isDark,
              ).animate().slideX(begin: 0.1, delay: 250.ms, duration: 350.ms).fadeIn(delay: 250.ms, duration: 350.ms),
              const SizedBox(height: 32),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text('💰', style: const TextStyle(fontSize: 32))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 0.9, end: 1.1, duration: 1200.ms),
                    const SizedBox(height: 8),
                    Text('BillBuddiesX', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  void _confirmReset(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset All Data', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete all groups, members, and expenses. This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.resetAll();
            },
            child: Text('Reset', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final Widget trailing;
  final bool isDark;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}