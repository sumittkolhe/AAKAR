import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../providers/game_provider.dart';
import '../../widgets/aakar_widgets.dart';

/// 🎮 Game Menu Page - Gamified Hub with Progress & XP
class GameMenuPage extends StatelessWidget {
  const GameMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

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
          'Play & Learn 🎮',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                
                // 📊 Stats Bar
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: _buildStatsBar(gameProvider),
                ),
                
                const SizedBox(height: 28),
                
                // Section Title
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Choose a Game',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 🎮 Face Emotion Game
                FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  child: _buildGameCard(
                    context,
                    emoji: '😊😢',
                    title: 'Face Emotion Game',
                    description: 'Guess the emotion from faces',
                    progress: 0.75, // TODO: Get real progress
                    xpReward: 50,
                    difficulty: 1,
                    bestScore: gameProvider.highScore('face_emotion'),
                    gradient: AppColors.purpleGradient,
                    route: '/face-game',
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 🎤 Voice Emotion Game (Coming Soon)
                FadeInRight(
                  delay: const Duration(milliseconds: 300),
                  child: _buildGameCard(
                    context,
                    emoji: '🎤🎵',
                    title: 'Voice Emotion Game',
                    description: 'Guess emotions from voice',
                    xpReward: 75,
                    difficulty: 2,
                    isLocked: true,
                    gradient: AppColors.mintGradient,
                    route: '/voice-game',
                  ),
                ),
                
                const SizedBox(height: 16),

                // 🧠 Memory Match
                FadeInLeft(
                  delay: const Duration(milliseconds: 300),
                  child: _buildGameCard(
                    context,
                    emoji: '🧠🃏',
                    title: 'Memory Match',
                    description: 'Find matching emotions',
                    xpReward: 100,
                    difficulty: 2,
                    gradient: AppColors.tealGradient, // Or any other nice gradient
                    route: '/memory-game',
                    bestScore: gameProvider.highScore('memory_match'),
                  ),
                ),
                
                const SizedBox(height: 16),

                // 📖 Scenario Quiz
                FadeInRight(
                  delay: const Duration(milliseconds: 350),
                  child: _buildGameCard(
                    context,
                    emoji: '📖✨',
                    title: 'Scenario Quiz',
                    description: 'What would you feel?',
                    xpReward: 60,
                    difficulty: 1,
                    gradient: AppColors.sunsetGradient,
                    route: '/scenario-game',
                    bestScore: gameProvider.highScore('scenario_quiz'),
                  ),
                ),
                
                const SizedBox(height: 16),

                // 🧘 Zen Zone
                FadeInLeft(
                  delay: const Duration(milliseconds: 380),
                  child: _buildGameCard(
                    context,
                    emoji: '🧘‍♀️🌿',
                    title: 'Zen Zone',
                    description: 'Breathe & Ground yourself.',
                    xpReward: 15, 
                    difficulty: 0,
                    gradient: AppColors.mintGradient,
                    route: '/zen-zone',
                  ),
                ),
                
                const SizedBox(height: 16),

                // 📓 Mood Journal
                FadeInRight(
                  delay: const Duration(milliseconds: 400),
                  child: _buildGameCard(
                    context,
                    emoji: '📓✍️',
                    title: 'Mood Journal',
                    description: 'Track your feelings daily.',
                    xpReward: 10,
                    difficulty: 0,
                    gradient: AppColors.warmGradient,
                    route: '/mood-journal',
                  ),
                ),

                const SizedBox(height: 16),

                // 🎨 Draw Your Feelings
                FadeInLeft(
                  delay: const Duration(milliseconds: 420),
                  child: _buildGameCard(
                    context,
                    emoji: '🎨🖌️',
                    title: 'Draw Feelings',
                    description: 'Express yourself with art.',
                    xpReward: 20,
                    difficulty: 0,
                    gradient: AppColors.storyGradient,
                    route: '/drawing',
                  ),
                ),

                const SizedBox(height: 16),

                // 📚 Social Stories
                FadeInRight(
                  delay: const Duration(milliseconds: 440),
                  child: _buildGameCard(
                    context,
                    emoji: '📚🎭',
                    title: 'Social Stories',
                    description: 'Learn social skills.',
                    xpReward: 50,
                    difficulty: 0,
                    gradient: AppColors.calmGradient,
                    route: '/social-stories',
                  ),
                ),

                const SizedBox(height: 16),

                // 🏆 Kindness Quests
                FadeInLeft(
                  delay: const Duration(milliseconds: 460),
                  child: _buildGameCard(
                    context,
                    emoji: '🏆✨',
                    title: 'Kindness Quests',
                    description: 'Real-world missions.',
                    xpReward: 30, // Average per quest
                    difficulty: 0,
                    gradient: AppColors.goldGradient,
                    route: '/kindness-quests',
                  ),
                ),
                

                
                const SizedBox(height: 16),
                
                // 🏆 Rewards
                FadeInLeft(
                  delay: const Duration(milliseconds: 400),
                  child: _buildGameCard(
                    context,
                    emoji: '🏆⭐',
                    title: 'My Rewards',
                    description: 'View badges & trophies',
                    unlockedBadges: gameProvider.badges.length,
                    gradient: AppColors.warmGradient,
                    route: '/rewards',
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 💡 Tips section
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _buildTipsCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar(GameProvider gameProvider) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🏆', 'Level ${gameProvider.level}', 'LEVEL'),
          Container(
            height: 40,
            width: 1,
            color: AppColors.glassBorder,
          ),
          _buildStatItem('⭐', '${gameProvider.totalXP}', 'XP'),
          Container(
            height: 40,
            width: 1,
            color: AppColors.glassBorder,
          ),
          _buildStatItem('🔥', '${gameProvider.dailyStreak} Days', 'STREAK'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String description,
    double? progress,
    int? xpReward,
    int? difficulty,
    int? bestScore,
    int? unlockedBadges,
    bool isLocked = false,
    required LinearGradient gradient,
    required String route,
  }) {
    // Determine card background color/gradient opacity based on locked state
    final cardColor = AppColors.surface;
    final borderColor = isLocked ? AppColors.glassBorder : gradient.colors.first.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: isLocked ? null : () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: isLocked ? null : [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji container
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: isLocked ? null : gradient,
                color: isLocked ? AppColors.surfaceLight : null,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(
                  emoji.length > 2 ? emoji.substring(0, 2) : emoji,
                  style: TextStyle(
                    fontSize: 28,
                    color: isLocked ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isLocked ? AppColors.textMuted : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_rounded, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                'Soon',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  if (progress != null && !isLocked) ...[
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.surfaceLight,
                              valueColor: AlwaysStoppedAnimation(gradient.colors.first),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: gradient.colors.first,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildTag('Level ${difficulty ?? 1}', gradient.colors.first),
                        const SizedBox(width: 8),
                        if (xpReward != null) _buildTag('+$xpReward XP', AppColors.gold),
                        const Spacer(),
                        if (bestScore != null && bestScore > 0) 
                          Text(
                            '🎯 Best: $bestScore',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ] else if (unlockedBadges != null) ...[
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🏅 $unlockedBadges Unlocked',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: gradient.colors.first,
                      ),
                    ),
                  ] else ...[
                    Text(
                      isLocked ? '🔜 Coming Soon!' : description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontStyle: isLocked ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    if (xpReward != null && !isLocked) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag('Level ${difficulty ?? 1}', gradient.colors.first),
                          const SizedBox(width: 8),
                          _buildTag('+$xpReward XP', AppColors.gold),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
            
            // Arrow
            if (!isLocked)
              Icon(
                Icons.chevron_right_rounded,
                color: gradient.colors.first,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Center(
              child: Text('💡', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Play daily to build your streak and earn bonus XP! 🔥',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
