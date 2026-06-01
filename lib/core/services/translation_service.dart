import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/prediction_model.dart';

class TranslationService {
  static const _base = 'https://ahmedmoasd-sign2gpt.hf.space';
  static const _timeout = Duration(seconds: 90);

  Future<PredictionResult> predict(File video, {int topK = 5}) async {
    final uri = Uri.parse('$_base/predict_ar?top_k=$topK');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', video.path));

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Server error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PredictionResult.fromJson(json);
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
    final res = await http
        .get(Uri.parse('$_base/classes'))
        .timeout(const Duration(seconds: 15));

    debugPrint('CLASSES status: ${res.statusCode}');
    debugPrint('CLASSES body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Server error ${res.statusCode}: ${res.body}');
    }

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
    return [];
  }
}
