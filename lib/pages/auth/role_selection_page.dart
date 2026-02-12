import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../theme.dart';
import '../../widgets/aakar_widgets.dart';
import 'login_page.dart';
import '../../models/user_model.dart'; // Ensure correct import for UserRole

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                FadeInDown(
                  child: Text(
                    "Welcome to AAKAR",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    "Who is using the app today?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                
                // Child Role
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _RoleCard(
                    title: "I am a Child 🧒",
                    subtitle: "Play games & learn!",
                    gradient: AppColors.primaryGradient,
                    onTap: () => _navigateToLogin(context, UserRole.child),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Parent Role
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _RoleCard(
                    title: "I am a Parent 🛡️",
                    subtitle: "Track progress & settings",
                    gradient: AppColors.secondaryGradient,
                    onTap: () => _navigateToLogin(context, UserRole.parent),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Therapist Role
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _RoleCard(
                    title: "I am a Therapist 🎓",
                    subtitle: "Manage students & reports",
                    color: const Color(0xFF6366F1), // Indigo
                    onTap: () => _navigateToLogin(context, UserRole.therapist),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(role: role)),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Gradient? gradient;
  final Color? color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    this.gradient,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: gradient,
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: (color ?? gradient!.colors.first).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
