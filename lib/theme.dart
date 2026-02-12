import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math';

// ─────────────────────────────────────────────────────────────
// 🎨 A.A.K.A.R — Premium Design System v2.0
// Emotion-first dark theme with glassmorphism, gradients,
// aurora backgrounds, pulse buttons, and emotion avatars
// ─────────────────────────────────────────────────────────────

class AppColors {
  // 🌙 Dark Mode Palette — OLED-optimized
  static const Color background = Color(0xFF06080F);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);

  // 🎨 Accent Colors — Modern violet/cyan
  static const Color primary = Color(0xFF8B5CF6);       // Violet-500
  static const Color secondary = Color(0xFF06B6D4);      // Cyan-500
  static const Color accent = Color(0xFFF97316);          // Orange-500
  static const Color teal = Color(0xFF14B8A6);            // Teal-500
  static const Color pink = Color(0xFFF472B6);            // Pink-400
  static const Color gold = Color(0xFFFBBF24);            // Amber-400

  // 📝 Text Colors
  static const Color textPrimary = Color(0xFFF1F5F9);    // Slate-100
  static const Color textSecondary = Color(0xFF94A3B8);   // Slate-400
  static const Color textMuted = Color(0xFF64748B);       // Slate-500
  static const Color textDark = Color(0xFF1E293B);

  // 🔄 Backward Compatible aliases
  static const Color primaryPurple = primary;
  static const Color primaryBlue = secondary;
  static const Color accentPeach = Color(0xFFFFB5A7);
  static const Color accentMint = Color(0xFF6EE7B7);
  static const Color accentYellow = Color(0xFFFDE68A);
  static const Color accentPink = pink;
  static const Color backgroundLight = background;
  static const Color cardWhite = surface;

  // ✨ Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient storyGradient = LinearGradient(
    colors: [Color(0xFFF472B6), Color(0xFF8B5CF6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF06080F), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFF87171), Color(0xFFFB923C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calmGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🔮 Glassmorphism
  static Color glassWhite = Colors.white.withValues(alpha: 0.06);
  static Color glassBorder = Colors.white.withValues(alpha: 0.10);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.12);
}

// ─────────────────────────────────────────────────────────────
// 📐 Design Tokens — Spacing, radii, elevation
// ─────────────────────────────────────────────────────────────

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 100;
  static const double card = 20;
  static const double button = 16;
  static const double modal = 28;
}

// ─────────────────────────────────────────────────────────────
// 🧠 Emotion Theme — Maps emotions to visual properties
// ─────────────────────────────────────────────────────────────

