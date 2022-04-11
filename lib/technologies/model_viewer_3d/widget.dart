import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import './scene.dart';

typedef void SceneCreatedCallback(Scene scene);

class ModelViewer3d extends StatefulWidget {
  ModelViewer3d({
    Key? key,
    this.interactive = true,
    this.onSceneCreated,
    this.onModelCreated,
  }) : super(key: key);

  final bool interactive;
  final SceneCreatedCallback? onSceneCreated;
  final ModelCreatedCallback? onModelCreated;

  @override
  _ModelViewer3dState createState() => _ModelViewer3dState();
}

class _ModelViewer3dState extends State<ModelViewer3d> {
  late Scene scene;
  late Offset _lastFocalPoint;
  double? _lastZoom;

  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.localFocalPoint;
    _lastZoom = null;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    scene.camera.trackBall(toVector2(_lastFocalPoint), toVector2(details.localFocalPoint), 1.5);
    _lastFocalPoint = details.localFocalPoint;
    if (_lastZoom == null) {
      _lastZoom = scene.camera.zoom;
    } else {
      scene.camera.zoom = _lastZoom! * details.scale;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    scene = Scene(
      onUpdate: () => setState(() {}),
      onModelCreated: widget.onModelCreated,
    );
    // prevent setState() or markNeedsBuild called during build
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      widget.onSceneCreated?.call(scene);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      scene.camera.viewportWidth = constraints.maxWidth;
      scene.camera.viewportHeight = constraints.maxHeight;
      final customPaint = CustomPaint(
        painter: _ModelViewer3dPainter(scene),
        size: Size(constraints.maxWidth, constraints.maxHeight),
      );
      return widget.interactive
          ? GestureDetector(
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              child: customPaint,
            )
          : customPaint;
    });
  }
}

class _ModelViewer3dPainter extends CustomPainter {
  final Scene _scene;
  const _ModelViewer3dPainter(this._scene);

  @override
  void paint(Canvas canvas, Size size) {
    _scene.render(canvas, size);
  }

  // We should repaint whenever the board changes, such as board.selected.
  @override
  bool shouldRepaint(_ModelViewer3dPainter oldDelegate) {
    return true;
  }
}

/// Convert Offset to Vector2
Vector2 toVector2(Offset value) {
  return Vector2(value.dx, value.dy);
}
