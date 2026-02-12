import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/role_provider.dart';
import '../../widgets/aakar_widgets.dart';

/// 🚀 Onboarding — 4-step animated flow with aurora background
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedRole = '';
  final Set<String> _selectedGoals = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: AppAnimations.normal,
        curve: AppAnimations.defaultCurve,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final onboarding = context.read<OnboardingProvider>();
    if (_selectedRole.isNotEmpty) {
      await onboarding.setRole(_selectedRole);
      context.read<RoleProvider>().setRole(_selectedRole);
    }
    if (_selectedGoals.isNotEmpty) {
      await onboarding.setGoals(_selectedGoals.toList());
    }
    await onboarding.completeOnboarding();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        colors: [
          AppColors.primary.withValues(alpha: 0.12),
          AppColors.secondary.withValues(alpha: 0.08),
          AppColors.teal.withValues(alpha: 0.06),
        ],
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _currentPage < 3
                      ? TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : const SizedBox(height: 48),
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWelcomePage(),
                    _buildRolePage(),
                    _buildExplainPage(),
                    _buildGoalsPage(),
                  ],
                ),
              ),

              // Dot indicators with gradient fill
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final isActive = i == _currentPage;
                    final isPast = i < _currentPage;
                    return AnimatedContainer(
                      duration: AppAnimations.normal,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: isActive ? AppColors.primaryGradient : null,
                        color: isActive
                            ? null
                            : isPast
                                ? AppColors.primary.withValues(alpha: 0.4)
                                : AppColors.surfaceLight,
                      ),
                    );
                  }),
                ),
              ),

              // Next button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: _currentPage == 3
                    ? PulseButton(
                        label: "Let's Go! 🚀",
                        onPressed: _nextPage,
                        gradient: AppColors.primaryGradient,
                      )
                    : GradientButton(
                        label: 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _nextPage,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Step 1: Welcome to A.A.K.A.R ──────────────────────────
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: AppAnimations.slow,
            child: const EmotionAvatar(
              emotion: 'happy',
              size: 140,
              animate: true,
            ),
          ),
          const SizedBox(height: 48),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Welcome to',
              style: GoogleFonts.inter(
                fontSize: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.primaryGradient.createShader(bounds),
              child: Text(
                'A.A.K.A.R',
                style: GoogleFonts.outfit(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                'AI-Based Assistive Kit for Autism Rehabilitation',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: Text(
              'Learning Emotions Together 🌈',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 2: Choose Role ──────────────────────────────────
  Widget _buildRolePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          FadeInDown(
            child: Text(
              "Who's using the app?",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Choose your role to personalize the experience',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildRoleCard('🧒', 'Child', 'Play games & learn emotions!',
              AppColors.warmGradient, 'child', 200),
          const SizedBox(height: 16),
          _buildRoleCard('👨‍👩‍👧', 'Parent', 'Track progress & get insights',
              AppColors.mintGradient, 'parent', 300),
          const SizedBox(height: 16),
          _buildRoleCard('👩‍🏫', 'Therapist', 'Monitor & manage sessions',
              AppColors.purpleGradient, 'therapist', 400),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRoleCard(String emoji, String title, String subtitle,
      LinearGradient gradient, String role, int delayMs) {
    final isSelected = _selectedRole == role;
    return FadeInUp(
      delay: Duration(milliseconds: delayMs),
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isSelected ? gradient : null,
            color: isSelected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: isSelected
                ? null
                : Border.all(color: AppColors.glassBorder),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.85)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: AppAnimations.normal,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white
                      : AppColors.surfaceLight,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : AppColors.glassBorder,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check_rounded,
                        size: 16,
                        color: gradient.colors.first)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Step 3: How It Works ─────────────────────────────────
  Widget _buildExplainPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          FadeInDown(
            child: Text(
              'How It Works',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Five powerful tools in one app',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildFeatureRow(Icons.camera_alt_rounded, '🎭 Detect Emotions',
              'AI reads your expressions to understand how you feel',
              AppColors.warmGradient, 200),
          const SizedBox(height: 20),
          _buildFeatureRow(Icons.chat_bubble_outline_rounded,
              '💬 Talk to AI', 'A friendly companion that adapts to your mood',
              AppColors.purpleGradient, 300),
          const SizedBox(height: 20),
          _buildFeatureRow(Icons.games_rounded, '🎮 Play & Learn',
              'Fun emotion games that build emotional intelligence',
              AppColors.mintGradient, 400),
          const SizedBox(height: 20),
          _buildFeatureRow(Icons.self_improvement_rounded, '🧘 Stay Calm',
              'Breathing exercises and calming tools',
              AppColors.calmGradient, 500),
          const SizedBox(height: 20),
          _buildFeatureRow(Icons.insights_rounded, '📊 Track Progress',
              'Beautiful insights on your emotional growth',
              AppColors.tealGradient, 600),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
      IconData icon, String title, String description, LinearGradient gradient, int delayMs) {
    return FadeInLeft(
      delay: Duration(milliseconds: delayMs),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 4: Set Goals ────────────────────────────────────
  Widget _buildGoalsPage() {
    final goals = [
      ('🎭', 'Learn Emotions', 'learn_emotions'),
      ('🧘', 'Improve Calmness', 'improve_calmness'),
      ('📊', 'Track My Mood', 'track_mood'),
      ('🎮', 'Play Games', 'play_games'),
      ('💬', 'Practice Communication', 'communication'),
      ('🌟', 'Build Confidence', 'confidence'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          FadeInDown(
            child: Text(
              'What are your goals?',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Select all that apply — you can change these later',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: goals.asMap().entries.map((entry) {
              final (emoji, label, id) = entry.value;
              final isSelected = _selectedGoals.contains(id);
              return FadeInUp(
                delay: Duration(milliseconds: 200 + entry.key * 80),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGoals.remove(id);
                      } else {
                        _selectedGoals.add(id);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: AppAnimations.normal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? AppColors.primaryGradient
                          : null,
                      color: isSelected ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.glassBorder),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded,
                              size: 16, color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
