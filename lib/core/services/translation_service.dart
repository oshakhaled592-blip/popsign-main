import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/prediction_model.dart';

class TranslationService {
  static const _base = 'https://ahmedmoasd-sign2gpt.hf.space';
  static const _newBase = 'http://91.108.113.135';
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
          .get(Uri.parse('$_newBase/health'))
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
    'مرحبا', 'السلام عليكم', 'شكرا', 'عفوا', 'من فضلك',
    'نعم', 'لا', 'ربما', 'أنا', 'أنت', 'هو', 'هي', 'نحن', 'هم',
    'أكل', 'شرب', 'نوم', 'وقف', 'اجلس', 'تعال', 'اذهب',
    'أحب', 'أريد', 'أعرف', 'أفهم', 'أساعد',
    'بيت', 'مدرسة', 'مستشفى', 'مسجد', 'سوق',
    'ماء', 'طعام', 'خبز', 'حليب', 'فاكهة',
    'يوم', 'ليل', 'صباح', 'مساء', 'الآن', 'غداً', 'أمس',
    'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة',
    'ستة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة',
    'كيف حالك؟', 'ما اسمك؟', 'أين؟', 'متى؟', 'ماذا؟',
    'جيد', 'سعيد', 'حزين', 'متعب', 'مريض',
    'أم', 'أب', 'أخ', 'أخت', 'صديق',
    'طبيب', 'معلم', 'شرطي', 'مهندس',
    'سيارة', 'حافلة', 'قطار', 'طائرة',
    'هاتف', 'كتاب', 'قلم', 'كمبيوتر',
  ];
}
