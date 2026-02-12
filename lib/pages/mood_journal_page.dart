import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

import '../theme.dart';
import '../models/mood_entry.dart';
import '../widgets/aakar_widgets.dart';

class MoodJournalPage extends StatefulWidget {
  const MoodJournalPage({super.key});

  @override
  State<MoodJournalPage> createState() => _MoodJournalPageState();
}

class _MoodJournalPageState extends State<MoodJournalPage> {
  Box<MoodEntry>? _moodBox;
  String? _selectedEmotion;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _emotions = ['Happy', 'Sad', 'Angry', 'Fear', 'Excited', 'Calm'];
  
  // For the "Calendar" strip
  final DateTime _now = DateTime.now();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _now;
    _openBox();
  }

  Future<void> _openBox() async {
    _moodBox = await Hive.openBox<MoodEntry>('mood_journal');
    setState(() {});
  }

  void _saveEntry() {
    if (_selectedEmotion == null) return;
    
    final entry = MoodEntry(
      date: DateTime.now(),
      emotion: _selectedEmotion!,
      note: _noteController.text,
    );

    _moodBox?.add(entry);
    
    _noteController.clear();
    setState(() {
      _selectedEmotion = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mood Saved! 🌟'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mood Journal 📓',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Entry Section
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    FadeInDown(
                      child: Text(
                        "How are you feeling?",
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Emotion Selector
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _emotions.map((emotion) {
                        final isSelected = _selectedEmotion == emotion;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedEmotion = emotion;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? EmotionTheme.color(emotion) : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                color: isSelected 
                                  ? EmotionTheme.color(emotion) 
                                  : AppColors.glassBorder,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: EmotionTheme.color(emotion).withValues(alpha: 0.4), blurRadius: 10)]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  EmotionTheme.emoji(emotion),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  emotion,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Note Input
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextField(
                          controller: _noteController,
                          maxLines: 3,
                          style: GoogleFonts.inter(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Why do you feel this way? (Optional)",
                            hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Save Button
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: GradientButton(
                          label: 'Save Mood',
                          gradient: _selectedEmotion != null 
                              ? AppColors.primaryGradient 
                              : const LinearGradient(colors: [Colors.grey, Colors.grey]), // Disabled look
                          onPressed: _selectedEmotion != null ? _saveEntry : () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Recent History (Mini List)
              Container(
                height: 250,
                padding: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border(top: BorderSide(color: AppColors.glassBorder)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Recent Moods",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _moodBox == null
                          ? const Center(child: CircularProgressIndicator())
                          : ValueListenableBuilder(
                              valueListenable: _moodBox!.listenable(),
                              builder: (context, Box<MoodEntry> box, _) {
                                if (box.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "No moods yet. Start tracking!",
                                      style: GoogleFonts.inter(color: AppColors.textMuted),
                                    ),
                                  );
                                }
                                // Show last 10 entries reversed
                                final entries = box.values.toList().reversed.take(10).toList();
                                
                                return ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: entries.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final entry = entries[index];
                                    return GlassCard(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: EmotionTheme.color(entry.emotion).withValues(alpha: 0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              EmotionTheme.emoji(entry.emotion),
                                              style: const TextStyle(fontSize: 24),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  entry.emotion,
                                                  style: GoogleFonts.outfit(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                if (entry.note.isNotEmpty)
                                                  Text(
                                                    entry.note,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                DateFormat('MMM d').format(entry.date),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('h:mm a').format(entry.date),
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
