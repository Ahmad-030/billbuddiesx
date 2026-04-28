// lib/widgets/member_avatar_stack.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/models.dart';

class MemberAvatarStack extends StatelessWidget {
  final List<AppMember> members;
  final double size;
  final int maxVisible;
  final Color? color;

  const MemberAvatarStack({
    super.key,
    required this.members,
    this.size = 34,
    this.maxVisible = 4,
    this.color,
  });

  static const _palette = [
    AppTheme.primary, AppTheme.accent, AppTheme.success,
    Color(0xFFFF6B9D), Color(0xFF00B4D8), AppTheme.warning,
  ];

  @override
  Widget build(BuildContext context) {
    final visible = members.take(maxVisible).toList();
    final extra = members.length - maxVisible;
    final totalWidth = visible.length * (size * 0.7) + (extra > 0 ? size * 0.7 : 0) + size * 0.3;

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: [
          ...visible.asMap().entries.map((e) {
            final c = color ?? _palette[e.key % _palette.length];
            return Positioned(
              left: e.key * (size * 0.7),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: c.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    e.value.name.isNotEmpty ? e.value.name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      fontSize: size * 0.35,
                      fontWeight: FontWeight.w800,
                      color: c,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (extra > 0)
            Positioned(
              left: visible.length * (size * 0.7),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppTheme.darkCardAlt,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: GoogleFonts.poppins(
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkTextSub,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
