import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:tflite/tflite.dart';

import '../../cubits/tensorflow_cubit.dart';

class ImageClassifier extends StatefulWidget {
  const ImageClassifier({Key? key}) : super(key: key);

  @override
  State<ImageClassifier> createState() => _ImageClassifierState();
}

class _ImageClassifierState extends State<ImageClassifier> with WidgetsBindingObserver {
  bool _isReadyForClassification = false;
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  double _aspectRatio = 1.5;
  String? _errorMessage;

  /// Initializing the camera, setting the camera controller and starting the image-stream
  void _initCamera() async {
    // get all available cameras of the system
    _cameras ??= await availableCameras();

    if (_cameras == null || _cameras!.isEmpty) {
      setState(() {
        _errorMessage = "Camera could not be initialized. No cameras available";
      });
      return;
    }

    _onNewCameraSelected(_cameras![0]);
  }

  void _onNewCameraSelected(CameraDescription description) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    // register any change in the camera controller
    _controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    await _controller!.initialize();

    // set the controller to initialized after 200ms
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _aspectRatio = _controller!.value.aspectRatio;
      });
    });

    // enable the image stream
    _controller!.startImageStream((image) {
      if (mounted && _isReadyForClassification) {
        _performClassification(image);
      }
    });
  }

  /// Perform the main classification
  void _performClassification(CameraImage image) async {
    _isReadyForClassification = false;

    BlocProvider.of<TensorflowCubit>(context).classifyFrame(image);
  }

  // ======== Lifecycle ===================================================
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    // Loading the tensorflow lite model from assets
    BlocProvider.of<TensorflowCubit>(context).loadModel();

    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);

    _controller?.dispose();

    // Close tensorflow
    //Tflite.close();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.resumed) {
      _onNewCameraSelected(_controller!.description);
    } else if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
    }
  }

  // ======== Ui ==========================================================
  @override
  Widget build(BuildContext context) {
    double detectionArea = MediaQuery.of(context).size.width - 20;

    return BlocListener<TensorflowCubit, TensorflowState>(
      listener: (_, state) {
        if (state is ModelLoadedTensorflowState || state is SuccessTensorflowState) {
          // wait 1.5sec for the next classificaion
          Future.delayed(const Duration(milliseconds: 1500), () => _isReadyForClassification = true);
        }
      },
      child: _controller != null && _controller!.value.isInitialized
          ? CameraPreview(
              _controller!,
              child: Center(
                child: Container(
                  width: detectionArea,
                  height: detectionArea,
                  decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3)),
                ),
              ),
            )
          : AspectRatio(
              aspectRatio: 1 / _aspectRatio,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: Center(
                    child: _errorMessage == null
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_errorMessage!)),
              ),
            ),
    );
  }
}
