import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../shared/emotions.dart';
import '../widgets/aakar_widgets.dart';

/// 🎉 Results Page - Enhanced celebration screen with premium design
class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _pulseController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow, // Using theme constant
    )..repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final conf = (args?['finalConf'] as double?) ?? 0.85;
      if (conf > 0.7) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Using EmotionTheme.explanation(emotion) would be better if it returned this map structure.
  // For now, I'll keep the logic here but styling it better.
  Map<String, String> _getEmotionExplanation(String emotion) {
      // ... (keeping content logic same for now, or could move to emotion_theme if desired)
      // For simplicity in this redesign, I'll rely on the existing map content logic but styled better.
      switch (emotion.toLowerCase()) {
      case 'happy':
        return {
          'title': 'Signs of happiness detected:',
          'cues': '• Raised cheeks\n• Upturned mouth corners\n• Relaxed eye area\n• Crow\'s feet wrinkles',
        };
      case 'sad':
        return {
          'title': 'Signs of sadness detected:',
          'cues': '• Downturned mouth\n• Inner eyebrows raised\n• Lower eyelids appear droopy\n• Reduced facial muscle tone',
        };
      case 'angry':
        return {
          'title': 'Signs of anger detected:',
          'cues': '• Lowered eyebrows\n• Tense jaw\n• Pressed lips\n• Intense eye gaze',
        };
      case 'surprise':
        return {
          'title': 'Signs of surprise detected:',
          'cues': '• Raised eyebrows\n• Widened eyes\n• Open mouth\n• Exposed white of eyes',
        };
      case 'fear':
        return {
          'title': 'Signs of fear detected:',
          'cues': '• Raised upper eyelids\n• Tensed lower eyelids\n• Parted lips\n• Eyebrows pulled together',
        };
      case 'disgust':
        return {
          'title': 'Signs of disgust detected:',
          'cues': '• Wrinkled nose\n• Raised upper lip\n• Lowered eyebrows\n• Narrowed eyes',
        };
      case 'neutral':
        return {
          'title': 'Neutral expression detected:',
          'cues': '• Relaxed facial muscles\n• Natural mouth position\n• Even eyebrow placement\n• Calm overall appearance',
        };
      default:
        return {
          'title': 'Expression analysis:',
          'cues': '• Facial features analyzed\n• Micro-expressions detected\n• Emotional patterns identified',
        };
    }
  }

  List<Map<String, dynamic>> _getSuggestedActions(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return [
          {'emoji': '🎮', 'label': 'Play Games', 'route': '/game-menu'},
          {'emoji': '💬', 'label': 'Chat', 'route': '/chatbot'},
        ];
      case 'sad':
        return [
          {'emoji': '🧘', 'label': 'Calm Down', 'route': '/calm-mode'},
          {'emoji': '💬', 'label': 'Talk to AI', 'route': '/chatbot'},
        ];
      case 'angry':
        return [
          {'emoji': '🌬️', 'label': 'Breathe', 'route': '/calm-mode'},
          {'emoji': '💬', 'label': 'Express', 'route': '/chatbot'},
        ];
      default:
        return [
          {'emoji': '🎮', 'label': 'Play', 'route': '/game-menu'},
          {'emoji': '💬', 'label': 'Chat', 'route': '/chatbot'},
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final label = (args?['finalLabel'] as String?) ?? 'Happy';
    final conf = (args?['finalConf'] as double?) ?? 0.85;
    final emoji = EmotionTheme.emoji(label); // Use EmotionTheme
    final themeColor = EmotionTheme.color(label);
    
    final isHighConfidence = conf > 0.7;
    final explanation = _getEmotionExplanation(label);
    final actions = _getSuggestedActions(label);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background,
                  themeColor.withValues(alpha: 0.2),
                  AppColors.background,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Aurora Effect
          const Positioned.fill(
             child: Opacity(opacity: 0.3, child: AuroraBackground(child: const SizedBox.shrink())),
          ),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 🔙 Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 20),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 🏆 Title
                  FadeInDown(
                    child: Text(
                      isHighConfidence ? '🎉 Amazing!' : '✨ Great Job!',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 😊 HUGE Emoji with animated glow
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                themeColor.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                              radius: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.2 + 0.1 * _pulseController.value),
                                blurRadius: 40 + 20 * _pulseController.value,
                                spreadRadius: 10 + 5 * _pulseController.value,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(emoji, style: const TextStyle(fontSize: 80)),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 📝 Emotion Label
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'You look $label!',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 📊 Confidence Card
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Confidence',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: themeColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '${(conf * 100).toStringAsFixed(0)}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: themeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: conf),
                                duration: AppAnimations.normal,
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    backgroundColor: AppColors.surfaceLight,
                                    valueColor: AlwaysStoppedAnimation(themeColor),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 💡 Explanation Card
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 10),
                              Text(
                                explanation['title']!,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            explanation['cues']!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 🎯 Suggested Actions
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What would you like to do?',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ...actions.map((action) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: action != actions.last ? 12 : 0,
                                ),
                                child: _buildActionButton(
                                  action['emoji'] as String,
                                  action['label'] as String,
                                  () => Navigator.pushNamed(context, action['route'] as String),
                                ),
                              ),
                            )),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton('🔄', 'Try Again', () {
                                Navigator.pop(context);
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 🏠 Home Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: TextButton.icon(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/', (r) => false),
                      icon: const Icon(Icons.home_rounded, color: AppColors.textSecondary),
                      label: Text(
                        'Back to Home',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // 🎊 Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                AppColors.primary,
                AppColors.secondary,
                AppColors.gold,
                AppColors.pink,
                AppColors.teal,
              ],
              numberOfParticles: 30,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
