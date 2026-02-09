import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:onnxruntime/onnxruntime.dart';
import '../shared/emotions.dart';

class MLService {
  OrtSession? _faceSession;
  Interpreter? _voiceInterpreter;
  bool _isInitialized = false;
  
  // Model type: 'affectnet' (new) or 'fer' (old)
  String _modelType = 'affectnet';
  
  // AffectNet emotion labels (different order from FER+)
  static const List<String> _affectnetLabels = [
    'Angry', 'Contempt', 'Disgust', 'Fear', 'Happy', 'Neutral', 'Sad', 'Surprise'
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize ONNX Runtime Environment
    OrtEnv.instance.init();

    // Try loading the new AffectNet model first (better trained)
    try {
      final modelFile = await _getAssetFile('assets/models/affectnet_model.onnx');
      _faceSession = OrtSession.fromFile(modelFile.path);
      _modelType = 'affectnet';
      print('✅ AffectNet ONNX model loaded');
    } catch (e) {
      print('⚠️ AffectNet ONNX model not found: $e');
      
      // Fall back to original CNN model (TFLite)
      // Note: We are keeping TFLite support for fallback and voice
      /*
      try {
        _faceInterpreter = await Interpreter.fromAsset('assets/models/cnn_model.tflite');
        _modelType = 'fer';
        print('✅ FER model loaded (cnn_model.tflite)');
      } catch (e2) {
        print('⚠️ No face model found: $e2');
      }
      */
    }

    try {
      // Load voice model (LSTM)
      _voiceInterpreter = await Interpreter.fromAsset('assets/models/lstm_model.tflite');
      print('✅ Voice model loaded');
    } catch (e) {
      print('⚠️ Voice model not found: $e');
    }

    _isInitialized = true;
  }

