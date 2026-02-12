import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// 🎨 Animated Emotion Chip - Tappable with scale and glow effects
class AnimatedEmotionChip extends StatefulWidget {
  final String emoji;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const AnimatedEmotionChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<AnimatedEmotionChip> createState() => _AnimatedEmotionChipState();
}

class _AnimatedEmotionChipState extends State<AnimatedEmotionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.color.withOpacity(0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.color
                      : AppColors.glassBorder,
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (widget.isSelected || _glowAnimation.value > 0)
                    BoxShadow(
                      color: widget.color.withOpacity(
                        0.3 * (widget.isSelected ? 1 : _glowAnimation.value),
                      ),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected
                          ? widget.color
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 🎯 Emotion suggestion data
class EmotionSuggestion {
  final String emotion;
  final String emoji;
  final Color color;
  final String message;
  final String actionLabel;
  final String route;
  final IconData icon;

  const EmotionSuggestion({
    required this.emotion,
    required this.emoji,
    required this.color,
    required this.message,
    required this.actionLabel,
    required this.route,
    required this.icon,
  });

  static const Map<String, EmotionSuggestion> suggestions = {
    'Happy': EmotionSuggestion(
      emotion: 'Happy',
      emoji: '😊',
      color: Color(0xFF4CAF50),
      message: "You're feeling great! Let's keep the fun going!",
      actionLabel: 'Play a Game',
      route: '/game-menu',
      icon: Icons.sports_esports,
    ),
    'Sad': EmotionSuggestion(
      emotion: 'Sad',
      emoji: '😢',
      color: Color(0xFF2196F3),
      message: "It's okay to feel sad. Let's do something calming.",
      actionLabel: 'Calm Activities',
      route: '/calm-mode',
      icon: Icons.spa,
    ),
    'Angry': EmotionSuggestion(
      emotion: 'Angry',
      emoji: '😠',
      color: Color(0xFFF44336),
      message: "Take a deep breath. Let's calm down together.",
      actionLabel: 'Breathing Exercise',
      route: '/calm-mode',
      icon: Icons.air,
    ),
    'Calm': EmotionSuggestion(
      emotion: 'Calm',
      emoji: '😌',
      color: Color(0xFF00BCD4),
      message: "You're feeling peaceful. Perfect time to learn!",
      actionLabel: 'Learn Emotions',
      route: '/face-game',
      icon: Icons.psychology,
    ),
    'Neutral': EmotionSuggestion(
      emotion: 'Neutral',
      emoji: '😐',
      color: Color(0xFF9E9E9E),
      message: "How about we chat or play a game?",
      actionLabel: 'Chat with AI',
      route: '/chatbot',
      icon: Icons.chat_bubble_outline,
    ),
  };
}
