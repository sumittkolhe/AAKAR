import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = true;
  final Uuid _uuid = const Uuid();

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  bool get isChild => _currentUser?.role == UserRole.child;
  bool get isParent => _currentUser?.role == UserRole.parent;
  bool get isTherapist => _currentUser?.role == UserRole.therapist;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userJson));
      } catch (e) {
        debugPrint("Error loading user: $e");
        await prefs.remove('user_data');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginAsChild(String name, String parentId) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK LOGIN
    _currentUser = ChildUser(
      id: _uuid.v4(),
      name: name,
      email: '${name.toLowerCase()}@aakar.com',
      parentId: parentId,
      age: 8,
      totalXP: 120,
      streaks: 3,
    );

    await _saveUserToPrefs();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginAsParent(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // MOCK LOGIN
    // In a real app, validate password here.
    if (password == 'password') {
       _currentUser = ParentUser(
        id: _uuid.v4(),
        name: "Parent User",
        email: email,
        childIds: ['child_1_mock'], // Mock child ID
      );
      await _saveUserToPrefs();
    } else {
      throw Exception('Invalid password');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginAsTherapist(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (password == 'password') {
      _currentUser = TherapistUser(
        id: _uuid.v4(),
        name: "Dr. Therapist",
        email: email,
        assignedChildIds: ['child_1_mock', 'child_2_mock'],
        clinicName: "Happy Minds Clinic",
      );
      await _saveUserToPrefs();
    } else {
      throw Exception('Invalid password');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }

  Future<void> _saveUserToPrefs() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));
  }
}