  Future<File> _getAssetFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${(await getTemporaryDirectory()).path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  Future<Map<String, double>> predictFace(String imagePath) async {
    if (_faceSession == null) {
      print('⚠️ Face model not loaded, using mock');
      return Emotions.mockProbs(seed: Emotions.seedFromString(imagePath));
    }
    
    try {
        return await _predictAffectNet(imagePath);
    } catch (e) {
      print('❌ Face prediction error: $e');
      return Emotions.mockProbs(seed: Emotions.seedFromString(imagePath));
    }
  }
  
  /// Predict using AffectNet ONNX model
  /// Input: 1x3x224x224 Float32 Tensor
  /// Output: 1x8 Float32 Tensor (logits)
  Future<Map<String, double>> _predictAffectNet(String imagePath) async {
    final floatInput = await _preprocessForAffectNet(imagePath);
    
    // Create input tensor: [1, 3, 224, 224]
    final shape = [1, 3, 224, 224];
    final inputOrt = OrtValueTensor.createTensorWithDataList(floatInput, shape);
    
    final runOptions = OrtRunOptions();
    // Get input and output names from the session
    // Usually input is 'input_1' or 'data' or 'input'
    // We can infer or just use the first input
    // The usage of inputNames in run() is optional if we pass a map.
    // However, we need to know the input name key.
    
    // Attempt to dynamically get input name if possible via session info?
    // Dart API might not expose session metadata easily in all versions.
    // Standard names: 'input_1' (Keras), 'input' (PyTorch->ONNX).
    // The model is likely 'input_1' based on EfficientNet Keras origin, OR 'input' if PyTorch.
    // EmotiEffLib models are PyTorch usually converted. 
    // Let's try 'input_1' as default, or inspect via try-catch if needed.
    // ACTUALLY: The safest way is to check inputs map if exposed, but OrtSession in Dart 
    // doesn't always expose metadata properties directly in older versions.
    // Let's assume 'input_1' (common).
    
    final inputs = {'input_1': inputOrt};
    
    final List<OrtValue?> outputs;
    try {
        outputs = _faceSession!.run(runOptions, inputs);
    } catch (e) {
        // Retry with 'input' or 'data'?
        print("Run failed with input_1, trying 'input'");
        inputOrt.release(); // Release previous tensor wrapper? No, it's valid.
        final inputs2 = {'input': inputOrt};
        outputs = _faceSession!.run(runOptions, inputs2);
    }
    
    inputOrt.release();
    runOptions.release();

    // Get output (logits)
    // Output is likely [1, 8]
    final outputValue = outputs[0];
    // value is a List (likely List<List<double>> or flat List<double> depending on shape)
    // OrtValueTensor.value returns List usually.
    final rawOutput = outputValue?.value as List; // This might be List<List<double>>
    
    List<double> logits;
    if (rawOutput[0] is List) {
        logits = (rawOutput[0] as List).cast<double>();
    } else {
        logits = rawOutput.cast<double>();
    }
    
    outputValue?.release();

    // Convert logits to map
    final probs = <String, double>{};
    print('🔍 Raw AffectNet Logits:');
    for (int i = 0; i < _affectnetLabels.length; i++) {
        final val = logits[i];
        final label = _affectnetLabels[i];
        probs[label] = val; // Logits
    }
    
    // Apply Softmax
    final softmaxProbs = _softmax(probs);
     print('📊 Softmax Probabilities:');
    softmaxProbs.forEach((k, v) => print('  $k: ${(v * 100).toStringAsFixed(1)}%'));
    
    // Map to FER+ labels
    return _mapToFERLabels(softmaxProbs);
  }
  
  /// Preprocess for AffectNet model: 224x224 RGB, ImageNet normalization, NCHW, Flat
  Future<Float32List> _preprocessForAffectNet(String path) async {
    final bytes = await File(path).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Failed to decode image');

    // 1. Center Crop to square
    final size = math.min(image.width, image.height);
    final x = (image.width - size) ~/ 2;
    final y = (image.height - size) ~/ 2;
    
    final cropped = img.copyCrop(image, x: x, y: y, width: size, height: size);
    
    // 2. Resize to 224x224
    // Use cubic interpolation for better quality
    final resized = img.copyResize(cropped, width: 224, height: 224, interpolation: img.Interpolation.cubic);
    
    // 3. Convert to Float32 List in NCHW format
    // NCHW: [Batch, Channel, Height, Width]
    // Batch = 1
    // Channels = 3 (R, G, B)
    // Height = 224, Width = 224
    
    final float32 = Float32List(1 * 3 * 224 * 224);
    
    // ImageNet stats
    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];
    
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        
        // Normalize
        final r = (pixel.r / 255.0 - mean[0]) / std[0];
        final g = (pixel.g / 255.0 - mean[1]) / std[1];
        final b = (pixel.b / 255.0 - mean[2]) / std[2];
        
        // Fill NCHW (Planar) input
        // Index: c * (H * W) + y * W + x
        // R channel (c=0)
        float32[0 * 224 * 224 + y * 224 + x] = r;
        // G channel (c=1)
        float32[1 * 224 * 224 + y * 224 + x] = g;
        // B channel (c=2)
        float32[2 * 224 * 224 + y * 224 + x] = b;
      }
    }
    
    return float32;
  }
  
  Map<String, double> _mapToFERLabels(Map<String, double> affectnetProbs) {
    final ferProbs = <String, double>{};
    for (final label in Emotions.labels) {
      ferProbs[label] = affectnetProbs[label] ?? 0.0;
    }
    return ferProbs;
  }

  // Softmax helper implementation kept same
  Map<String, double> _softmax(Map<String, double> logits) {
    final values = logits.values.toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final expValues = values.map((v) => math.exp(v - maxVal)).toList();
    final sumExp = expValues.reduce((a, b) => a + b);
    final result = <String, double>{};
    int i = 0;
    for (final label in logits.keys) {
      result[label] = expValues[i] / sumExp;
      i++;
    }
    return result;
  }

  void dispose() {
    _faceSession?.release();
    _voiceInterpreter?.close();
    OrtEnv.instance.release();
    _isInitialized = false;
  }
}
