import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:outfitable_mobile_app/models/classification_result.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  /// The interpreter used to run the Tensorflow-Lite model
  Interpreter? _interpreter;

  /// List of all the labels
  List<String>? _labels;

  /// Input and output shape of the model
  List<int>? _inputShape, _outputShape;

  /// Input and output type of the model. Mostly [TfLiteType.uint8] or [TfLiteType.float32]
  TfLiteType? _inputType, _outputType;

  /// Processor for getting the probability data from the results
  SequentialProcessor<TensorBuffer>? _probabilityProcessor;

  /// Image Mean and standard deviation
  double imgStd, imgMean;

  /// Creates a classifier, which can run a tensorflow lite model for image classification
  ///
  /// Params:
  ///   - [modelPath] path to the model. See [Colassifier.loadModel] for more information
  ///   - [labelsPath] path to the labels. See [Colassifier.loadLabels] for more information
  ///   - [imgMean] image mean (default 127.5)
  ///   - [imgStd] image standard deviation (default 127.5)
  Classifier(String modelPath, String labelsPath, {this.imgMean = 127.5, this.imgStd = 127.5}) {
    loadModel(modelPath);
    loadLabels(labelsPath);
  }

  Interpreter? get interpreter => _interpreter;
  List<String>? get labels => _labels;

  /// Loading the Model from the [modelPath] and using [threads] to run the model.
  ///
  /// If the model is saved in "assets/tensorflow/model.tflit", the [modelPath]
  /// should be "tensorflow/model.tflite" WITHOUT the "asset"
  ///
  /// This method also sets the input- adn output shapes and types
  void loadModel(String modelPath, {int threads = 1}) async {
    try {
      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: InterpreterOptions()..threads = threads,
      );

      _inputShape = _interpreter!.getInputTensor(0).shape;
      _outputShape = _interpreter!.getOutputTensor(0).shape;
      _inputType = _interpreter!.getInputTensor(0).type;
      _outputType = _interpreter!.getOutputTensor(0).type;

      var normalization = _inputType == TfLiteType.uint8 ? NormalizeOp(0, 255) : NormalizeOp(0, 1);

      _probabilityProcessor = TensorProcessorBuilder().add(normalization).build();

      print("[Classifier] - Loaded Model '$modelPath' successfully");
      print("[Classifier] - Iput: $_inputType, $_inputShape");
      print("[Classifier] - Output: $_outputType, $_outputShape");
    } catch (err) {
      print("[Classifier] - Error loading Model $modelPath: $err");
    }
  }

  /// Loading the labels from [labelsPath]
  ///
  /// If the Labels are saved in "assets/tensorflow/labels.txt", the [labelsPath]
  /// should be "assets/tensorflow/labels.txt.
  void loadLabels(String labelsPath) async {
    try {
      _labels = await FileUtil.loadLabels(labelsPath);
    } catch (err) {
      print("[Classifier] - Error loading Labels $labelsPath: $err");
    }
  }

  /// Preproccess the [image]
  ///
  /// The image gets croped, scaled, rotated and normalized
  TensorImage _preProcessImage(TensorImage image) {
    int cropSize = math.min(image.height, image.width);

    var normalization = _inputType == TfLiteType.uint8 ? NormalizeOp(0, 1) : NormalizeOp(imgMean, imgStd);

    var processor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(_inputShape![1], _inputShape![2], ResizeMethod.NEAREST_NEIGHBOUR))
        .add(Rot90Op())
        .add(normalization)
        .build();

    return processor.process(image);
  }

  /// Runs the [Interpreter] on the input [image]
  ///
  /// Firstly the image gets converted into a [TensorImage]. This image is then croped, scaled
  /// and rotated to be in the correct format for image classification (Square, 224x224pxl for MobileNet)
  /// Then the interpreter is run.
  /// The results finally gets converted into all the labels and confidences and the one with the
  /// highest confindece is returend as an [ClassificationResult]
  Future<ClassificationResult> predict(img.Image image) async {
    if (_interpreter == null || _labels == null) return ClassificationResult.empty();

    TensorImage input = TensorImage(_inputType!);
    input.loadImage(image);
    input = _preProcessImage(input);

    TensorBuffer output = TensorBuffer.createFixedSize(_outputShape!, _outputType!);

    _interpreter!.run(input.buffer, output.getBuffer());

    Map<String, double> labeledProb =
        TensorLabel.fromList(_labels!, _probabilityProcessor!.process(output)).getMapWithFloatValue();

    List<MapEntry<String, double>> predictions = labeledProb.entries.toList();

    double highestProbability = 0.0;
    int probableIndex = 0;

    for (int i = 0; i < predictions.length; i++) {
      if (predictions[i].value > highestProbability) {
        highestProbability = predictions[i].value;
        probableIndex = i;
      }
    }

    var result = predictions[probableIndex];

    ClassificationResult prediction = ClassificationResult(
      index: probableIndex,
      label: result.key,
      confidence: result.value,
    );

    return prediction;
  }

  /// Closing the interpreter
  void close() {
    _interpreter?.close();
  }
}
