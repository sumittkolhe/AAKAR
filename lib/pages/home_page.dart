import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/aakar_widgets.dart';
import '../providers/emotion_history_provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';
import 'dashboards/child_dashboard.dart';

/// 🏠 Dynamic Emotion Dashboard — the living heartbeat of A.A.K.A.R
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _navIndex = 0;
  String? _lastEmotion;
  double? _lastConfidence;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final history = context.read<EmotionHistoryProvider>();
      if (history.recentHistory.isNotEmpty) {
        final latest = history.recentHistory.first;
        setState(() {
          _lastEmotion = latest.emotion;
          _lastConfidence = latest.confidence;
        });
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅';
    if (hour < 17) return '☀️';
    return '🌙';
  }

  void _onNavTap(int index) {
    if (index == 4) {
      _showMoreMenu();
      return;
    }
    if (index == _navIndex) return;
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/detect');
        break;
      case 2:
        Navigator.pushNamed(context, '/game-menu');
        break;
      case 3:
        Navigator.pushNamed(context, '/chatbot');
        break;
      case 4:
        _showMoreMenu();
        break;
    }
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.modal)),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                _buildMenuItem(Icons.analytics_outlined, 'Analytics', AppColors.tealGradient, '/analytics'),
                _buildMenuItem(Icons.self_improvement, 'Calm Tools', AppColors.calmGradient, '/calm-mode'),
                _buildMenuItem(Icons.emoji_events_rounded, 'Rewards', AppColors.goldGradient, '/rewards'),
                _buildMenuItem(Icons.people_outline_rounded, 'Switch Role', AppColors.mintGradient, '/role-selection'),
                _buildMenuItem(Icons.settings_outlined, 'Settings', AppColors.purpleGradient, '/settings'),
                _buildMenuItem(Icons.info_outline_rounded, 'About', AppColors.tealGradient, '/about'),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  ),
                  title: Text(
                    'Logout',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AuthProvider>().logout();
                    Navigator.pushReplacementNamed(context, '/role-selection');
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, LinearGradient gradient, String route) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final historyProvider = context.watch<EmotionHistoryProvider>();
    final recentEmotions =
        historyProvider.recentHistory.map((e) => e.emotion).toList();

    // Check user role and redirect if needed
    final auth = context.read<AuthProvider>();
    if (auth.isChild) {
      return const ChildDashboardPage();
    }

    return Scaffold(
      body: AuroraBackground(
        colors: _lastEmotion != null
            ? [
                EmotionTheme.color(_lastEmotion!).withValues(alpha: 0.15),
                EmotionTheme.color(_lastEmotion!).withValues(alpha: 0.08),
                AppColors.secondary.withValues(alpha: 0.05),
              ]
            : null,
        child: SafeArea(
          child: Column(
            children: [
              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(gameProvider),
                      const SizedBox(height: 24),
                      _buildEmotionHero(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      if (recentEmotions.isNotEmpty)
                        _buildMoodHistory(recentEmotions),
                      if (recentEmotions.isNotEmpty) const SizedBox(height: 24),
                      _buildFeatureCards(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom Nav
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Top Bar ──────────────────────────────────────────────
  Widget _buildTopBar(GameProvider gameProvider) {
    return FadeInDown(
      duration: AppAnimations.normal,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()} ${_getGreetingEmoji()}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    'A.A.K.A.R',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          StreakBadge(streak: gameProvider.dailyStreak),
          const SizedBox(width: 8),
          XPProgressBar(
            currentXP: gameProvider.totalXP,
            maxXP: gameProvider.level * 100,
            level: gameProvider.level,
          ),
        ],
      ),
    );
  }

  // ─── Emotion Hero Section ─────────────────────────────────
  Widget _buildEmotionHero() {
    if (_lastEmotion != null) {
      return _buildDetectedEmotionCard();
    }
    return _buildNoEmotionCard();
  }

  Widget _buildNoEmotionCard() {
    return FadeInUp(
      duration: AppAnimations.normal,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/detect'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surface,
                AppColors.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            children: [
              const EmotionAvatar(
                emotion: 'neutral',
                size: 100,
                animate: true,
              ),
              const SizedBox(height: 24),
              Text(
                "Let's check how you're feeling",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to detect your emotion with AI',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Detect Emotion',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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

  Widget _buildDetectedEmotionCard() {
    final emotionColor = EmotionTheme.color(_lastEmotion!);
    final confidence = ((_lastConfidence ?? 0) * 100).toStringAsFixed(0);

    return FadeInUp(
      duration: AppAnimations.normal,
      child: GlowingEmotionCard(
        emotion: _lastEmotion!,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                EmotionAvatar(
                  emotion: _lastEmotion!,
                  size: 64,
                  animate: true,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You're feeling ${_lastEmotion!.toLowerCase()}",
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: emotionColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$confidence% confident',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: emotionColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Emotion explanation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                EmotionTheme.explanation(_lastEmotion!),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Quick sub-actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSmallAction('🔄', 'Redetect', () {
                  Navigator.pushNamed(context, '/detect');
                }),
                _buildSmallAction('📓', 'Journal', () {}),
                _buildSmallAction('📊', 'Insights', () {
                  Navigator.pushNamed(context, '/analytics');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallAction(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick Actions ────────────────────────────────────────
  Widget _buildQuickActions() {
    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionButton(
            emoji: '🧘',
            label: 'Calm',
            color: const Color(0xFF6366F1),
            onTap: () => Navigator.pushNamed(context, '/calm-mode'),
          ),
          QuickActionButton(
            emoji: '💬',
            label: 'Talk',
            color: const Color(0xFF14B8A6),
            onTap: () => Navigator.pushNamed(context, '/chatbot'),
          ),
          QuickActionButton(
            emoji: '🎮',
            label: 'Play',
            color: const Color(0xFFF87171),
            onTap: () => Navigator.pushNamed(context, '/game-menu'),
          ),
          QuickActionButton(
            emoji: '📊',
            label: 'Insights',
            color: const Color(0xFFFBBF24),
            onTap: () => Navigator.pushNamed(context, '/analytics'),
          ),
        ],
      ),
    );
  }

  // ─── Mood History ─────────────────────────────────────────
  Widget _buildMoodHistory(List<String> recentEmotions) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Recent Moods',
              trailing: 'See All',
              onTrailingTap: () => Navigator.pushNamed(context, '/analytics'),
            ),
            const SizedBox(height: 8),
            Center(child: MoodDotTimeline(emotions: recentEmotions)),
          ],
        ),
      ),
    );
  }

  // ─── Feature Cards ────────────────────────────────────────
  Widget _buildFeatureCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Explore'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                '🎭',
                'Emotion\nDetection',
                'AI-powered face reading',
                AppColors.warmGradient,
                () => Navigator.pushNamed(context, '/detect'),
                200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                '🎮',
                'Learning\nGames',
                'Play & earn XP',
                AppColors.mintGradient,
                () => Navigator.pushNamed(context, '/game-menu'),
                300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                '🧘',
                'Calm\nTools',
                'Breathe & relax',
                AppColors.calmGradient,
                () => Navigator.pushNamed(context, '/calm-mode'),
                400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                '💬',
                'AI\nCompanion',
                'Talk about feelings',
                AppColors.tealGradient,
                () => Navigator.pushNamed(context, '/chatbot'),
                500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String emoji, String title, String subtitle,
      LinearGradient gradient, VoidCallback onTap, int delayMs) {
    return FadeInUp(
      delay: Duration(milliseconds: delayMs),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, 'Home', 0),
          _buildNavItem(Icons.camera_alt_rounded, 'Detect', 1),
          _buildNavItem(Icons.games_rounded, 'Games', 2),
          _buildNavItem(Icons.chat_bubble_rounded, 'Chat', 3),
          _buildNavItem(Icons.more_horiz_rounded, 'More', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = index == _navIndex;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
