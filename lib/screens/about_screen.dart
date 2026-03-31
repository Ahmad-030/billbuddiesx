// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final features = [
      ['💰', 'Split bills instantly', 'Divide expenses equally or with custom amounts'],
      ['👥', 'Group management', 'Create groups for trips, roommates, dinners & more'],
      ['📊', 'Visual reports', 'Pie charts and bar charts for clear spending insights'],
      ['🔒', 'Fully offline', 'No internet, no account, no tracking – ever'],
      ['⚡', 'Lightning fast', 'Everything stored locally for instant access'],
      ['🎨', 'Beautiful UI', 'Modern design with dark & light mode support'],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A1A35), AppTheme.darkBg]
                      : [const Color(0xFFEEEEFF), AppTheme.lightBg],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
                      ],
                    ),
                    child: const Center(child: Text('💰', style: TextStyle(fontSize: 44))),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),
                  Text(
                    'BillBuddiesX',
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800),
                  ).animate().slideY(begin: 0.3, delay: 200.ms, duration: 400.ms).fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Version 1.0.0',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ).animate().scale(delay: 350.ms, duration: 400.ms).fadeIn(delay: 350.ms, duration: 400.ms),
                  const SizedBox(height: 16),
                  Text(
                    'Split bills. Track debts. Stay friends.',
                    style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                ],
              ),
            ),

            // Features
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Features', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800))
                      .animate().fadeIn(delay: 500.ms, duration: 400.ms),
                  const SizedBox(height: 14),
                  ...features.asMap().entries.map((entry) {
                    final i = entry.key;
                    final f = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(child: Text(f[0], style: const TextStyle(fontSize: 22))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f[1], style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text(f[2], style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .slideX(begin: 0.1, delay: Duration(milliseconds: 500 + i * 60), duration: 350.ms)
                        .fadeIn(delay: Duration(milliseconds: 500 + i * 60), duration: 350.ms);
                  }),
                  const SizedBox(height: 24),

                  // Developer info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A35), Color(0xFF252540)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text('👨‍💻', style: TextStyle(fontSize: 36))
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .moveY(begin: 0, end: -5, duration: 1200.ms),
                        const SizedBox(height: 12),
                        Text('Developed by', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
                        Text('DanaTypeApps', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '📧 Adnanmirza.console1@gmail.com',
                            style: GoogleFonts.poppins(color: AppTheme.primaryLight, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Built with ❤️ using Flutter',
                          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ).animate().scale(delay: 900.ms, duration: 400.ms, curve: Curves.easeOut).fadeIn(delay: 900.ms, duration: 400.ms),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
