import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme.dart';

/// 🏠 Home Page - Premium Instagram/WhatsApp Style
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0: break; // Home - already here
      case 1: Navigator.pushNamed(context, '/detect'); break;
      case 2: Navigator.pushNamed(context, '/game-menu'); break;
      case 3: Navigator.pushNamed(context, '/chatbot'); break;
      case 4: Navigator.pushNamed(context, '/analytics'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // 📱 Top Bar
                _buildTopBar(),
                
                const SizedBox(height: 32),
                
                // 🌟 Hero Section
                _buildHeroSection(),
                
                const SizedBox(height: 32),
                
                // 📊 Quick Stats Stories
                _buildStoriesSection(),
                
                const SizedBox(height: 28),
                
                // 🎯 Main Actions
                _buildMainActions(),
                
                const SizedBox(height: 28),
                
                // 🎮 Feature Grid
                _buildFeatureGrid(),
                
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Logo
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🧠', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'A.A.K.A.R',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'AI Emotion Assistant',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Notification & Settings
          Row(
            children: [
              _buildIconButton(Icons.notifications_outlined, () {}),
              const SizedBox(width: 8),
              _buildIconButton(Icons.settings_outlined, () {
                Navigator.pushNamed(context, '/settings');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 22),
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Animated Emotion Face
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + (_pulseController.value * 0.05),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 30 + (_pulseController.value * 20),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('😊', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Hey! How are you feeling?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Let me analyze your emotions with AI ✨',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            
            const SizedBox(height: 24),
            
            GradientButton(
              label: 'Detect My Emotion',
              icon: Icons.face_retouching_natural,
              onPressed: () => Navigator.pushNamed(context, '/detect'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesSection() {
    final stories = [
      {'emoji': '😊', 'label': 'Happy', 'color': const Color(0xFF4CAF50)},
      {'emoji': '😢', 'label': 'Sad', 'color': const Color(0xFF2196F3)},
      {'emoji': '😠', 'label': 'Angry', 'color': const Color(0xFFF44336)},
      {'emoji': '😲', 'label': 'Surprise', 'color': const Color(0xFFFF9800)},
      {'emoji': '😐', 'label': 'Neutral', 'color': const Color(0xFF9E9E9E)},
    ];

    return FadeInLeft(
      duration: const Duration(milliseconds: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emotions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return Padding(
                  padding: EdgeInsets.only(right: index < stories.length - 1 ? 16 : 0),
                  child: _buildStoryItem(
                    story['emoji'] as String,
                    story['label'] as String,
                    story['color'] as Color,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(String emoji, String label, Color color) {
    return Column(
      children: [
        GradientBorder(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
          borderWidth: 2.5,
          borderRadius: 30,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMainActions() {
    return FadeInUp(
      duration: const Duration(milliseconds: 900),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              '🎮',
              'Games',
              'Learn emotions',
              AppColors.purpleGradient,
              () => Navigator.pushNamed(context, '/game-menu'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              '💬',
              'Chat Bot',
              'Talk with AI',
              AppColors.mintGradient,
              () => Navigator.pushNamed(context, '/chatbot'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String emoji, String title, String subtitle, Gradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {'icon': Icons.auto_graph, 'label': 'Analytics', 'route': '/analytics'},
      {'icon': Icons.spa, 'label': 'Calm Mode', 'route': '/calm-mode'},
      {'icon': Icons.menu_book, 'label': 'Guide', 'route': '/behavior-guide'},
      {'icon': Icons.info_outline, 'label': 'About', 'route': '/about'},
    ];

    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return _buildFeatureItem(
                feature['icon'] as IconData,
                feature['label'] as String,
                () => Navigator.pushNamed(context, feature['route'] as String),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_filled, 'Home', 0),
              _buildNavItem(Icons.face_retouching_natural, 'Detect', 1),
              _buildNavItem(Icons.sports_esports, 'Games', 2),
              _buildNavItem(Icons.chat_bubble_outline, 'Chat', 3),
              _buildNavItem(Icons.bar_chart, 'Stats', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
