 import 'dart:math';

class Emotions {
  // FER-Plus 8-class emotions (matches the pre-trained model vicksam/fer-model)
  // Order: Angry, Disgust, Fear, Happy, Sad, Surprise, Contempt, Neutral
  static const List<String> labels = [
    'Angry', 'Disgust', 'Fear', 'Happy', 'Sad', 'Surprise', 'Contempt', 'Neutral'
  ];

  static const Map<String, String> emoji = {
    'Angry': '😠',
    'Disgust': '🤢',
    'Fear': '😨',
    'Happy': '😊',
    'Sad': '😢',
    'Surprise': '😲',
    'Contempt': '😏',
    'Neutral': '😐',
  };

  static int seedFromString(String s) {
    // Simple deterministic hash -> int seed
    int h = 0;
    for (final code in s.codeUnits) {
      h = 0x1fffffff & (h + code);
      h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
      h ^= (h >> 6);
    }
    h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
    h ^= (h >> 11);
    h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
    return h & 0x7fffffff;
  }

  static Map<String, double> mockProbs({int? seed}) {
    final rand = Random(seed);
    // Weights corresponding to new label order:
    // Angry, Disgust, Fear, Happy, Sad, Surprise, Contempt, Neutral
    // Bias toward Neutral and Happy for general use
    final weights = [0.5, 0.4, 0.4, 2.5, 0.6, 1.2, 0.3, 2.0];
    final values = List<double>.generate(labels.length, (i) => rand.nextDouble() * weights[i]);
    final sum = values.fold<double>(0, (a, b) => a + b);
    final probs = <String, double>{};
    for (int i = 0; i < labels.length; i++) {
      probs[labels[i]] = values[i] / (sum == 0 ? 1 : sum);
    }
    return probs;
  }

  static Map<String, double> oneHot(String label) {
    return {for (final l in labels) l: l == label ? 1.0 : 0.0};
  }

  static String argMax(Map<String, double> probs) {
    String best = labels.first;
    double bestVal = -1;
    probs.forEach((k, v) {
      if (v > bestVal) {
        best = k;
        bestVal = v;
      }
    });
    return best;
  }

  static Map<String, double> combineWeighted(Map<String, double>? a, Map<String, double>? b, {double wA = 0.6, double wB = 0.4}) {
    final result = <String, double>{for (final l in labels) l: 0.0};
    if (a != null) {
      for (final l in labels) {
        result[l] = result[l]! + wA * (a[l] ?? 0.0);
      }
    }
    if (b != null) {
      for (final l in labels) {
        result[l] = result[l]! + wB * (b[l] ?? 0.0);
      }
    }
    // normalize
    final sum = result.values.fold<double>(0, (s, v) => s + v);
    if (sum > 0) {
      for (final l in labels) {
        result[l] = result[l]! / sum;
      }
    }
    return result;
  }

  static String getEmoji(String emotion) {
    return emoji[emotion] ?? '😊';
  }
}
