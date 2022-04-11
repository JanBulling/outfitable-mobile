import 'dart:typed_data';

import 'package:tflite/tflite.dart';

class TensorflowService {
  Future<List> classifyFrame(List<Uint8List> bytes, int width, int height) async {
    List? results = await Tflite.runModelOnFrame(
      bytesList: bytes,
      imageWidth: width,
      imageHeight: height,
      rotation: 90,
      imageMean: 127.5,
      imageStd: 127.5,
      threshold: 0.4,
      numResults: 1,
    );

    return results ?? [];
  }

  Future<void> loadModel(String modelPath, String labelsPath) async {
    Tflite.close();

    await Tflite.loadModel(model: modelPath, labels: labelsPath);
  }

  Future close() async {
    await Tflite.close();
  }
}
