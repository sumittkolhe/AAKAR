import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../models/social_story.dart';
import '../data/social_stories_data.dart';
import '../widgets/aakar_widgets.dart';
import '../providers/game_provider.dart';

class SocialStoryHubPage extends StatelessWidget {
  const SocialStoryHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = SocialStoriesData.stories;

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
          'Social Stories 📚',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return FadeInUp(
                delay: Duration(milliseconds: index * 100),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SocialStoryPage(story: story),
                        ),
                      );
                    },
                    child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              story.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  story.description,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SocialStoryPage extends StatefulWidget {
  final SocialStory story;

  const SocialStoryPage({super.key, required this.story});

  @override
  State<SocialStoryPage> createState() => _SocialStoryPageState();
}

class _SocialStoryPageState extends State<SocialStoryPage> {
  late String _currentSegmentId;
  int _totalXpEarned = 0;

  @override
  void initState() {
    super.initState();
    _currentSegmentId = 'start';
  }

  StorySegment get _currentSegment =>
      widget.story.segments.firstWhere((s) => s.id == _currentSegmentId);

  void _handleChoice(StoryChoice choice) {
    if (choice.xpReward != null) {
      _totalXpEarned += choice.xpReward!;
    }

    if (choice.nextSegmentId == null) {
      _finishStory();
    } else {
      setState(() {
        _currentSegmentId = choice.nextSegmentId!;
      });
    }
  }

  void _finishStory() {
    if (_totalXpEarned > 0) {
      context.read<GameProvider>().addXP(_totalXpEarned);
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎉", style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                "Story Complete!",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You earned $_totalXpEarned XP!",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Back to Stories',
                gradient: AppColors.primaryGradient,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final segment = _currentSegment;

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
          widget.story.title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FadeIn(
                      key: ValueKey(_currentSegmentId),
                      child: GlassCard(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (segment.imageAsset != null) ...[
                              Image.asset(segment.imageAsset!, height: 150),
                              const SizedBox(height: 24),
                            ],
                            Text(
                              segment.text,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                height: 1.5,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: segment.choices.map((choice) {
                       return Padding(
                         padding: const EdgeInsets.only(bottom: 12),
                         child: FadeInUp(
                           duration: const Duration(milliseconds: 300),
                           child: SizedBox(
                             height: 56,
                             child: ElevatedButton(
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: AppColors.surfaceLight,
                                 foregroundColor: AppColors.textPrimary,
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(AppRadius.pill),
                                   side: const BorderSide(color: AppColors.primary, width: 1),
                                 ),
                                 elevation: 0,
                               ),
                               onPressed: () => _handleChoice(choice),
                               child: Text(
                                 choice.text,
                                 style: GoogleFonts.outfit(
                                   fontSize: 16,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                             ),
                           ),
                         ),
                       );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),

    );
  }
}
