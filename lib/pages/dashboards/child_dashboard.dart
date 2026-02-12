import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../widgets/aakar_widgets.dart';
import '../../providers/emotion_history_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/auth_provider.dart';

class ChildDashboardPage extends StatefulWidget {
  const ChildDashboardPage({super.key});

  @override
  State<ChildDashboardPage> createState() => _ChildDashboardPageState();
}

class _ChildDashboardPageState extends State<ChildDashboardPage> {
  String? _lastEmotion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final history = context.read<EmotionHistoryProvider>();
      if (history.recentHistory.isNotEmpty) {
        setState(() {
          _lastEmotion = history.recentHistory.first.emotion;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final authProvider = context.read<AuthProvider>();
    final childName = authProvider.currentUser?.name.split(' ').first ?? 'Friend';

    return Scaffold(
      body: AuroraBackground(
        colors: _lastEmotion != null
            ? [
                EmotionTheme.color(_lastEmotion!).withValues(alpha: 0.15),
                AppColors.secondary.withValues(alpha: 0.05),
              ]
            : null,
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar (Avatar + Streak)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.surfaceLight,
                      radius: 24,
                      child: Text("🧒", style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, $childName!",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Level ${gameProvider.level} Explorer",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    StreakBadge(streak: gameProvider.dailyStreak),
                  ],
                ),
              ),

              // 2. Main Scrollable Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // XP Progress (Big & Fun)
                      FadeInDown(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Your XP Power", style: GoogleFonts.outfit(color: Colors.white)),
                                  Text("${gameProvider.totalXP} / ${gameProvider.level * 100}", 
                                    style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              XPProgressBar(
                                currentXP: gameProvider.totalXP,
                                maxXP: gameProvider.level * 100,
                                level: gameProvider.level,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Big "How are you?" Button
                      FadeInUp(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/detect'),
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: AppColors.storyGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("🎭", style: TextStyle(fontSize: 48)),
                                const SizedBox(width: 16),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Check My Mood",
                                      style: GoogleFonts.outfit(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Scan your face!",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Game Grid
                      Column(
                        children: [
                           Row(
                            children: [
                              Expanded(child: _buildBigGameCard(
                                "Games", "🎮", AppColors.mintGradient, () => Navigator.pushNamed(context, '/game-menu'))),
                              const SizedBox(width: 16),
                              Expanded(child: _buildBigGameCard(
                                "Feelings", "🎨", AppColors.warmGradient, () => Navigator.pushNamed(context, '/drawing'))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildBigGameCard(
                                "Zen Zone", "🧘", AppColors.calmGradient, () => Navigator.pushNamed(context, '/zen-zone'))),
                              const SizedBox(width: 16),
                              Expanded(child: _buildBigGameCard(
                                "Quests", "🏆", AppColors.goldGradient, () => Navigator.pushNamed(context, '/kindness-quests'))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildBigGameCard(
                        "Talk to AI", "🤖", AppColors.tealGradient, () => Navigator.pushNamed(context, '/chatbot'), fullWidth: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBigGameCard(String title, String emoji, Gradient gradient, VoidCallback onTap, {bool fullWidth = false}) {
    return FadeInUp(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: fullWidth ? 100 : 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.home_rounded, color: AppColors.primary, size: 30), onPressed: () {}),
          IconButton(icon: const Icon(Icons.star_rounded, color: AppColors.textMuted, size: 30), onPressed: () => Navigator.pushNamed(context, '/rewards')),
           IconButton(icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted, size: 30), 
            onPressed: () {
             context.read<AuthProvider>().logout();
             Navigator.pushReplacementNamed(context, '/role-selection');
            }),
        ],
      ),
    );
  }
}

extension GradientOpacity on Gradient {
  Gradient withOpacity(double opacity) {
    if (this is LinearGradient) {
      final lg = this as LinearGradient;
      return LinearGradient(
        colors: lg.colors.map((c) => c.withOpacity(opacity)).toList(),
        begin: lg.begin,
        end: lg.end,
        stops: lg.stops,
      );
    }
    return this;
  }
}
