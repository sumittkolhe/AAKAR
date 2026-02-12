import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import '../../theme.dart';
import '../../providers/game_provider.dart';
import '../../models/game_score.dart';
import '../../models/scenario_question.dart';
import '../../widgets/aakar_widgets.dart';
import '../../data/scenario_data.dart';

class ScenarioGamePage extends StatefulWidget {
  const ScenarioGamePage({super.key});

  @override
  State<ScenarioGamePage> createState() => _ScenarioGamePageState();
}

class _ScenarioGamePageState extends State<ScenarioGamePage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  String? _selectedOption;
  String? _feedbackMessage;

  // Dynamic Questions
  late List<ScenarioQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    // Select 5 random questions from the large pool
    final allQuestions = [...ScenarioData.allQuestions];
    allQuestions.shuffle();
    _questions = allQuestions.take(5).toList();
    
    // Also shuffle options for each question to ensure variety
    for (var q in _questions) {
      q.options.shuffle();
    }
  }

  void _checkAnswer(String option) {
    setState(() {
      _selectedOption = option;
      _answered = true;
      final correct = option == _questions[_currentQuestionIndex].emotion;
      if (correct) {
        _score++;
        _feedbackMessage = "Correct! ${_questions[_currentQuestionIndex].explanation}";
      } else {
        _feedbackMessage = "Not quite. ${_questions[_currentQuestionIndex].explanation}";
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedOption = null;
        _feedbackMessage = null;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final gameProvider = context.read<GameProvider>();
    final int xpEarned = _score * 15; // 15 XP per correct answer

    final gameScore = GameScore(
      id: const Uuid().v4(),
      gameType: 'scenario_quiz',
      score: _score * 100,
      totalQuestions: _questions.length,
      correctAnswers: _score,
      xpEarned: xpEarned,
      timestamp: DateTime.now(),
      difficulty: 'easy',
    );

    gameProvider.addScore(gameScore);

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
                _score >= 4 ? '🌟' : _score >= 3 ? '👍' : '📚',
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              Text(
                'Quiz Complete!',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You got $_score out of ${_questions.length} correct!',
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
                      label: 'Retry',
                      gradient: AppColors.primaryGradient,
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _loadQuestions(); // Load new set of questions
                          _currentQuestionIndex = 0;
                          _score = 0;
                          _answered = false;
                          _selectedOption = null;
                          _feedbackMessage = null;
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
    final question = _questions[_currentQuestionIndex];

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
          'Scenario Quiz 📖',
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
              '${_currentQuestionIndex + 1}/${_questions.length}',
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 32),

                // Scenario Card
                Expanded(
                  flex: 3,
                  child: FadeInDown(
                    key: ValueKey(_currentQuestionIndex),
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book_rounded,
                              size: 48, color: AppColors.secondary),
                          const SizedBox(height: 20),
                          Text(
                            question.scenario,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Options
                Expanded(
                  flex: 4,
                  child: Column(
                    children: question.options.map((option) {
                      final isSelected = _selectedOption == option;
                      final isCorrect = option == question.emotion;
                      
                      Color? btnColor;
                      if (_answered) {
                        if (isCorrect) {
                          btnColor = Colors.green;
                        } else if (isSelected) {
                          btnColor = Colors.red;
                        }
                      }

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FadeInUp(
                            child: GestureDetector(
                              onTap: _answered ? null : () => _checkAnswer(option),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: btnColor?.withValues(alpha: 0.2) ?? AppColors.surface,
                                  border: Border.all(
                                    color: btnColor ?? AppColors.glassBorder,
                                    width: isSelected || (_answered && isCorrect) ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.card),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      EmotionTheme.emoji(option),
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      option,
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (_answered && isCorrect)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(Icons.check_circle, color: Colors.green),
                                      ),
                                     if (_answered && isSelected && !isCorrect)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(Icons.cancel, color: Colors.red),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Feedback & Next Button
                if (_answered)
                  FadeInUp(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Text(
                            _feedbackMessage ?? '',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          label: _currentQuestionIndex < _questions.length - 1
                              ? 'Next Question'
                              : 'Finish Quiz',
                          onPressed: _nextQuestion,
                        ),
                      ],
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
