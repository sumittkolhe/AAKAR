import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../theme.dart';
import '../../providers/game_provider.dart';
import '../../models/game_score.dart';
import '../../widgets/aakar_widgets.dart';
import 'package:uuid/uuid.dart';

class FaceEmotionGame extends StatefulWidget {
  const FaceEmotionGame({super.key});

  @override
  State<FaceEmotionGame> createState() => _FaceEmotionGameState();
}

class _FaceEmotionGameState extends State<FaceEmotionGame> {
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  final int _totalQuestions = 5;
  String? _selectedAnswer;
  bool _answered = false;
  String _currentEmotion = '';
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    // Use emotions from EmotionTheme to ensure consistency
    final allEmotions = ['Happy', 'Sad', 'Angry', 'Fear', 'Surprise', 'Neutral'];
    _currentEmotion = allEmotions[random.nextInt(allEmotions.length)];
    
    // Generate 4 options including correct answer
    _options = [_currentEmotion];
    while (_options.length < 4) {
      final option = allEmotions[random.nextInt(allEmotions.length)];
      if (!_options.contains(option)) {
        _options.add(option);
      }
    }
    _options.shuffle();
  }

  void _checkAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == _currentEmotion) {
        _correctAnswers++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (_currentQuestion + 1 < _totalQuestions) {
          setState(() {
            _currentQuestion++;
            _answered = false;
            _selectedAnswer = null;
            _generateQuestion();
          });
        } else {
          _showResults();
        }
      }
    });
  }

  void _showResults() {
    final gameProvider = context.read<GameProvider>();
    final xpEarned = _correctAnswers * 20;
    final score = GameScore(
      id: const Uuid().v4(),
      gameType: 'face_emotion',
      score: _correctAnswers * 100,
      totalQuestions: _totalQuestions,
      correctAnswers: _correctAnswers,
      xpEarned: xpEarned,
      timestamp: DateTime.now(),
      difficulty: 'easy',
    );
    
    gameProvider.addScore(score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _correctAnswers >= 4 ? '🎉' : _correctAnswers >= 2 ? '👍' : '💪',
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              Text(
                _correctAnswers >= 4 ? 'Amazing!' : _correctAnswers >= 2 ? 'Good Job!' : 'Keep Trying!',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You got $_correctAnswers out of $_totalQuestions correct!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      '+$xpEarned XP',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Back to menu
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Back to Menu',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GradientButton(
                      label: 'Play Again',
                      gradient: AppColors.primaryGradient,
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _currentQuestion = 0;
                          _correctAnswers = 0;
                          _answered = false;
                          _selectedAnswer = null;
                          _generateQuestion();
                        });
                      },
                    ),
                  ),
                ],
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
          'Face Emotion Game',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(
              '${_currentQuestion + 1}/$_totalQuestions',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Progress bar
                FadeInDown(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: (_currentQuestion + 1) / _totalQuestions,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Question Area
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      FadeIn(
                        child: Text(
                          'Which emotion is this?',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Emoji Display
                      ZoomIn(
                        key: ValueKey(_currentQuestion), // Animate on change
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                EmotionTheme.color(_currentEmotion).withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                              radius: 0.7,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              EmotionTheme.emoji(_currentEmotion),
                              style: const TextStyle(fontSize: 100),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Options Grid
                Expanded(
                  flex: 5,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: _options.length,
                    itemBuilder: (context, index) {
                      final option = _options[index];
                      final isCorrect = option == _currentEmotion;
                      final isSelected = option == _selectedAnswer;
                      
                      Color? backgroundColor;
                      Color? borderColor;
                      
                      if (_answered) {
                        if (isCorrect) {
                          backgroundColor = const Color(0xFF4CAF50).withValues(alpha: 0.2);
                          borderColor = const Color(0xFF4CAF50);
                        } else if (isSelected) {
                          backgroundColor = const Color(0xFFF44336).withValues(alpha: 0.2);
                          borderColor = const Color(0xFFF44336);
                        } else {
                          backgroundColor = AppColors.surfaceLight;
                          borderColor = Colors.transparent;
                        }
                      } else {
                        backgroundColor = AppColors.surface;
                        borderColor = AppColors.glassBorder;
                      }

                      return BounceInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: GestureDetector(
                          onTap: _answered ? null : () => _checkAnswer(option),
                          child: AnimatedContainer(
                            duration: AppAnimations.fast,
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(
                                color: borderColor ?? Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                if (!_answered)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  EmotionTheme.emoji(option),
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  option,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
