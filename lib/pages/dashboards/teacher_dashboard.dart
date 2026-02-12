import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/role-selection');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: const Text(
                  'Classroom Support',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C4DFF),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Tools and resources for educators',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Quick Actions
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: _buildActionCard(
                  context,
                  icon: Icons.analytics,
                  title: 'View Analytics',
                  subtitle: 'Student emotional trends',
                  color: const Color(0xFF4CAF50),
                  route: '/analytics',
                ),
              ),
              const SizedBox(height: 16),
              FadeInRight(
                delay: const Duration(milliseconds: 300),
                child: _buildActionCard(
                  context,
                  icon: Icons.book,
                  title: 'Behavior Guide',
                  subtitle: 'Understanding behaviors',
                  color: const Color(0xFFFF9800),
                  route: '/behavior-guide',
                ),
              ),
              const SizedBox(height: 16),
              FadeInLeft(
                delay: const Duration(milliseconds: 400),
                child: _buildActionCard(
                  context,
                  icon: Icons.chat,
                  title: 'Educational Chat',
                  subtitle: 'Get teaching strategies',
                  color: const Color(0xFF00BCD4),
                  route: '/chatbot',
                ),
              ),
              const SizedBox(height: 30),

              // Classroom Strategies
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: const Text(
                  'Classroom Strategies',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStrategy('📋', 'Visual schedules reduce anxiety'),
                      _buildStrategy('🔇', 'Quiet zones for overwhelm'),
                      _buildStrategy('⏰', 'Advance warning for transitions'),
                      _buildStrategy('👏', 'Positive reinforcement'),
                      _buildStrategy('🎯', 'Clear, simple instructions'),
                      _buildStrategy('🪑', 'Flexible seating arrangements'),
                      _buildStrategy('🎨', 'Sensory breaks throughout the day'),
                      _buildStrategy('📝', 'Written instructions alongside verbal'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Classroom Warning Signs Section
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: const Text(
                  'Classroom Warning Signs',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE91E63),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber, color: Color(0xFFE91E63)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Signs to Watch For in Class',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Social Signs
                      const Text(
                        '👥 Social Indicators',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIndicator('Avoids group activities or partner work'),
                      _buildIndicator('Difficulty understanding social cues'),
                      _buildIndicator('Prefers to work alone consistently'),
                      _buildIndicator('Struggles with playground interactions'),
                      _buildIndicator('Limited facial expressions or eye contact'),
                      
                      const SizedBox(height: 16),
                      
                      // Communication Signs
                      const Text(
                        '💬 Communication Indicators',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIndicator('Takes instructions very literally'),
                      _buildIndicator('Difficulty following multi-step directions'),
                      _buildIndicator('Unusual speech patterns or tone'),
                      _buildIndicator('Struggles with "why" or open-ended questions'),
                      _buildIndicator('Echoes words or phrases (echolalia)'),
                      
                      const SizedBox(height: 16),
                      
                      // Behavioral Signs
                      const Text(
                        '🔄 Behavioral Indicators',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIndicator('Repetitive movements (stimming)'),
                      _buildIndicator('Difficulty with transitions between activities'),
                      _buildIndicator('Meltdowns during unexpected changes'),
                      _buildIndicator('Intense focus on specific topics'),
                      _buildIndicator('Covers ears during loud noises'),
                      _buildIndicator('Overwhelmed by crowded or busy spaces'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategy(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String indicator) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFFE91E63)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              indicator,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
