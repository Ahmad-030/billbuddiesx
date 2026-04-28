// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieCtrl;

  @override
  void initState() {
    super.initState();
    _lottieCtrl = AnimationController(vsync: this);
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
    _lottieCtrl.dispose();
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
            // Floating coins background (lightweight emoji — unchanged)
            ..._buildFloatingCoins(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Lottie coin animation replacing the static logo box ──
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Soft glow behind the animation
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primary.withOpacity(0.35),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.45),
                              blurRadius: 60,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      Lottie.asset(
                        'assets/coin.json',
                        controller: _lottieCtrl,
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                        onLoaded: (composition) {
                          _lottieCtrl
                            ..duration = composition.duration
                            ..repeat();
                        },
                      ),
                    ],
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
                      .slideY(
                      begin: 0.3,
                      duration: 600.ms,
                      delay: 200.ms,
                      curve: Curves.easeOut)
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
                      .slideY(
                      begin: 0.3,
                      duration: 600.ms,
                      delay: 350.ms,
                      curve: Curves.easeOut)
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
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingCoins() {
    final coins = ['💵', '💴', '💶', '💷', '🪙', '💳', '💰', '🏦'];
    return List.generate(8, (i) {
      final positions = [
        [0.1, 0.1],
        [0.85, 0.15],
        [0.05, 0.5],
        [0.9, 0.45],
        [0.15, 0.8],
        [0.8, 0.75],
        [0.5, 0.05],
        [0.45, 0.92],
      ];
      return Positioned(
        left: MediaQuery.of(context).size.width * positions[i][0],
        top: MediaQuery.of(context).size.height * positions[i][1],
        child: Text(
          coins[i],
          style: TextStyle(
            fontSize: 20 + (i % 3) * 8.0,
          ),
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