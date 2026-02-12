import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'pages/home_page.dart';
import 'pages/splash_screen.dart';
import 'pages/auth/role_selection_page.dart'; // Updated path
import 'pages/detect_page.dart';
import 'pages/results_page.dart';
import 'pages/about_page.dart';
import 'pages/dashboards/child_dashboard.dart';
import 'pages/dashboards/parent_dashboard.dart';
import 'pages/dashboards/teacher_dashboard.dart';
import 'package:aakar_app/pages/games/game_menu_page.dart';
import 'package:aakar_app/pages/games/face_emotion_game.dart';
import 'package:aakar_app/pages/games/memory_game_page.dart';
import 'package:aakar_app/pages/games/scenario_game_page.dart';
import 'package:aakar_app/pages/games/rewards_page.dart';
import 'pages/chatbot/chatbot_page.dart';
import 'pages/guide/behavior_guide_page.dart';
import 'pages/analytics/analytics_page.dart';
import 'pages/zen_zone_page.dart';
import 'pages/settings_page.dart';
import 'pages/camera_page.dart';
import 'pages/extras/calm_mode_page.dart';
import 'pages/extras/breathing_exercise_page.dart';
import 'pages/onboarding/onboarding_page.dart';
import 'providers/role_provider.dart';
import 'providers/emotion_history_provider.dart';
import 'providers/game_provider.dart';
import 'providers/chatbot_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/auth_provider.dart'; // Added
import 'models/mood_entry.dart';
import 'pages/mood_journal_page.dart';
import 'pages/drawing_page.dart';
import 'pages/social_story_page.dart';
import 'models/quest.dart';
import 'pages/kindness_quest_page.dart';
import 'services/ml_service.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(QuestAdapter());
  
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error initializing cameras: $e');
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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => EmotionHistoryProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ],
      child: MaterialApp(
        title: 'A.A.K.A.R - Autism Assistive Kit',
        theme: AppTheme.dark(),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/role-selection': (_) => const RoleSelectionPage(),
          '/child-dashboard': (_) => const HomePage(),
          '/parent-dashboard': (_) => const ParentDashboard(),
          '/teacher-dashboard': (_) => const TeacherDashboard(),
          '/detect': (_) => const DetectPage(),
          '/camera': (_) => const CameraPage(),
          '/results': (_) => const ResultsPage(),
          '/game-menu': (_) => const GameMenuPage(),
          '/face-game': (context) => const FaceEmotionGame(),
          '/memory-game': (context) => const MemoryGamePage(),
          '/scenario-game': (context) => const ScenarioGamePage(),
          '/zen-zone': (context) => const ZenZonePage(),
          '/mood-journal': (context) => const MoodJournalPage(),
          '/drawing': (context) => const DrawingPage(),
          '/social-stories': (context) => const SocialStoryHubPage(),
          '/kindness-quests': (context) => const KindnessQuestPage(),
          '/rewards': (context) => const RewardsPage(),
          '/chatbot': (_) => const ChatbotPage(),
          '/behavior-guide': (_) => const BehaviorGuidePage(),
          '/analytics': (_) => const AnalyticsPage(),
          '/settings': (_) => const SettingsPage(),
          '/calm-mode': (_) => const CalmModePage(),
          '/breathing-exercise': (_) => const BreathingExercisePage(),
          '/about': (_) => const AboutPage(),
          '/onboarding': (_) => const OnboardingPage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const SplashScreen();
        }
        
        if (!auth.isAuthenticated) {
          return const RoleSelectionPage();
        }

        if (auth.isChild) {
          return const HomePage();
        } else if (auth.isParent) {
          return const ParentDashboard();
        } else if (auth.isTherapist) {
          return const TeacherDashboard();
        }

        return const RoleSelectionPage();
      },
    );
  }
}