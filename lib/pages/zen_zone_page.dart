import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';

import '../theme.dart';
import '../widgets/aakar_widgets.dart';

class ZenZonePage extends StatefulWidget {
  const ZenZonePage({super.key});

  @override
  State<ZenZonePage> createState() => _ZenZonePageState();
}

class _ZenZonePageState extends State<ZenZonePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Zen Zone 🧘',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Breathing'),
            Tab(text: 'Grounding'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: const [
              BreathingExercise(),
              GroundingGame(),
            ],
          ),
        ),
      ),
    );
  }
}

class BreathingExercise extends StatefulWidget {
  const BreathingExercise({super.key});

  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _instruction = "Breathe In";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startBreathingCycle();
  }

  void _startBreathingCycle() {
    _runCycle();
    _timer = Timer.periodic(const Duration(seconds: 12), (timer) {
      _runCycle();
    });
  }

  void _runCycle() {
    if (!mounted) return;
    
    // Inhale (4s)
    setState(() => _instruction = "Breathe In... 🌬️");
    _controller.forward();

    // Hold (4s)
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _instruction = "Hold... 😌");
    });

    // Exhale (4s)
    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      setState(() => _instruction = "Breathe Out... 💨");
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Text(
              _instruction,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 60),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)], // Teal
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2DD4BF).withValues(alpha: 0.5),
                        blurRadius: 30 * _animation.value,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.spa_rounded, size: 80, color: Colors.white),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
          FadeInUp(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Follow the circle. Breathe deep to calm your mind.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroundingGame extends StatefulWidget {
  const GroundingGame({super.key});

  @override
  State<GroundingGame> createState() => _GroundingGameState();
}

class _GroundingGameState extends State<GroundingGame> {
  final List<String> _steps = [
    "Find 5 things you can SEE 👀",
    "Find 4 things you can TOUCH ✋",
    "Find 3 things you can HEAR 👂",
    "Find 2 things you can SMELL 👃",
    "Find 1 thing you can TASTE 👅",
  ];
  
  final List<bool> _completed = [false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    final allDone = !_completed.contains(false);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),
        Text(
          "5-4-3-2-1 Grounding",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tap each step when you finish it.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FadeInLeft(
              delay: Duration(milliseconds: index * 200),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _completed[index] = !_completed[index];
                });
              },
              child: GlassCard(
                glowColor: _completed[index] ? AppColors.primary : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _completed[index] ? AppColors.primary : AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "${5 - index}",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _completed[index] ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _steps[index],
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            decoration: _completed[index] ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (_completed[index])
                        const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              ),
            ),
          );
        }),
        
        if (allDone) ...[
          const SizedBox(height: 32),
          FadeInUp(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text("🌟", style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 16),
                  Text(
                    "You did it! Feel steadier?",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Great job taking care of yourself.",
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
