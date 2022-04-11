import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/tensorflow_service.dart';
import '../technologies/image/image_utils.dart';

class TensorflowCubit extends Cubit<TensorflowState> {
  final TensorflowService _service;

  TensorflowCubit(this._service) : super(InitialTensorflowState());

  void loadModel() async {
    emit(LoadingModelTensorflowState());

    try {
      print("Loading model...");
      await _service.loadModel(
        "assets/tensorflow/model_mobile.tflite",
        "assets/tensorflow/labels_mobile.txt",
      );
      print("loaded model");

      emit(ModelLoadedTensorflowState());
    } catch (err) {
      emit(ErrorTensorflowState(err.toString()));
    }
  }

  void classifyFrame(CameraImage image) async {
    var bytes = image.planes.map((planes) => planes.bytes).toList();

    try {
      var color = await ImageUtils.predictColor(image);

      List results = await _service.classifyFrame(bytes, image.width, image.height);

      emit(SuccessTensorflowState(results, color));
    } catch (err) {
      emit(ErrorTensorflowState(err.toString()));
    }
  }

  void closeTflite() async {
    await _service.close();
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
  final List results;
  final Color color;
  SuccessTensorflowState(this.results, this.color);
}
