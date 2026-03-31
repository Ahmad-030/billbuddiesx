// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _coinController;

  @override
  void initState() {
    super.initState();
    _coinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    await provider.init();
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            onboardingDone ? const HomeScreen() : const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _coinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF1A1A35), AppTheme.darkBg],
          ),
        ),
        child: Stack(
          children: [
            // Floating coins background
            ..._buildFloatingCoins(),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('💰', style: TextStyle(fontSize: 52)),
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 28),
                  Text(
                    'BillBuddiesX',
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  )
                      .animate()
                      .slideY(begin: 0.3, duration: 600.ms, delay: 200.ms, curve: Curves.easeOut)
                      .fadeIn(duration: 500.ms, delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Split bills. Track debts. Stay friends.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.darkTextSub,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                      .animate()
                      .slideY(begin: 0.3, duration: 600.ms, delay: 350.ms, curve: Curves.easeOut)
                      .fadeIn(duration: 500.ms, delay: 350.ms),
                  const SizedBox(height: 60),
                  // Loading dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .scaleXY(
                            begin: 0.5,
                            end: 1.2,
                            delay: Duration(milliseconds: i * 180),
                            duration: 500.ms,
                          )
                          .then()
                          .scaleXY(begin: 1.2, end: 0.5, duration: 500.ms);
                    }),
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                ],
              ),
            ),
            // Bottom branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'by DanaTypeApps',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.darkTextSub,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingCoins() {
    final coins = ['💵', '💴', '💶', '💷', '🪙', '💳', '💰', '🏦'];
    return List.generate(8, (i) {
      final positions = [
        [0.1, 0.1], [0.85, 0.15], [0.05, 0.5], [0.9, 0.45],
        [0.15, 0.8], [0.8, 0.75], [0.5, 0.05], [0.45, 0.92],
      ];
      return Positioned(
        left: MediaQuery.of(context).size.width * positions[i][0],
        top: MediaQuery.of(context).size.height * positions[i][1],
        child: Text(
          coins[i],
          style: TextStyle(fontSize: 20 + (i % 3) * 8.0,),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: 0,
              end: -15,
              duration: Duration(milliseconds: 1500 + i * 300),
              curve: Curves.easeInOut,
            )
            .fadeIn(delay: Duration(milliseconds: i * 100)),
      );
    });
  }
}

extension on Text {
  Text copyWith({TextStyle? style}) => Text(data ?? '', style: style);
}
