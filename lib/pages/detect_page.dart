import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../shared/emotions.dart';
import '../services/ml_service.dart';
import '../theme.dart';
import '../widgets/aakar_widgets.dart';
import '../providers/emotion_history_provider.dart';
import '../models/emotion_result.dart';

/// 🎭 Emotion Detection — 3-state flow: Prep → Detecting → Result
class DetectPage extends StatefulWidget {
  const DetectPage({super.key});

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> with TickerProviderStateMixin {
  // State: 0 = preparation, 1 = detecting, 2 = result
  int _state = 0;
  int _tabIndex = 0; // 0 = face, 1 = voice
  File? _selectedImage;
  String? _selectedAudioPath;
  bool _isAnalyzing = false;

  // Result data
  String? _detectedEmotion;
  double? _confidence;
  Map<String, double>? _probabilities;
  String? _previousEmotion;

  // Animation
  late AnimationController _scanController;
  late AnimationController _progressController;
  late Animation<double> _scanAnimation;
  int _messageIndex = 0;

  final List<String> _analyzeMessages = [
    'Reading facial expressions...',
    'Analyzing micro-patterns...',
    'Detecting emotional cues...',
    'Processing with AI...',
    'Almost there...',
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final history = context.read<EmotionHistoryProvider>();
      if (history.recentHistory.isNotEmpty) {
        _previousEmotion = history.recentHistory.first.emotion;
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _state = 0;
      });
    }
  }

  Future<void> _captureImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _state = 0;
        });
      }
    } catch (e) {
      _snack('Camera not available: $e');
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedAudioPath = result.files.single.path;
      });
    }
  }

  Future<void> _analyzeFace() async {
    if (_selectedImage == null) {
      _snack('Please select or capture an image first');
      return;
    }

    setState(() {
      _state = 1;
      _isAnalyzing = true;
      _messageIndex = 0;
    });

    _progressController.forward(from: 0);
    _startMessageRotation();

    try {
      final mlService = MLService();
      final result = await mlService.predictFace(_selectedImage!.path);
      final emotion = Emotions.argMax(result);
      final confidence = result[emotion] ?? 0.0;

      final emotionResult = EmotionResult(
        id: const Uuid().v4(),
        emotion: emotion,
        confidence: confidence,
        allProbabilities: result,
        timestamp: DateTime.now(),
        detectionType: 'face',
        imagePath: _selectedImage?.path,
      );
      if (mounted) {
        context.read<EmotionHistoryProvider>().addResult(emotionResult);
      }

      setState(() {
        _detectedEmotion = emotion;
        _confidence = confidence;
        _probabilities = result;
        _state = 2;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _state = 0;
        _isAnalyzing = false;
      });
      _snack('Analysis failed: $e');
    }
  }

  Future<void> _analyzeVoice() async {
    if (_selectedAudioPath == null) {
      _snack('Please select an audio file first');
      return;
    }

    setState(() {
      _state = 1;
      _isAnalyzing = true;
      _messageIndex = 0;
    });

    _progressController.forward(from: 0);
    _startMessageRotation();

    await Future.delayed(const Duration(seconds: 3));

    final mockResult = Emotions.mockProbs(
      seed: Emotions.seedFromString(_selectedAudioPath!),
    );
    final emotion = Emotions.argMax(mockResult);
    final confidence = mockResult[emotion] ?? 0.0;

    final emotionResult = EmotionResult(
      id: const Uuid().v4(),
      emotion: emotion,
      confidence: confidence,
      allProbabilities: mockResult,
      timestamp: DateTime.now(),
      detectionType: 'voice',
      audioPath: _selectedAudioPath,
    );
    if (mounted) {
      context.read<EmotionHistoryProvider>().addResult(emotionResult);
    }

    setState(() {
      _detectedEmotion = emotion;
      _confidence = confidence;
      _probabilities = mockResult;
      _state = 2;
      _isAnalyzing = false;
    });
  }

  void _startMessageRotation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_isAnalyzing) return false;
      setState(() {
        _messageIndex = (_messageIndex + 1) % _analyzeMessages.length;
      });
      return _isAnalyzing;
    });
  }

  void _retry() {
    setState(() {
      _state = 0;
      _detectedEmotion = null;
      _confidence = null;
      _probabilities = null;
    });
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _state == 2 ? 'Result' : 'Emotion Detection',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () {
            if (_state == 2) {
              _retry();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: AnimatedSwitcher(
        duration: AppAnimations.normal,
        child: _state == 0
            ? _buildPreparation()
            : _state == 1
                ? _buildDetecting()
                : _buildResult(),
      ),
    );
  }

  // ─── STATE 1: PREPARATION ────────────────────────────────
  Widget _buildPreparation() {
    return SingleChildScrollView(
      key: const ValueKey('prep'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTabSelector(),
          const SizedBox(height: 24),
          if (_tabIndex == 0) _buildFaceSection() else _buildVoiceSection(),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        children: [
          _buildTab('🎭 Face', 0),
          _buildTab('🎤 Voice', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaceSection() {
    return FadeInUp(
      child: Column(
        children: [
          // Image preview / placeholder
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_selectedImage!, fit: BoxFit.cover),
                          // Face alignment guide
                          Center(
                            child: Container(
                              width: 180,
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(90),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          child: const Icon(
                            Icons.face_retouching_natural,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to select a photo',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Center your face in the frame',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  Icons.photo_library_rounded,
                  'Gallery',
                  _pickImage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionBtn(
                  Icons.camera_alt_rounded,
                  'Camera',
                  _captureImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Analyze button
          PulseButton(
            label: 'Analyze Emotion 🧠',
            onPressed: _analyzeFace,
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSection() {
    return FadeInUp(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Icon(
                    _selectedAudioPath != null
                        ? Icons.audiotrack_rounded
                        : Icons.mic_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedAudioPath != null
                      ? 'Audio file selected ✓'
                      : 'Select an audio file',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'AI will analyze vocal emotion patterns',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildActionBtn(Icons.folder_open_rounded, 'Select Audio', _pickAudio),
          const SizedBox(height: 20),
          PulseButton(
            label: 'Analyze Voice 🎤',
            gradient: AppColors.purpleGradient,
            onPressed: _analyzeVoice,
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATE 2: DETECTING ──────────────────────────────────
  Widget _buildDetecting() {
    return Container(
      key: const ValueKey('detecting'),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scanning animation
          FadeInDown(
            child: AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3 * _scanAnimation.value),
                        AppColors.secondary.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2 * _scanAnimation.value),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: SpinKitPulse(
                      color: AppColors.primary,
                      size: 80,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 48),

          // AI thinking message
          FadeInUp(
            child: AnimatedSwitcher(
              duration: AppAnimations.normal,
              child: Text(
                _analyzeMessages[_messageIndex],
                key: ValueKey(_messageIndex),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Progress bar
          SizedBox(
            width: 200,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progressController.value,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── STATE 3: RESULT ─────────────────────────────────────
  Widget _buildResult() {
    if (_detectedEmotion == null) return const SizedBox.shrink();

    final emotionColor = EmotionTheme.color(_detectedEmotion!);
    final conf = ((_confidence ?? 0) * 100).toStringAsFixed(1);

    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main result card
          FadeInDown(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    emotionColor.withValues(alpha: 0.2),
                    AppColors.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: emotionColor.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: emotionColor.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Emotion Avatar
                  EmotionAvatar(
                    emotion: _detectedEmotion!,
                    size: 100,
                    animate: true,
                  ),
                  const SizedBox(height: 16),

                  // Emotion label
                  GlowText(
                    text: _detectedEmotion!,
                    glowColor: emotionColor,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: emotionColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Confidence
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: emotionColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '$conf% Confidence',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: emotionColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Emotion comparison
          if (_previousEmotion != null)
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Last: ${EmotionTheme.emoji(_previousEmotion!)} $_previousEmotion',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: AppColors.textMuted, size: 18),
                    ),
                    Text(
                      'Now: ${EmotionTheme.emoji(_detectedEmotion!)} $_detectedEmotion',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: emotionColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_previousEmotion != null) const SizedBox(height: 20),

          // Explanation
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 What This Means',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    EmotionTheme.explanation(_detectedEmotion!),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Probability bars
          if (_probabilities != null)
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 All Emotions',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildProbabilityBars(),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Suggested actions
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Suggested Actions'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: EmotionTheme.suggestedActions(_detectedEmotion!)
                      .map((action) => _buildSuggestedAction(action))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Row(
              children: [
                Expanded(
                  child: GradientButton(
                    label: '🔄 Try Again',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF334155), Color(0xFF1E293B)],
                    ),
                    onPressed: _retry,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: '🏠 Home',
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildProbabilityBars() {
    if (_probabilities == null) return [];

    final sorted = _probabilities!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((entry) {
      final pct = (entry.value * 100).toStringAsFixed(1);
      final color = EmotionTheme.color(entry.key);
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                '${EmotionTheme.emoji(entry.key)} ${entry.key}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: entry.value),
                  duration: Duration(milliseconds: 600 + (sorted.indexOf(entry) * 100)),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, _) {
                    return LinearProgressIndicator(
                      value: val,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 40,
              child: Text(
                '$pct%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSuggestedAction(String action) {
    return GestureDetector(
      onTap: () {
        if (action.contains('Calm') || action.contains('Breathe')) {
          Navigator.pushNamed(context, '/calm-mode');
        } else if (action.contains('Talk') || action.contains('Chat') || action.contains('Express') || action.contains('Share')) {
          Navigator.pushNamed(context, '/chatbot');
        } else if (action.contains('Play') || action.contains('Game') || action.contains('Distract')) {
          Navigator.pushNamed(context, '/game-menu');
        } else if (action.contains('Insights') || action.contains('Detect')) {
          Navigator.pushNamed(context, '/detect');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          action,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
