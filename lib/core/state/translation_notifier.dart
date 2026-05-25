import 'dart:io';
import 'package:flutter/foundation.dart';

import '../models/prediction_model.dart';
import '../services/translation_service.dart';

enum TranslationStatus { idle, loading, success, error }

class TranslationNotifier extends ChangeNotifier {
  final _service = TranslationService();

  TranslationStatus _status = TranslationStatus.idle;
  PredictionResult? _result;
  String _error = '';
  File? _videoFile;

  TranslationStatus get status  => _status;
  PredictionResult? get result  => _result;
  String            get error   => _error;
  File?             get video   => _videoFile;

  bool get isIdle    => _status == TranslationStatus.idle;
  bool get isLoading => _status == TranslationStatus.loading;
  bool get isSuccess => _status == TranslationStatus.success;
  bool get isError   => _status == TranslationStatus.error;

  Future<void> predict(File video) async {
    _videoFile = video;
    _status = TranslationStatus.loading;
    _result = null;
    _error = '';
    notifyListeners();

    try {
      _result = await _service.predict(video);
      _status = TranslationStatus.success;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = TranslationStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _status = TranslationStatus.idle;
    _result = null;
    _error = '';
    _videoFile = null;
    notifyListeners();
  }
}
