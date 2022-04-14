import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/classification_result.dart';

class ClassificationCubit extends Cubit<ClassificationState> {
  bool _isLoading = false;
  int? _mostConfidentType;
  Color _color = Colors.black;
  double _highestConfidence = 0.0;

  final double minConfidence = 0.5;

  ClassificationCubit() : super(LoadingClassificationState());

  void emitLoading() {
    if (!_isLoading) {
      _isLoading = true;
      emit(LoadingClassificationState());
    }
  }

  /// processes the result. The method also saves the highes result.
  void processResult(ClassificationResult predictions) {
    try {
      if (predictions.index == -1) return;

      double confidence = predictions.confidence;
      int type = predictions.index;

      if (confidence < minConfidence) return;

      if (type == _mostConfidentType) {
        _highestConfidence = math.max(_highestConfidence, confidence);
        _color = predictions.color ?? Colors.black;

        emit(SuccessClassificationState(_mostConfidentType!, _color));
        return;
      }

      // tolerance. If there is another clothing with a high confidence, the result switches
      if (confidence > _highestConfidence - 0.25) {
        _highestConfidence = confidence;
        _mostConfidentType = type;
        _color = predictions.color ?? Colors.black;

        emit(SuccessClassificationState(_mostConfidentType!, _color));
      }
    } catch (err) {
      emit(ErrorClassificationState(err.toString()));
    }
  }

  void emitError(String message) {
    emit(ErrorClassificationState(message));
  }
}

// ======= States ===============================================
@immutable
abstract class ClassificationState {}

class LoadingClassificationState extends ClassificationState {}

class ErrorClassificationState extends ClassificationState {
  final String message;
  ErrorClassificationState(this.message);
}

class SuccessClassificationState extends ClassificationState {
  final int resultType;
  final Color color;
  SuccessClassificationState(this.resultType, this.color);
}
