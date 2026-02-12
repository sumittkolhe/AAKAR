import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/emotion_history_provider.dart';
import '../../theme.dart';
import '../../shared/emotions.dart';

/// 📊 Analytics Page - Enhanced with mood trends and motivational elements
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getMotivationalMessage(Map<String, int> distribution) {
    if (distribution.isEmpty) {
      return 'Start detecting emotions to see your patterns! 🌟';
    }
    
    final topEmotion = distribution.entries.reduce(
      (a, b) => a.value > b.value ? a : b
    ).key;
    
    switch (topEmotion.toLowerCase()) {
      case 'happy':
        return 'You\'ve been feeling great lately! Keep up the positive vibes! 🌈';
      case 'sad':
        return 'It\'s okay to feel down sometimes. You\'re doing great by being aware! 💙';
      case 'angry':
        return 'Remember to take deep breaths. You\'re learning to manage your emotions! 🌬️';
      case 'calm':
        return 'You\'re maintaining excellent emotional balance! 🧘';
      case 'neutral':
        return 'You\'re staying balanced! Explore more emotions when ready. 🎭';
      default:
        return 'Every emotion is a chance to learn about yourself! ✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotionHistory = context.watch<EmotionHistoryProvider>();
    final distribution = emotionHistory.getEmotionDistribution();
    final totalDetections = distribution.values.fold(0, (a, b) => a + b);

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
          'Emotion Insights 📊',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                
                // Stats Summary
                FadeInDown(
                  child: _buildStatsSummary(totalDetections, distribution),
                ),
                
                const SizedBox(height: 24),
                
                if (distribution.isEmpty)
                  FadeInUp(
                    child: _buildEmptyState(),
                  )
                else ...[
                  // Motivational Message
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: _buildMotivationalCard(distribution),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pie Chart
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildPieChartCard(distribution),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent History
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildRecentHistoryCard(emotionHistory),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary(int total, Map<String, int> distribution) {
    String topEmotion = 'None';
    String topEmoji = '📊';
    
    if (distribution.isNotEmpty) {
      final top = distribution.entries.reduce((a, b) => a.value > b.value ? a : b);
      topEmotion = top.key;
      topEmoji = EmotionTheme.emoji(topEmotion);
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('📸', '$total', 'SCANS'),
          Container(height: 40, width: 1, color: AppColors.glassBorder),
          _buildStatItem(topEmoji, topEmotion, 'TOP MOOD'),
          Container(height: 40, width: 1, color: AppColors.glassBorder),
          _buildStatItem('📅', '${distribution.length}', 'EMOTIONS'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3 + 0.2 * _pulseController.value),
                      blurRadius: 20 + 10 * _pulseController.value,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('📊', style: TextStyle(fontSize: 48)),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'No Data Yet!',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 10),
          
          Text(
            'Start detecting emotions to see your patterns and mood trends here. 🌟',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          GradientButton(
            label: 'Start Detecting',
            icon: Icons.face_retouching_natural,
            onPressed: () => Navigator.pushNamed(context, '/detect'),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard(Map<String, int> distribution) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('💪', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _getMotivationalMessage(distribution),
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(Map<String, int> distribution) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emotion Distribution',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: _generatePieChartSections(distribution),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: distribution.keys.map((emotion) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: EmotionTheme.color(emotion),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${EmotionTheme.emoji(emotion)} $emotion',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections(Map<String, int> distribution) {
    final total = distribution.values.fold(0, (a, b) => a + b);
    final entries = distribution.entries.toList();
    
    return List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final value = (entries[i].value / total) * 100;
      final color = EmotionTheme.color(entries[i].key);
      
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${value.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched ? Text(
          EmotionTheme.emoji(entries[i].key),
          style: const TextStyle(fontSize: 20),
        ) : null,
        badgePositionPercentageOffset: 1.3,
      );
    });
  }

  Widget _buildRecentHistoryCard(EmotionHistoryProvider provider) {
    final history = provider.recentHistory;
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Detections',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (history.isNotEmpty)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: Text('Clear History?', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                        content: Text('This will remove all emotion detection history.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: GoogleFonts.inter()),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.clearHistory();
                              Navigator.pop(context);
                            },
                            child: Text('Clear', style: GoogleFonts.inter(color: const Color(0xFFF44336))),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Clear',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No recent detections yet 📭',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ...history.take(5).map((result) => _buildHistoryItem(result)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(dynamic result) {
    final emotion = result.emotion as String? ?? 'Unknown';
    final confidence = result.confidence as double? ?? 0.0;
    final timestamp = result.timestamp as DateTime? ?? DateTime.now();
    final emotionColor = EmotionTheme.color(emotion);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: emotionColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: emotionColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                EmotionTheme.emoji(emotion),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emotion,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: emotionColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${(confidence * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: emotionColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
