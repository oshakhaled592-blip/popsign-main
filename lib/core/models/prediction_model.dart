class PredictionItem {
  final String label;
  final String labelAr;
  final double score;

  const PredictionItem({
    required this.label,
    required this.labelAr,
    required this.score,
  });

  factory PredictionItem.fromJson(Map<String, dynamic> json) {
    return PredictionItem(
      label:   (json['label']    ?? json['word']  ?? json['class'] ?? '').toString(),
      labelAr: (json['label_ar'] ?? json['word_ar'] ?? json['translation'] ?? '').toString(),
      score:   ((json['score'] ?? json['confidence'] ?? json['probability'] ?? 0) as num).toDouble(),
    );
  }

  String get percent => '${(score * 100).toStringAsFixed(1)}%';

  PredictionItem withScore(double newScore) =>
      PredictionItem(label: label, labelAr: labelAr, score: newScore);
}

class PredictionResult {
  final List<PredictionItem> predictions;

  const PredictionResult({required this.predictions});

  PredictionItem get top => predictions.first;

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final raw = json['predictions']
        ?? json['top_predictions']
        ?? json['results']
        ?? [];

    final list = (raw as List)
        .map((e) => PredictionItem.fromJson(e as Map<String, dynamic>))
        .toList();

    // normalize scores so they sum to 100%
    final total = list.fold<double>(0, (sum, item) => sum + item.score);
    final normalized = total > 0
        ? list.map((item) => item.withScore(item.score / total)).toList()
        : list;

    return PredictionResult(predictions: normalized);
  }
}
