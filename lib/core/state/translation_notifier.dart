import 'dart:io';
import 'package:flutter/foundation.dart';

import '../models/prediction_model.dart';
import '../services/translation_service.dart';

enum TranslationStatus { idle, loading, success, error }
enum ServerStatus { unknown, online, offline }

class TranslationNotifier extends ChangeNotifier {
  final _service = TranslationService();

  TranslationStatus _status = TranslationStatus.idle;
  PredictionResult? _result;
  String _error = '';
  File? _videoFile;

  ServerStatus _serverStatus = ServerStatus.unknown;
  List<String> _classes = [];
  bool _classesLoading = false;

  // accumulated sentence
  final List<PredictionItem> _sentence = [];

  TranslationStatus  get status         => _status;
  PredictionResult?  get result         => _result;
  String             get error          => _error;
  File?              get video          => _videoFile;
  ServerStatus       get serverStatus   => _serverStatus;
  List<String>       get classes        => _classes;
  bool               get classesLoading => _classesLoading;
  List<PredictionItem> get sentence     => List.unmodifiable(_sentence);

  bool get isIdle    => _status == TranslationStatus.idle;
  bool get isLoading => _status == TranslationStatus.loading;
  bool get isSuccess => _status == TranslationStatus.success;
  bool get isError   => _status == TranslationStatus.error;

  Future<void> checkHealth() async {
    _serverStatus = ServerStatus.unknown;
    notifyListeners();
    final ok = await _service.checkHealth();
    _serverStatus = ok ? ServerStatus.online : ServerStatus.offline;
    notifyListeners();
  }

  Future<void> loadClasses() async {
    _classesLoading = true;
    notifyListeners();
    try {
      _classes = await _service.getClasses();
    } catch (_) {}
    _classesLoading = false;
    notifyListeners();
  }

  Future<void> predict(File video) async {
    _videoFile = video;
    _status = TranslationStatus.loading;
    _result = null;
    _error = '';
    notifyListeners();

    try {
      _result = await _service.predict(video);
      _status = TranslationStatus.success;
      _sentence.add(_result!.top);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = TranslationStatus.error;
    }

    notifyListeners();
  }

  void removeFromSentence(int index) {
    if (index >= 0 && index < _sentence.length) {
      _sentence.removeAt(index);
      notifyListeners();
    }
  }

  void clearSentence() {
    _sentence.clear();
    _status = TranslationStatus.idle;
    _result = null;
    _error = '';
    _videoFile = null;
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
