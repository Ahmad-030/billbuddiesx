// lib/screens/create_group_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../models/models.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameCtrl = TextEditingController();
  final _memberCtrl = TextEditingController();
  final List<String> _members = [];
  String _selectedEmoji = '👥';
  bool _loading = false;

  final List<String> _emojis = [
    '👥', '✈️', '🏠', '🍕', '🎉', '🏖️', '🛒', '🎮',
    '💼', '🎓', '🏋️', '🎸', '🌍', '🚗', '⚽', '🎭',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _memberCtrl.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberCtrl.text.trim();
    if (name.isEmpty) return;
    if (_members.contains(name)) {
      _showSnack('Member already added');
      return;
    }
    setState(() => _members.add(name));
    _memberCtrl.clear();
  }

  void _removeMember(int i) => setState(() => _members.removeAt(i));

  Future<void> _createGroup() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack('Please enter a group name');
      return;
    }
    if (_members.length < 2) {
      _showSnack('Add at least 2 members');
      return;
    }

    setState(() => _loading = true);
    final uuid = const Uuid();
    final group = Group(
      id: uuid.v4(),
      name: _nameCtrl.text.trim(),
      members: _members.map((n) => AppMember(id: uuid.v4(), name: n)).toList(),
      expenses: [],
      createdAt: DateTime.now(),
      emoji: _selectedEmoji,
    );

    await context.read<AppProvider>().addGroup(group);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showSnack(String msg) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
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
            // Emoji picker
            _SectionTitle('Choose an Icon').animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _emojis.length,
                itemBuilder: (context, i) {
                  final selected = _emojis[i] == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = _emojis[i]),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.only(right: 10),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary.withOpacity(0.2)
                            : (isDark ? AppTheme.darkCardAlt : AppTheme.lightCard),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppTheme.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(_emojis[i], style: const TextStyle(fontSize: 26)),
                      ),
                    ).animate(target: selected ? 1 : 0).scaleXY(end: 1.1, duration: 200.ms),
                  );
                },
              ),
            ).animate().slideX(begin: 0.1, duration: 400.ms, delay: 100.ms).fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 24),

            // Group name
            _SectionTitle('Group Name').animate().fadeIn(duration: 400.ms, delay: 150.ms),
            const SizedBox(height: 10),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'e.g., Trip to Bali, Roommates...',
                prefixIcon: Text(_selectedEmoji,
                    style: const TextStyle(fontSize: 20))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 0.95, end: 1.05, duration: 1000.ms),
              ),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ).animate().slideX(begin: 0.1, duration: 400.ms, delay: 200.ms).fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 24),

            // Add members
            _SectionTitle('Add Members (min. 2)').animate().fadeIn(duration: 400.ms, delay: 250.ms),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memberCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Member name',
                      prefixIcon: Icon(Icons.person_add_rounded, color: AppTheme.primary),
                    ),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    onSubmitted: (_) => _addMember(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _addMember,
                  child: AnimatedContainer(
                    duration: 200.ms,
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ).animate().slideX(begin: 0.1, duration: 400.ms, delay: 300.ms).fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: 16),

            // Member list
            if (_members.isNotEmpty) ...[
              ..._members.asMap().entries.map((entry) {
                final i = entry.key;
                final name = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCardAlt : AppTheme.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            name[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeMember(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close_rounded, size: 18, color: AppTheme.error),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .slideX(begin: 0.2, duration: 300.ms, curve: Curves.easeOut)
                    .fadeIn(duration: 300.ms);
              }),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _createGroup,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.group_add_rounded),
                          const SizedBox(width: 8),
                          const Text('Create Group'),
                        ],
                      ),
              ),
            ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 400.ms).fadeIn(duration: 400.ms, delay: 400.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isDark ? AppTheme.darkTextSub : AppTheme.lightTextSub,
        letterSpacing: 0.5,
      ),
    );
  }
}
