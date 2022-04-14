import 'dart:ui';

class ClassificationResult {
  int index;
  String label;
  double confidence;
  Color? color;

  ClassificationResult({required this.index, required this.label, required this.confidence, this.color});

  factory ClassificationResult.empty() => ClassificationResult(index: -1, label: "None", confidence: 1);

  @override
  bool operator ==(Object o) {
    if (o is ClassificationResult) {
      return (o.index == index && o.confidence == confidence);
    }
    return false;
  }

  @override
  String toString() {
    return "<Category \"" + label + "\" (confidence=" + confidence.toStringAsFixed(3) + ")>";
  }
}
