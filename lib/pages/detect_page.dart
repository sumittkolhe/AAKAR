import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';

import '../shared/emotions.dart';
import '../services/ml_service.dart';
import '../theme.dart';

class DetectPage extends StatefulWidget {
  const DetectPage({super.key});

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final MLService _mlService = MLService();
  XFile? _image;
  File? _audio;
  bool _isLoading = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _mlService.initialize();
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Use FilePicker with extension filter to only allow supported formats
    // AVIF is not supported by the image package
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'],
    );
    if (res != null && res.files.single.path != null) {
      final path = res.files.single.path!;
      final ext = path.split('.').last.toLowerCase();
      
      // Secondary validation - reject unsupported formats
      const supportedFormats = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'];
      if (!supportedFormats.contains(ext)) {
        _snack('Unsupported format: .$ext\nPlease use JPG, PNG, WebP, GIF, or BMP');
        return;
      }
      
      setState(() => _image = XFile(path));
    }
  }

  Future<void> _captureImage() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // On desktop, launch our custom camera page
      final result = await Navigator.pushNamed(context, '/camera');
      if (result != null && result is XFile) {
        setState(() => _image = result);
      }
    } else {
      // On mobile, use standard image picker
      final XFile? picked = await _imagePicker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        setState(() => _image = picked);
      }
    }
  }

  Future<void> _pickAudio() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'mp3', 'ogg', 'm4a'],
    );
    if (res != null && res.files.single.path != null) {
      setState(() => _audio = File(res.files.single.path!));
    }
  }

  Future<void> _analyzeFace() async {
    if (_image == null) {
      _snack('Please select an image first');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final probs = await _mlService.predictFace(_image!.path);
      final label = Emotions.argMax(probs);
      if (mounted) {
        Navigator.pushNamed(context, '/results', arguments: {
          'finalLabel': label,
          'finalConf': probs[label],
          'emoji': Emotions.emoji[label],
          'feedback': 'You look ${label.toLowerCase()}! ${Emotions.emoji[label]}'
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _analyzeVoice() async {
    if (_audio == null) {
      _snack('Please select an audio file first');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final probs = await _mlService.predictVoice(_audio!.path);
      final label = Emotions.argMax(probs);
      if (mounted) {
        Navigator.pushNamed(context, '/results', arguments: {
          'finalLabel': label,
          'finalConf': probs[label],
          'emoji': Emotions.emoji[label],
          'feedback': 'You sound ${label.toLowerCase()}! 🎵'
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Emotion Detection'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // Tab Selector
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: _buildTabSelector(),
                ),
                
                const SizedBox(height: 24),
                
                // Content based on tab
                if (_selectedTab == 0) ...[
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: _buildImageSection(),
                  ),
                ] else ...[
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: _buildAudioSection(),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Analyze Button
                if (_isLoading)
                  _buildLoadingIndicator()
                else
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: _buildAnalyzeButton(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab('📸 Face', 0)),
          Expanded(child: _buildTab('🎵 Voice', 1)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Preview Area
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder, width: 2),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_a_photo, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to select an image',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'or use the buttons below',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.photo_library_outlined,
                  'Gallery',
                  _pickImage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  Icons.camera_alt_outlined,
                  'Camera',
                  _captureImage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Audio Preview
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder, width: 2),
            ),
            child: _audio != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.mintGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.audiotrack, color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _audio!.path.split(Platform.pathSeparator).last,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.mintGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic_none, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select an audio file',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
          ),
          
          const SizedBox(height: 20),
          
          // Audio Button
          _buildActionButton(
            Icons.folder_outlined,
            'Choose Audio File',
            _pickAudio,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return FadeIn(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitRipple(
              color: AppColors.primary,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Analyzing your emotion...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final hasInput = _selectedTab == 0 ? _image != null : _audio != null;
    
    return GradientButton(
      label: _selectedTab == 0 ? 'Analyze Face' : 'Analyze Voice',
      icon: _selectedTab == 0 ? Icons.face_retouching_natural : Icons.graphic_eq,
      onPressed: hasInput
          ? (_selectedTab == 0 ? _analyzeFace : _analyzeVoice)
          : () => _snack('Please select ${_selectedTab == 0 ? 'an image' : 'an audio file'} first'),
      gradient: hasInput ? AppColors.primaryGradient : null,
    );
  }
}
