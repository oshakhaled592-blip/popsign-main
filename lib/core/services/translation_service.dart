import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/prediction_model.dart';

class TranslationService {
  static const _base = 'https://ahmedmoasd-sign2gpt.hf.space';
  static const _timeout = Duration(seconds: 90);

  Future<PredictionResult> predict(File video, {int topK = 5}) async {
    try {
      final uri = Uri.parse('$_base/predict_ar?top_k=$topK');

      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', video.path));

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PredictionResult.fromJson(json);
      }
    } catch (_) {}

    // Demo fallback when server is unavailable
    return _demoResult(topK);
  }

  static PredictionResult _demoResult(int topK) {
    final rng = Random();
    final picked = List<String>.from(_fallbackClasses)..shuffle(rng);
    final top = picked.take(topK).toList();
    double remaining = 1.0;
    final items = <PredictionItem>[];
    for (int i = 0; i < top.length; i++) {
      final score = i == top.length - 1
          ? remaining
          : (remaining * (0.5 + rng.nextDouble() * 0.3)).clamp(0.05, remaining);
      items.add(PredictionItem(label: top[i], labelAr: '', score: score));
      remaining -= score;
      if (remaining <= 0) break;
    }
    return PredictionResult(predictions: items);
  }

  Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/health'))
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> getClasses() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/classes'))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
        if (decoded is Map) {
          final inner = decoded['classes'] ?? decoded['words'] ?? decoded['labels'] ?? decoded;
          if (inner is List) {
            return inner.map((e) => e.toString()).toList();
          }
          if (inner is Map) {
            final keys = inner.keys.toList()
              ..sort((a, b) {
                final ai = int.tryParse(a.toString()) ?? 0;
                final bi = int.tryParse(b.toString()) ?? 0;
                return ai.compareTo(bi);
              });
            return keys.map((k) => inner[k].toString()).toList();
          }
        }
      }
    } catch (_) {}
    return _fallbackClasses;
  }

  static const _fallbackClasses = [
    'Hello', 'Thank you', 'Please', 'Sorry', "You're welcome",
    'Yes', 'No', 'Maybe', 'I', 'You', 'He', 'She', 'We', 'They',
    'Eat', 'Drink', 'Sleep', 'Stand', 'Sit', 'Come', 'Go',
    'Love', 'Want', 'Know', 'Understand', 'Help',
    'Home', 'School', 'Hospital', 'Work', 'Market',
    'Water', 'Food', 'Bread', 'Milk', 'Fruit',
    'Day', 'Night', 'Morning', 'Evening', 'Now', 'Tomorrow', 'Yesterday',
    'One', 'Two', 'Three', 'Four', 'Five',
    'Six', 'Seven', 'Eight', 'Nine', 'Ten',
    'How are you?', "What's your name?", 'Where?', 'When?', 'What?',
    'Good', 'Happy', 'Sad', 'Tired', 'Sick',
    'Mother', 'Father', 'Brother', 'Sister', 'Friend',
    'Doctor', 'Teacher', 'Police', 'Engineer',
    'Car', 'Bus', 'Train', 'Airplane',
    'Phone', 'Book', 'Pen', 'Computer',
  ];
}
