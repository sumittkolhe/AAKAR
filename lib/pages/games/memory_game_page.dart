import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';

import '../../theme.dart';
import '../../providers/game_provider.dart';
import '../../models/game_score.dart';
import '../../widgets/aakar_widgets.dart';

enum MemoryDifficulty { easy, medium, hard }

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  // 3 Difficulty Levels
  MemoryDifficulty _difficulty = MemoryDifficulty.easy;

  // Emotion Pools
  final List<String> _basicEmotions = [
    'Happy', 'Sad', 'Angry', 'Fear', 'Surprise', 'Disgust'
  ];

  final List<String> _socialEmotions = [
    'Proud', 'Shy', 'Excited', 'Bored', 'Confused', 'Nervous', 'Contempt', 'Neutral'
  ];

  // Game State
  late List<String> _cards;
  late List<bool> _cardFlips;
  late List<bool> _cardMatches;
  int? _firstCardIndex;
  bool _isChecking = false;
  int _moves = 0;
  int _pairsFound = 0;
  late Timer _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startNewGame([MemoryDifficulty? difficulty]) {
    if (difficulty != null) {
      _difficulty = difficulty;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
    // This will restart existing timer if called multiple times, so cancel first
    // Actually we should separate init logic.
  }
  
  void _resetGameLogic() {
       if (mounted && (_timer.isActive)) {
      _timer.cancel();
    }

    // Determine Number of Pairs
    int numPairs;
    int crossAxisCount;
    List<String> pool;

    switch (_difficulty) {
      case MemoryDifficulty.easy:
        numPairs = 6; // 12 cards (3x4)
        crossAxisCount = 3;
        pool = [..._basicEmotions];
        break;
      case MemoryDifficulty.medium:
        numPairs = 8; // 16 cards (4x4)
        crossAxisCount = 4;
        pool = [..._basicEmotions, ..._socialEmotions];
        break;
      case MemoryDifficulty.hard:
        numPairs = 10; // 20 cards (4x5)
        crossAxisCount = 4;
        pool = [..._basicEmotions, ..._socialEmotions];
        break;
    }

    // Randomly select 'numPairs' distinct emotions
    pool.shuffle();
    // take top N unique
    // use a set to ensure uniqueness if logic allows, but pool is unique strings
    // Just take sublist
    if (pool.length < numPairs) {
      // Fallback if pool is too small (shouldn't happen with current lists)
      // Duplicate some if needed or just use all
      pool = [...pool, ..._basicEmotions]; // dumb fallback
    }
    
    final selectedEmotions = pool.take(numPairs).toList();

    // duplicate for pairs
    _cards = [...selectedEmotions, ...selectedEmotions];
    _cards.shuffle();

    _cardFlips = List.generate(_cards.length, (index) => false);
    _cardMatches = List.generate(_cards.length, (index) => false);
    _firstCardIndex = null;
    _isChecking = false;
    _moves = 0;
    _pairsFound = 0;
    _secondsElapsed = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });

    // Briefly show cards at start
    setState(() {
      _cardFlips = List.generate(_cards.length, (index) => true);
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _cardFlips = List.generate(_cards.length, (index) => false);
        });
      }
    }); 
  }

  // Renamed to avoid confusion with the initial State call
  void _initGame() {
      _resetGameLogic();
  }

  void _onCardTap(int index) {
    if (_isChecking || _cardFlips[index] || _cardMatches[index]) return;

    setState(() {
      _cardFlips[index] = true;
    });

    if (_firstCardIndex == null) {
      _firstCardIndex = index;
    } else {
      _moves++;
      _isChecking = true;
      final firstIndex = _firstCardIndex!;
      
      if (_cards[firstIndex] == _cards[index]) {
        // Match found
        _cardMatches[firstIndex] = true;
        _cardMatches[index] = true;
        _pairsFound++;
        _firstCardIndex = null;
        _isChecking = false;

        if (_pairsFound == (_cards.length ~/ 2)) {
          _timer.cancel();
          Future.delayed(const Duration(milliseconds: 500), _showResults);
        }
      } else {
        // No match
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _cardFlips[firstIndex] = false;
              _cardFlips[index] = false;
              _firstCardIndex = null;
              _isChecking = false;
            });
          }
        });
      }
    }
  }

  void _showResults() {
    final gameProvider = context.read<GameProvider>();
    
    int numPairs = _cards.length ~/ 2;
    int optimalMoves = numPairs; // Perfect game
    
    // Scoring logic
    // penalties
    int timePenalty = _secondsElapsed * 1;
    int movePenalty = (_moves - optimalMoves) * 5;
    
    int baseScore = 1000;
    if (_difficulty == MemoryDifficulty.medium) baseScore = 1500;
    if (_difficulty == MemoryDifficulty.hard) baseScore = 2000;

    int finalScore = max(100, baseScore - timePenalty - movePenalty);
    int xpEarned = (finalScore / 10).round();

    final score = GameScore(
      id: const Uuid().v4(),
      gameType: 'memory_match',
      score: finalScore,
      totalQuestions: numPairs,
      correctAnswers: _pairsFound,
      xpEarned: xpEarned,
      timestamp: DateTime.now(),
      difficulty: _difficulty.name,
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
              const Text('🎉', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                'Memory Master!',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Difficulty: ${_difficulty.name.toUpperCase()}\nTime: ${_formatTime(_secondsElapsed)}\nMoves: $_moves',
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
                      label: 'Play Again',
                      gradient: AppColors.primaryGradient,
                      onPressed: () {
                        Navigator.pop(context);
                        _initGame();
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

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _changeDifficulty(MemoryDifficulty newDiff) {
    if (_difficulty == newDiff) return;
    setState(() {
      _difficulty = newDiff;
    });
    _initGame();
  }

  @override
  Widget build(BuildContext context) {
    // Determine crossAxisCount based on difficulty
    int crossAxisCount = 3;
    if (_difficulty == MemoryDifficulty.medium || _difficulty == MemoryDifficulty.hard) {
      crossAxisCount = 4;
    }

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
          'Memory Match 🧠',
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
              _formatTime(_secondsElapsed),
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
          child: Column(
            children: [
               const SizedBox(height: 10),
               
               // Difficulty Selector
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   _buildDiffChip(MemoryDifficulty.easy, 'Easy'),
                   const SizedBox(width: 8),
                   _buildDiffChip(MemoryDifficulty.medium, 'Medium'),
                   const SizedBox(width: 8),
                   _buildDiffChip(MemoryDifficulty.hard, 'Hard'),
                 ],
               ),

              const SizedBox(height: 16),

              // Game Info
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Moves: $_moves',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Pairs: $_pairsFound/${_cards.length ~/ 2}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                       ),
               ),
              const SizedBox(height: 16),

              // Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      return _buildCard(index);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiffChip(MemoryDifficulty level, String label) {
    final isSelected = _difficulty == level;
    return GestureDetector(
      onTap: () => _changeDifficulty(level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final isFlipped = _cardFlips[index] || _cardMatches[index];
    final emotion = _cards[index];
    final color = EmotionTheme.color(emotion);

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isFlipped ? AppColors.surface : AppColors.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isFlipped ? color : AppColors.glassBorder,
            width: 2,
          ),
          boxShadow: [
            if (isFlipped)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ],
        ),
        child: isFlipped
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      EmotionTheme.emoji(emotion),
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 2),
                     FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          emotion,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Text(
                  '?',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
      ),
    );
  }
}
