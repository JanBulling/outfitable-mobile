import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

import '../models/classification_result.dart';
import '../technologies/classification/image_utils.dart';
import '../technologies/classification/classifier.dart';

class TensorflowService {
  Classifier? _classifier;

  Future<void> loadModel(String modelPath, String labelsPath) async {
    if (_classifier != null) return;

    _classifier = Classifier(modelPath, labelsPath);
  }

  Future<ClassificationResult> classifyCameraImage(CameraImage cameraImage) async {
    if (_classifier == null) return ClassificationResult.empty();

    var imgResult = await ImageUtils.convertCameraImage(cameraImage, predictColor: true);

    img.Image? image = imgResult["image"];
    Color? color = imgResult["color"];

    if (image == null) return ClassificationResult.empty();

    ClassificationResult? result = await _classifier!.predict(image);
    result.color = color;

    return result;
  }

  // error, when the classifier is closed and reused
  void close() {
    //_classifier?.close();
  }
}
