import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../theme.dart';
import '../models/quest.dart';
import '../data/quest_data.dart';
import '../widgets/aakar_widgets.dart';
import '../providers/game_provider.dart';

class KindnessQuestPage extends StatefulWidget {
  const KindnessQuestPage({super.key});

  @override
  State<KindnessQuestPage> createState() => _KindnessQuestPageState();
}

class _KindnessQuestPageState extends State<KindnessQuestPage> {
  Box<Quest>? _questBox;
  List<Quest> _todaysQuests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeQuests();
  }

  Future<void> _initializeQuests() async {
    // Open box
    _questBox = await Hive.openBox<Quest>('quests');
    
    // Check if we have quests for today
    // Ideally, store a "lastGeneratedDate" in settings box to refresh daily.
    // For now, we'll just check if box is empty or has < 3 quests (simple logic)
    
    if (_questBox!.isEmpty) {
      _generateDailyQuests();
    } else {
      _todaysQuests = _questBox!.values.toList();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _generateDailyQuests() {
    final random = Random();
    final all = List<Quest>.from(QuestData.allQuests);
    all.shuffle(random);
    _todaysQuests = all.take(3).toList();
    
    _questBox!.clear();
    _questBox!.addAll(_todaysQuests);
  }

  void _completeQuest(int index) {
    if (_todaysQuests[index].isCompleted) return;

    setState(() {
      _todaysQuests[index].isCompleted = true;
      _questBox!.putAt(index, _todaysQuests[index]); // Update Hive
    });

    // Award XP
    context.read<GameProvider>().addXP(_todaysQuests[index].xpReward);

    // Show Celebration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quest Complete! +${_todaysQuests[index].xpReward} XP 🌟'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Check if all done
    if (_todaysQuests.every((q) => q.isCompleted)) {
      _showAllDoneDialog();
    }
  }

  void _showAllDoneDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🏆", style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                "All Quests Done!",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You are a Kindness Superhero!",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Awesome!',
                gradient: AppColors.goldGradient,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
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
          'Kindness Quests 🏆',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _generateDailyQuests());
            },
            tooltip: "New Quests",
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _todaysQuests.length,
                  itemBuilder: (context, index) {
                    final quest = _todaysQuests[index];
                    return FadeInLeft(
                      delay: Duration(milliseconds: index * 200),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GlassCard(
                          glowColor: quest.isCompleted ? AppColors.primary : null,
                          child: InkWell(
                            onTap: () => _completeQuest(index),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: quest.isCompleted ? AppColors.primary : Colors.transparent,
                                      border: Border.all(
                                        color: quest.isCompleted ? AppColors.primary : AppColors.textSecondary,
                                        width: 2,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.check,
                                      size: 20,
                                      color: quest.isCompleted ? Colors.white : Colors.transparent,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          quest.title,
                                          style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                            decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                                            decorationColor: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          quest.description,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                                    ),
                                    child: Text(
                                      "+${quest.xpReward} XP",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