class EmotionTheme {
  static Color color(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return const Color(0xFFFBBF24);
      case 'sad':
        return const Color(0xFF60A5FA);
      case 'angry':
        return const Color(0xFFF87171);
      case 'fear':
        return const Color(0xFFA78BFA);
      case 'surprise':
        return const Color(0xFF34D399);
      case 'disgust':
        return const Color(0xFFFB923C);
      case 'contempt':
        return const Color(0xFFE17055);
      case 'neutral':
      case 'bored':
        return const Color(0xFF94A3B8);
      case 'excited':
        return const Color(0xFFFBBF24); // Gold
      case 'nervous':
        return const Color(0xFF818CF8); // Indigo
      case 'proud':
        return const Color(0xFFF472B6); // Pink
      case 'shy':
        return const Color(0xFFA78BFA); // Purple
      case 'confused':
        return const Color(0xFFFB923C); // Orange
      default:
        return const Color(0xFF94A3B8);
    }
  }

  static LinearGradient gradient(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'excited':
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFB923C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sad':
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'angry':
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'fear':
      case 'nervous':
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'surprise':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'disgust':
        return const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'contempt':
      case 'proud':
        return const LinearGradient(
          colors: [Color(0xFFE17055), Color(0xFFD35400)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'shy':
        return const LinearGradient(
          colors: [Color(0xFFC084FC), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'confused':
         return const LinearGradient(
          colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'neutral':
      case 'bored':
      default:
        return const LinearGradient(
          colors: [Color(0xFF64748B), Color(0xFF475569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  static Color glowColor(String emotion) {
    return color(emotion).withValues(alpha: 0.4);
  }

  /// Background gradient for the entire screen based on emotion
  static LinearGradient screenGradient(String emotion) {
    final c = color(emotion);
    return LinearGradient(
      colors: [
        AppColors.background,
        c.withValues(alpha: 0.08),
        AppColors.background,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.4, 1.0],
    );
  }

  static String explanation(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return "You're feeling joyful! Your face shows a smile and bright eyes. This is a wonderful feeling! 🌟";
      case 'excited':
        return "You're bubbling with energy! Something great must be happening! 🤩";
      case 'sad':
        return "You seem a little down. It's okay to feel sad sometimes — everyone does. Would you like to talk about it? 💙";
      case 'angry':
        return "You look frustrated or upset. It's natural to feel angry. Let's find a way to feel calmer together. 🧘";
      case 'fear':
        return "You might be feeling scared or worried. That's okay — you're safe here. Let's try some calming exercises. 💫";
      case 'nervous':
        return "Butterflies in your stomach? Take a deep breath. You've got this! 🦋";
      case 'surprise':
        return "Something surprised you! Your eyes went wide and your eyebrows went up. How exciting! ✨";
      case 'disgust':
        return "Something doesn't seem right to you. That's your brain's way of protecting you. 🛡️";
      case 'contempt':
        return "You might be feeling a bit dismissive or unimpressed. Let's explore what's on your mind. 🤔";
      case 'proud':
        return "You did something awesome! Stand tall and feel good about yourself. 🏆";
      case 'shy':
        return "Feeling a bit quiet? That's totally fine. Take your time. 🌸";
      case 'bored':
        return "Feeling uninterested? Maybe it's time to try something new! 🎨";
      case 'confused':
        return "Not sure what's going on? Asking questions is a great way to learn! ❓";
      case 'neutral':
      default:
        return "You seem calm and relaxed right now. A peaceful feeling is a great place to start! 😌";
    }
  }

  static List<String> suggestedActions(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'excited':
      case 'proud':
        return ['🎮 Play a Game', '💬 Share Joy', '📓 Journal It', '🌟 Keep Going'];
      case 'sad':
      case 'shy':
        return ['🧘 Calm Down', '💬 Talk About It', '🎵 Listen to Music', '🤗 Get a Hug'];
      case 'angry':
        return ['🌬️ Breathe Deep', '🧘 Calm Mode', '💬 Express It', '🎮 Play'];
      case 'fear':
      case 'nervous':
        return ['🌬️ Breathe', '✋ Grounding', '💬 Talk', '🧘 Safe Space'];
      case 'surprise':
      case 'confused':
        return ['💬 Share It', '📓 Journal', '🎮 Play', '🤔 Reflect'];
      case 'disgust':
        return ['🧘 Calm Mode', '💬 Talk', '🎮 Distract', '📓 Journal'];
      case 'contempt':
      case 'bored':
        return ['💬 Express', '🧘 Reflect', '🎮 Play', '📓 Journal'];
      case 'neutral':
      default:
        return ['🎭 Detect Emotion', '🎮 Play Games', '💬 Chat', '📊 Insights'];
    }
  }

  static String emoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy': return '😊';
      case 'sad': return '😢';
      case 'angry': return '😠';
      case 'fear': return '😨';
      case 'surprise': return '😲';
      case 'disgust': return '🤢';
      case 'contempt': return '😏';
      case 'excited': return '🤩';
      case 'nervous': return '😰';
      case 'proud': return '😌';
      case 'shy': return '🫣';
      case 'bored': return '😒';
      case 'confused': return '😕';
      case 'neutral': default: return '😐';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// ⚡ Animation Constants
// ─────────────────────────────────────────────────────────────

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration xSlow = Duration(milliseconds: 800);
  static const Duration pageTransition = Duration(milliseconds: 400);
  static const Duration breathe = Duration(milliseconds: 3000);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve springCurve = Curves.easeOutBack;
}

// ─────────────────────────────────────────────────────────────
// 🎨 App Theme
// ─────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData dark() {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -1.5),
        displayMedium: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary, height: 1.6),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        color: AppColors.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          side: BorderSide(color: AppColors.glassBorder, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: CircleBorder(),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 0.5,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        side: BorderSide(color: AppColors.glassBorder),
      ),
    );
  }

  static ThemeData light() => dark();
}

// ─────────────────────────────────────────────────────────────
// 🔮 Glass Card Widget
// ─────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? blur;
  final double? borderRadius;
  final Gradient? gradient;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 10,
    this.borderRadius = 20,
    this.gradient,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius!),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur!, sigmaY: blur!),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? AppColors.glassWhite : null,
            borderRadius: BorderRadius.circular(borderRadius!),
            border: Border.all(color: AppColors.glassBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              if (glowColor != null)
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ✨ Gradient Button — with scale animation
// ─────────────────────────────────────────────────────────────

class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final double? width;
  final double? height;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.gradient,
    this.width,
    this.height = 56,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: [
              BoxShadow(
                color: (widget.gradient ?? AppColors.primaryGradient)
                    .colors
                    .first
                    .withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
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

// ─────────────────────────────────────────────────────────────
// 🌈 Gradient Border Container
// ─────────────────────────────────────────────────────────────

class GradientBorder extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final double? borderWidth;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const GradientBorder({
    super.key,
    required this.child,
    this.gradient,
    this.borderWidth = 2,
    this.borderRadius = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(borderWidth!),
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.storyGradient,
        borderRadius: BorderRadius.circular(borderRadius!),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(borderRadius! - borderWidth!),
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🌌 Aurora Background — animated gradient mesh
// ─────────────────────────────────────────────────────────────

class AuroraBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const AuroraBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? [
      AppColors.primary.withValues(alpha: 0.15),
      AppColors.secondary.withValues(alpha: 0.10),
      AppColors.teal.withValues(alpha: 0.08),
    ];

    return Stack(
      children: [
        // Base background
        Container(color: AppColors.background),
        // Animated aurora blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _AuroraPainter(
                animation: _controller.value,
                colors: colors,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double animation;
  final List<Color> colors;

  _AuroraPainter({required this.animation, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

      final offset = Offset(
        size.width * (0.3 + 0.4 * sin(animation * 2 * pi + i * 2.1)),
        size.height * (0.2 + 0.3 * sin(animation * 2 * pi + i * 1.7 + 1.0)),
      );

      canvas.drawCircle(offset, size.width * 0.35, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

// ─────────────────────────────────────────────────────────────
// 💜 Pulse Button — CTA with animated pulse ring
// ─────────────────────────────────────────────────────────────

class PulseButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final double size;

  const PulseButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.gradient,
    this.size = 56,
  });

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = _pulseController.value;
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: double.infinity,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: widget.gradient ?? AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.button),
              boxShadow: [
                BoxShadow(
                  color: (widget.gradient ?? AppColors.primaryGradient)
                      .colors.first
                      .withValues(alpha: 0.3 + pulseValue * 0.2),
                  blurRadius: 20 + pulseValue * 10,
                  spreadRadius: pulseValue * 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🎭 Emotion Avatar — circular emotion indicator with ring
// ─────────────────────────────────────────────────────────────

class EmotionAvatar extends StatefulWidget {
  final String emotion;
  final double size;
  final bool animate;

  const EmotionAvatar({
    super.key,
    required this.emotion,
    this.size = 80,
    this.animate = true,
  });

  @override
  State<EmotionAvatar> createState() => _EmotionAvatarState();
}

class _EmotionAvatarState extends State<EmotionAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.animate) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emotionColor = EmotionTheme.color(widget.emotion);
    final emoji = EmotionTheme.emoji(widget.emotion);

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final glow = widget.animate ? _glowController.value : 0.5;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                emotionColor.withValues(alpha: 0.2),
                emotionColor.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              radius: 1.0 + glow * 0.3,
            ),
            boxShadow: [
              BoxShadow(
                color: emotionColor.withValues(alpha: 0.3 + glow * 0.2),
                blurRadius: 20 + glow * 15,
                spreadRadius: glow * 3,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  emotionColor.withValues(alpha: 0.3),
                  emotionColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: emotionColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: widget.size * 0.45),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🔄 Progress Ring — circular progress indicator
// ─────────────────────────────────────────────────────────────

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Gradient? gradient;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 60,
    this.strokeWidth = 4,
    this.gradient,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              color: AppColors.surface,
              backgroundColor: Colors.transparent,
            ),
          ),
          // Progress arc
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: AppAnimations.slow,
              curve: AppAnimations.defaultCurve,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _ProgressRingPainter(
                    progress: value,
                    strokeWidth: strokeWidth,
                    gradient: gradient ?? AppColors.primaryGradient,
                  ),
                );
              },
            ),
          ),
          // Center content
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Gradient gradient;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─────────────────────────────────────────────────────────────
// ✨ Glow Text — text with soft emotion-colored glow
// ─────────────────────────────────────────────────────────────

class GlowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double glowRadius;

  const GlowText({
    super.key,
    required this.text,
    this.style,
    this.glowColor = AppColors.primary,
    this.glowRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glow layer
        Text(
          text,
          style: (style ?? GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700)).copyWith(
            foreground: Paint()
              ..color = glowColor.withValues(alpha: 0.4)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius),
          ),
        ),
        // Main text
        Text(
          text,
          style: style ?? GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🏷️ Section Header — reusable section title
// ─────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailing!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🎯 Stat Chip — small stat display (XP, Level, Streak)
// ─────────────────────────────────────────────────────────────

class StatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Gradient? gradient;

  const StatChip({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
