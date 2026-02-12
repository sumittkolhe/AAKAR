import 'package:flutter/foundation.dart';
import '../models/game_score.dart';

class GameProvider with ChangeNotifier {
  int _totalXP = 0;
  int _dailyStreak = 0;
  List<GameScore> _scores = [];
  List<Badge> _badges = [];
  DateTime? _lastPlayedDate;

  int get totalXP => _totalXP;
  int get dailyStreak => _dailyStreak;
  List<GameScore> get scores => List.unmodifiable(_scores);
  List<Badge> get badges => List.unmodifiable(_badges);
  int get level => (_totalXP / 100).floor() + 1;
  int get xpForNextLevel => (level * 100) - _totalXP;

  void addScore(GameScore score) {
    _scores.add(score);
    _totalXP += score.xpEarned;
    _updateDailyStreak();
    _checkBadgeUnlocks();
    notifyListeners();
  }

  void addXP(int amount) {
    _totalXP += amount;
    _updateDailyStreak();
    _checkBadgeUnlocks();
    notifyListeners();
  }



  void loadData({
    required int totalXP,
    required int dailyStreak,
    required List<GameScore> scores,
    required List<Badge> badges,
    DateTime? lastPlayedDate,
  }) {
    _totalXP = totalXP;
    _dailyStreak = dailyStreak;
    _scores = scores;
    _badges = badges;
    _lastPlayedDate = lastPlayedDate;
    notifyListeners();
  }

  void _updateDailyStreak() {
    final now = DateTime.now();
    if (_lastPlayedDate == null) {
      _dailyStreak = 1;
    } else {
      final difference = now.difference(_lastPlayedDate!).inDays;
      if (difference == 1) {
        _dailyStreak++;
      } else if (difference > 1) {
        _dailyStreak = 1;
      }
    }
    _lastPlayedDate = now;
  }

  void _checkBadgeUnlocks() {
    // Check for new badge unlocks based on achievements
    final newBadges = <Badge>[];

    // First Game Badge
    if (_scores.length == 1 && !_hasBadge('first_game')) {
      newBadges.add(Badge(
        id: 'first_game',
        name: 'First Steps',
        emoji: '🎮',
        description: 'Played your first game!',
        unlockedAt: DateTime.now(),
      ));
    }

    // Perfect Score Badge
    final perfectScores = _scores.where((s) => s.accuracy == 100).length;
    if (perfectScores >= 1 && !_hasBadge('perfect_score')) {
      newBadges.add(Badge(
        id: 'perfect_score',
        name: 'Perfectionist',
        emoji: '⭐',
        description: 'Got a perfect score!',
        unlockedAt: DateTime.now(),
      ));
    }

    // 10 Games Badge
    if (_scores.length >= 10 && !_hasBadge('ten_games')) {
      newBadges.add(Badge(
        id: 'ten_games',
        name: 'Dedicated Learner',
        emoji: '🏆',
        description: 'Played 10 games!',
        unlockedAt: DateTime.now(),
      ));
    }

    // 7 Day Streak Badge
    if (_dailyStreak >= 7 && !_hasBadge('week_streak')) {
      newBadges.add(Badge(
        id: 'week_streak',
        name: 'Week Warrior',
        emoji: '🔥',
        description: '7 day streak!',
        unlockedAt: DateTime.now(),
      ));
    }

    // Emotion Master Badge (500 XP)
    if (_totalXP >= 500 && !_hasBadge('emotion_master')) {
      newBadges.add(Badge(
        id: 'emotion_master',
        name: 'Emotion Master',
        emoji: '🎓',
        description: 'Reached 500 XP!',
        unlockedAt: DateTime.now(),
      ));
    }

    _badges.addAll(newBadges);
  }

  bool _hasBadge(String badgeId) {
    return _badges.any((badge) => badge.id == badgeId);
  }

  List<GameScore> getScoresByGameType(String gameType) {
    return _scores.where((s) => s.gameType == gameType).toList();
  }

  double getAverageAccuracy() {
    if (_scores.isEmpty) return 0;
    final total = _scores.fold<double>(0, (sum, score) => sum + score.accuracy);
    return total / _scores.length;
  }

  int highScore(String gameType) {
    if (_scores.isEmpty) return 0;
    final gameScores = _scores.where((s) => s.gameType == gameType);
    if (gameScores.isEmpty) return 0;
    return gameScores.map((s) => s.score).reduce((a, b) => a > b ? a : b);
  }
}
