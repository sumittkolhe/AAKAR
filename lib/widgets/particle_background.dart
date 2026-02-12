import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

/// ✨ Particle Background - Ambient floating particles for visual depth
class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final Color? baseColor;
  final Widget? child;

  const ParticleBackground({
    super.key,
    this.particleCount = 30,
    this.baseColor,
    this.child,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _particles = List.generate(
      widget.particleCount,
      (_) => Particle.random(_random),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                progress: _controller.value,
                baseColor: widget.baseColor ?? AppColors.primary,
              ),
              size: Size.infinite,
            );
          },
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  double opacity;
  double phase;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
    required this.phase,
  });

  factory Particle.random(Random random) {
    return Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: random.nextDouble() * 3 + 1,
      speedX: (random.nextDouble() - 0.5) * 0.02,
      speedY: (random.nextDouble() - 0.5) * 0.02,
      opacity: random.nextDouble() * 0.3 + 0.1,
      phase: random.nextDouble() * pi * 2,
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color baseColor;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final animatedOpacity = particle.opacity *
          (0.5 + 0.5 * sin(progress * pi * 2 + particle.phase));

      final paint = Paint()
        ..color = baseColor.withOpacity(animatedOpacity)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size);

      final x = ((particle.x + particle.speedX * progress * 10) % 1) * size.width;
      final y = ((particle.y + particle.speedY * progress * 10) % 1) * size.height;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
