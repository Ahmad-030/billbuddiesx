// lib/widgets/empty_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.9, end: 1.05, duration: 1800.ms, curve: Curves.easeInOut),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            if (buttonLabel != null && onButtonTap != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onButtonTap,
                icon: const Icon(Icons.add_rounded),
                label: Text(buttonLabel!),
              ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.elasticOut),
            ],
          ],
        ),
      ),
    );
  }
}
