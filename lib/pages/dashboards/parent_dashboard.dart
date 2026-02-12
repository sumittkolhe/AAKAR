import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/emotion_history_provider.dart';
import '../../providers/auth_provider.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final emotionHistory = context.watch<EmotionHistoryProvider>();
    final distribution = emotionHistory.getEmotionDistribution();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
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
              // Welcome Section
              FadeInDown(
                child: const Text(
                  'Child\'s Emotional Journey',
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
                  'Monitor progress and gain insights',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Quick Stats
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: '📊',
                        title: 'Total Scans',
                        value: '${emotionHistory.history.length}',
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: '😊',
                        title: 'Most Common',
                        value: _getMostCommonEmotion(distribution),
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _buildActionButton(
                  context,
                  icon: Icons.analytics,
                  title: 'View Analytics',
                  subtitle: 'Detailed emotion trends and insights',
                  route: '/analytics',
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildActionButton(
                  context,
                  icon: Icons.book,
                  title: 'Behavior Guide',
                  subtitle: 'Understanding autism behaviors',
                  route: '/behavior-guide',
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: _buildActionButton(
                  context,
                  icon: Icons.chat,
                  title: 'Chat Support',
                  subtitle: 'Get help and advice',
                  route: '/chatbot',
                ),
              ),
              const SizedBox(height: 30),

              // Emergency Calming Tips
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF44336),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.emergency, color: Color(0xFFF44336)),
                          SizedBox(width: 8),
                          Text(
                            'Emergency Calming Tips',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF44336),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('Create a quiet, safe space'),
                      _buildTip('Reduce sensory input (lights, noise)'),
                      _buildTip('Offer comfort items'),
                      _buildTip('Use calm, simple language'),
                      _buildTip('Give time and space'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/breathing-exercise'),
                              icon: const Icon(Icons.air),
                              label: const Text('Breathing'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00BCD4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/calm-mode'),
                              icon: const Icon(Icons.self_improvement),
                              label: const Text('Calm Mode'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C4DFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Autism Symptoms Section
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF9C27B0),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.psychology, color: Color(0xFF9C27B0)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Autism Signs to Watch For',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9C27B0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Early Warning Signs
                      const Text(
                        '🚨 Early Warning Signs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSymptom('Limited or no eye contact'),
                      _buildSymptom('Delayed speech or language skills'),
                      _buildSymptom('Repetitive movements (hand flapping, rocking)'),
                      _buildSymptom('Not responding to their name by 12 months'),
                      _buildSymptom('Loss of previously acquired skills'),
                      
                      const SizedBox(height: 16),
                      
                      // Social Communication
                      const Text(
                        '💬 Social & Communication Signs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSymptom('Difficulty understanding others\' emotions'),
                      _buildSymptom('Prefers playing alone'),
                      _buildSymptom('Difficulty making or keeping friends'),
                      _buildSymptom('Unusual tone of voice or speech patterns'),
                      _buildSymptom('Trouble with back-and-forth conversation'),
                      
                      const SizedBox(height: 16),
                      
                      // Sensory Sensitivities
                      const Text(
                        '🎧 Sensory Sensitivities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSymptom('Over or under-sensitive to sounds'),
                      _buildSymptom('Sensitivity to lights or colors'),
                      _buildSymptom('Texture aversions (food, clothing)'),
                      _buildSymptom('Unusual responses to smells or tastes'),
                      _buildSymptom('Seeking or avoiding certain sensations'),
                      
                      const SizedBox(height: 16),
                      
                      // Behavioral Patterns
                      const Text(
                        '🔄 Behavioral Patterns',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSymptom('Strong need for routine and predictability'),
                      _buildSymptom('Intense focus on specific interests'),
                      _buildSymptom('Difficulty with changes or transitions'),
                      _buildSymptom('Lining up toys or objects'),
                      _buildSymptom('Meltdowns when overwhelmed'),
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

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF7C4DFF), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptom(String symptom) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF9C27B0)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              symptom,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _getMostCommonEmotion(Map<String, int> distribution) {
    if (distribution.isEmpty) return 'N/A';
    final sorted = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }
}
