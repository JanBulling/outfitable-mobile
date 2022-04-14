import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/classification_result.dart';
import '../services/tensorflow_service.dart';

class TensorflowCubit extends Cubit<TensorflowState> {
  final TensorflowService _service;

  TensorflowCubit(this._service) : super(InitialTensorflowState());

  void loadModel() async {
    emit(LoadingModelTensorflowState());

    try {
      String modelName = "outfitable_v2";

      await _service.loadModel(
        "tensorflow/model_$modelName.tflite",
        "assets/tensorflow/labels_$modelName.txt",
      );

      //+ DEPUG PRINT
      print("[TensorflowCubit] - Model '$modelName' loaded successfully.");

      emit(ModelLoadedTensorflowState());
    } catch (err) {
      emit(ErrorTensorflowState(err.toString()));
    }
  }

  void classifyFrame(CameraImage image) async {
    try {
      var results = await _service.classifyCameraImage(image);

      //+ DEPUG PRINT
      print(results);

      emit(SuccessTensorflowState(results));
    } catch (err) {
      emit(ErrorTensorflowState(err.toString()));
    }
  }

  @override
  Future<void> close() {
    _service.close();
    return super.close();
  }
}

// ======= States ===============================================
@immutable
abstract class TensorflowState {}

class InitialTensorflowState extends TensorflowState {}

class LoadingModelTensorflowState extends TensorflowState {}

class LoadingTensorflowState extends TensorflowState {}

class ErrorTensorflowState extends TensorflowState {
  final String message;
  ErrorTensorflowState(this.message);
}

class ModelLoadedTensorflowState extends TensorflowState {}

class SuccessTensorflowState extends TensorflowState {
  final ClassificationResult results;
  SuccessTensorflowState(this.results);
}
