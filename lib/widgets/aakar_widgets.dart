import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../theme.dart';

// ─────────────────────────────────────────────────────────────
// 🔮 Glowing Emotion Card — card with animated emotion glow
// ─────────────────────────────────────────────────────────────

class GlowingEmotionCard extends StatefulWidget {
  final String emotion;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlowingEmotionCard({
    super.key,
    required this.emotion,
    required this.child,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  State<GlowingEmotionCard> createState() => _GlowingEmotionCardState();
}

class _GlowingEmotionCardState extends State<GlowingEmotionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emotionColor = EmotionTheme.color(widget.emotion);
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: emotionColor.withValues(alpha: _glowAnimation.value * 0.4),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: emotionColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 📊 XP Progress Bar
// ─────────────────────────────────────────────────────────────

class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int maxXP;
  final int level;

  const XPProgressBar({
    super.key,
    required this.currentXP,
    required this.maxXP,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxXP > 0 ? (currentXP % 100) / 100.0 : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$level',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$currentXP XP',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.gold,
                    ),
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

// ─────────────────────────────────────────────────────────────
// 🔥 Streak Badge
// ─────────────────────────────────────────────────────────────

class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: streak > 0
            ? const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              )
            : null,
        color: streak > 0 ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: streak > 0 ? null : Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(streak > 0 ? '🔥' : '💤', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: streak > 0 ? Colors.white : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ⭕ Emotion Orb — animated glowing emotion indicator
// ─────────────────────────────────────────────────────────────

class EmotionOrb extends StatefulWidget {
  final String? emotion;
  final double size;

  const EmotionOrb({super.key, this.emotion, this.size = 120});

  @override
  State<EmotionOrb> createState() => _EmotionOrbState();
}

class _EmotionOrbState extends State<EmotionOrb>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.emotion != null
        ? EmotionTheme.color(widget.emotion!)
        : AppColors.primary;
    final gradient = widget.emotion != null
        ? EmotionTheme.gradient(widget.emotion!)
        : AppColors.primaryGradient;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.emotion != null
                        ? EmotionTheme.emoji(widget.emotion!)
                        : '🧠',
                    style: TextStyle(fontSize: widget.size * 0.4),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PulseCircle extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseCircle({
    required this.color,
    required this.size,
  });

  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.2),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🔘 Quick Action Button
// ─────────────────────────────────────────────────────────────

class QuickActionButton extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const QuickActionButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: (widget.color ?? AppColors.primary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: (widget.color ?? AppColors.primary).withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(widget.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🌊 Animated Counter
// ─────────────────────────────────────────────────────────────

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: AppAnimations.slow,
      builder: (context, val, child) {
        return Text(
          '$val${suffix ?? ''}',
          style: style ??
              GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 📊 Mood Dot Timeline — mini history indicator
// ─────────────────────────────────────────────────────────────

class MoodDotTimeline extends StatelessWidget {
  final List<String> emotions;

  const MoodDotTimeline({super.key, required this.emotions});

  @override
  Widget build(BuildContext context) {
    final display = emotions.length > 7 ? emotions.sublist(emotions.length - 7) : emotions;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < display.length; i++) ...[
          if (i > 0)
            Container(
              width: 12,
              height: 2,
              color: AppColors.surfaceLight,
            ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + i * 100),
            builder: (context, val, child) {
              return Transform.scale(
                scale: val,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EmotionTheme.color(display[i]),
                    boxShadow: [
                      BoxShadow(
                        color: EmotionTheme.color(display[i]).withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      EmotionTheme.emoji(display[i]),
                      style: const TextStyle(fontSize: 8),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
