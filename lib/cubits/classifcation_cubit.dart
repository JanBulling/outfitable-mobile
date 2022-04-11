import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassificationCubit extends Cubit<ClassificationState> {
  bool _isLoading = false;
  int? _mostConfidentType;
  Color? _color;
  double _highestConfidence = 0.0;

  ClassificationCubit() : super(LoadingClassificationState());

  void emitLoading() {
    if (!_isLoading) {
      _isLoading = true;
      emit(LoadingClassificationState());
    }
  }

  void processResult(List classificationResults, Color color) {
    try {
      if (classificationResults.isEmpty) return;

      Map result = classificationResults[0];

      int currentType = result["index"] ?? -1;
      double confidence = result["confidence"] ?? -1.0;

      if (currentType == _mostConfidentType) {
        _highestConfidence = math.max(_highestConfidence, confidence);
        _color = color;

        emit(SuccessClassificationState(_mostConfidentType!, _color!));
        return;
      }

      if (confidence > _highestConfidence - 0.15) {
        _highestConfidence = confidence;
        _mostConfidentType = currentType;
        _color = color;

        emit(SuccessClassificationState(_mostConfidentType!, _color!));
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
