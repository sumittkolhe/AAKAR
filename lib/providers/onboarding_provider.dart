import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnboardingProvider with ChangeNotifier {
  bool _isComplete = false;
  List<String> _selectedGoals = [];
  String _selectedRole = '';

  bool get isComplete => _isComplete;
  List<String> get selectedGoals => _selectedGoals;
  String get selectedRole => _selectedRole;

  OnboardingProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    final box = await Hive.openBox('onboarding');
    _isComplete = box.get('isComplete', defaultValue: false);
    _selectedGoals = List<String>.from(box.get('goals', defaultValue: []));
    _selectedRole = box.get('role', defaultValue: '');
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isComplete = true;
    final box = await Hive.openBox('onboarding');
    await box.put('isComplete', true);
    notifyListeners();
  }

  Future<void> setGoals(List<String> goals) async {
    _selectedGoals = goals;
    final box = await Hive.openBox('onboarding');
    await box.put('goals', goals);
    notifyListeners();
  }

  Future<void> setRole(String role) async {
    _selectedRole = role;
    final box = await Hive.openBox('onboarding');
    await box.put('role', role);
    notifyListeners();
  }

  Future<void> reset() async {
    _isComplete = false;
    _selectedGoals = [];
    _selectedRole = '';
    final box = await Hive.openBox('onboarding');
    await box.clear();
    notifyListeners();
  }
}
