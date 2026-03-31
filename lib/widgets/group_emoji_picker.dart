// lib/widgets/group_emoji_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class GroupEmojiPicker extends StatefulWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const GroupEmojiPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<GroupEmojiPicker> createState() => _GroupEmojiPickerState();
}

class _GroupEmojiPickerState extends State<GroupEmojiPicker> {
  static const _emojis = [
    '👥', '✈️', '🏠', '🍕', '🎉', '🏖️', '🛒', '🎮',
    '💼', '🎓', '🏋️', '🎸', '🌍', '🚗', '⚽', '🎭',
    '🏕️', '🎂', '🎯', '🎪', '🧳', '🏔️', '🌮', '🍺',
    '🎵', '🏊', '🚢', '🧘', '🎨', '🏡', '🌴', '🎠',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _emojis.length,
        itemBuilder: (context, i) {
          final emoji = _emojis[i];
          final isSelected = emoji == widget.selected;
          return GestureDetector(
            onTap: () => widget.onSelected(emoji),
            child: AnimatedContainer(
              duration: 200.ms,
              margin: const EdgeInsets.only(right: 8),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.2)
                    : (isDark ? AppTheme.darkCardAlt : AppTheme.lightCard),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10)]
                    : [],
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: isSelected ? 28 : 24),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
