import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'pages/home_page.dart';
import 'pages/splash_screen.dart';
import 'pages/role_selection_page.dart';
import 'pages/detect_page.dart';
import 'pages/results_page.dart';
import 'pages/about_page.dart';
import 'pages/dashboards/child_dashboard.dart';
import 'pages/dashboards/parent_dashboard.dart';
import 'pages/dashboards/teacher_dashboard.dart';
import 'pages/games/game_menu_page.dart';
import 'pages/games/face_emotion_game.dart';
import 'pages/games/rewards_page.dart';
import 'pages/chatbot/chatbot_page.dart';
import 'pages/guide/behavior_guide_page.dart';
import 'pages/analytics/analytics_page.dart';
import 'pages/settings_page.dart';
import 'pages/camera_page.dart';
import 'pages/extras/calm_mode_page.dart';
import 'pages/extras/breathing_exercise_page.dart';
import 'providers/role_provider.dart';
import 'providers/emotion_history_provider.dart';
import 'providers/game_provider.dart';
import 'providers/chatbot_provider.dart';
import 'providers/settings_provider.dart';
import 'services/ml_service.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Error initializing cameras: $e');
  }
  
  // Initialize ML service
  final mlService = MLService();
  await mlService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => EmotionHistoryProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'A.A.K.A.R - Autism Assistive Kit',
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/': (_) => const HomePage(),
          '/role-selection': (_) => const RoleSelectionPage(),
          '/child-dashboard': (_) => const ChildDashboard(),
          '/parent-dashboard': (_) => const ParentDashboard(),
          '/teacher-dashboard': (_) => const TeacherDashboard(),
          '/detect': (_) => const DetectPage(),
          '/camera': (_) => const CameraPage(),
          '/results': (_) => const ResultsPage(),
          '/game-menu': (_) => const GameMenuPage(),
          '/face-game': (_) => const FaceEmotionGame(),
          '/rewards': (_) => const RewardsPage(),
          '/chatbot': (_) => const ChatbotPage(),
          '/behavior-guide': (_) => const BehaviorGuidePage(),
          '/analytics': (_) => const AnalyticsPage(),
          '/settings': (_) => const SettingsPage(),
          '/calm-mode': (_) => const CalmModePage(),
          '/breathing-exercise': (_) => const BreathingExercisePage(),
          '/about': (_) => const AboutPage(),
        },
      ),
    );
  }
}