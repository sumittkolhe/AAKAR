import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../theme.dart'; // Make sure this path is correct based on your structure
import '../../widgets/aakar_widgets.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  final UserRole role;

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // For Child Login
  final _nameController = TextEditingController();
  final _parentIdController = TextEditingController();

  bool _isPasswordVisible = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    
    try {
      if (widget.role == UserRole.child) {
        // Child Login Logic
        await auth.loginAsChild(
          _nameController.text.trim(),
          _parentIdController.text.trim(),
        );
      } else if (widget.role == UserRole.parent) {
        // Parent Login Logic
        await auth.loginAsParent(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        // Therapist Login Logic
        await auth.loginAsTherapist(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (mounted) {
        // Navigation is handled by the AuthWrapper in main.dart
        // We just pop back to root or let the wrapper handle it
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Failed: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChild = widget.role == UserRole.child;
    final roleName = widget.role.toString().split('.').last.toUpperCase();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                   FadeInDown(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        isChild ? "🧒" : (widget.role == UserRole.parent ? "🛡️" : "🎓"),
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      "$roleName LOGIN",
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (isChild) ...[
                              _buildTextField(
                                controller: _nameController,
                                label: "First Name",
                                icon: Icons.person_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _parentIdController,
                                label: "Parent Code (Optional for mock)", // In real app, strict linking
                                icon: Icons.qr_code_rounded,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Ask your parent for their code!",
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              )
                            ] else ...[
                              _buildTextField(
                                controller: _emailController,
                                label: "Email Address",
                                icon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _passwordController,
                                label: "Password",
                                icon: Icons.lock_rounded,
                                isPassword: true,
                              ),
                            ],
                            
                            const SizedBox(height: 32),
                            
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return auth.isLoading 
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: GradientButton(
                                        label: "Login", 
                                        gradient: isChild 
                                          ? AppColors.primaryGradient 
                                          : AppColors.secondaryGradient,
                                        onPressed: _login,
                                      ),
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white),
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label, // Changed from labelText to label: Text() usually, but labelText works
        labelStyle: GoogleFonts.inter(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF1E293B).withValues(alpha: 0.5), // Slate-800 equivalent
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
