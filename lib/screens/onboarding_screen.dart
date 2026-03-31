// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../widgets/animated_gradient_button.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _current = 0;

  static const _pages = [
    _OnboardPage(
      emoji: '💰',
      title: 'Split Bills\nEffortlessly',
      subtitle: 'Add any expense and let BillBuddiesX automatically calculate who owes what.',
      gradient: [Color(0xFF6C63FF), Color(0xFF9D96FF)],
    ),
    _OnboardPage(
      emoji: '👥',
      title: 'Manage Any\nGroup',
      subtitle: 'Roommates, travel buddies, dinner friends — create groups for any occasion.',
      gradient: [Color(0xFFF7971E), Color(0xFFFFBD59)],
    ),
    _OnboardPage(
      emoji: '📊',
      title: 'Track &\nVisualize',
      subtitle: 'See spending charts, filter by member, and get a clear picture of every penny.',
      gradient: [Color(0xFF00D8A4), Color(0xFF00B4D8)],
    ),
    _OnboardPage(
      emoji: '🔒',
      title: '100% Private\n& Offline',
      subtitle: 'No accounts. No internet. No tracking. Your data stays on your device — always.',
      gradient: [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
    ),
  ];

  void _next() {
    if (_current < _pages.length - 1) {
      _pageCtrl.nextPage(duration: 400.ms, curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: 600.ms,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_current];

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedContainer(
            duration: 500.ms,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  page.gradient[0].withOpacity(0.2),
                  AppTheme.darkBg,
                ],
              ),
            ),
          ),

          // Page content
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _pages.length,
            itemBuilder: (context, i) => _buildPage(_pages[i], i == _current),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _current;
                      return AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? page.gradient[0] : AppTheme.darkBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // Button
                  AnimatedGradientButton(
                    label: _current == _pages.length - 1 ? "Let's Go! 🚀" : 'Next',
                    icon: _current == _pages.length - 1 ? null : Icons.arrow_forward_rounded,
                    colors: page.gradient,
                    onTap: _next,
                  ),
                  if (_current < _pages.length - 1) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          color: AppTheme.darkTextSub,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardPage page, bool active) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 160),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji in glowing circle
          AnimatedContainer(
            duration: 400.ms,
            width: active ? 140 : 100,
            height: active ? 140 : 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: page.gradient[0].withOpacity(0.5),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                page.emoji,
                style: TextStyle(fontSize: active ? 68 : 48),
              ),
            ),
          )
              .animate(target: active ? 1 : 0)
              .scaleXY(begin: 0.8, end: 1.0, duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.15,
            ),
          ).animate(key: ValueKey(page.title)).slideY(begin: 0.2, duration: 400.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 18),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppTheme.darkTextSub,
              height: 1.6,
            ),
          ).animate(key: ValueKey(page.subtitle)).slideY(begin: 0.2, delay: 80.ms, duration: 400.ms).fadeIn(delay: 80.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final String emoji, title, subtitle;
  final List<Color> gradient;
  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
