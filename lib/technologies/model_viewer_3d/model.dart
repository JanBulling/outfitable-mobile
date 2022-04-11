import 'package:vector_math/vector_math_64.dart';

import './mesh.dart';
import './scene.dart';

class Model {
  Model({
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
    this.name,
    Mesh? mesh,
    Scene? scene,
    this.parent,
    List<Model>? children,
    this.backfaceCulling = true,
    this.lighting = false,
    this.visiable = true,
    bool normalized = true,
    String? fileName,
    bool isAsset = true,
  }) {
    if (position != null) position.copyInto(this.position);
    if (rotation != null) rotation.copyInto(this.rotation);
    if (scale != null) scale.copyInto(this.scale);
    updateTransform();
    this.mesh = mesh ?? Mesh();
    this.children = children ?? <Model>[];
    for (Model child in this.children) {
      child.parent = this;
    }
    this.scene = scene;

    // load mesh from obj file
    if (fileName != null) {
      loadObj(fileName, normalized, isAsset: isAsset).then((List<Mesh> meshes) {
        if (meshes.length == 1) {
          this.mesh = meshes[0];
        } else if (meshes.length > 1) {
          // multiple Models
          for (Mesh mesh in meshes) {
            add(Model(name: mesh.name, mesh: mesh, backfaceCulling: backfaceCulling, lighting: lighting));
          }
        }
        this.scene?.modelCreated(this);
      });
    } else {
      this.scene?.modelCreated(this);
    }
  }

  /// The local position of this model relative to the parent. Default is Vector3(0.0, 0.0, 0.0). updateTransform after you change the value.
  final Vector3 position = Vector3(0.0, 0.0, 0.0);

  /// The local rotation of this model relative to the parent. Default is Vector3(0.0, 0.0, 0.0). updateTransform after you change the value.
  final Vector3 rotation = Vector3(0.0, 0.0, 0.0);

  /// The local scale of this model relative to the parent. Default is Vector3(1.0, 1.0, 1.0). updateTransform after you change the value.
  final Vector3 scale = Vector3(1.0, 1.0, 1.0);

  /// The name of this model.
  String? name;

  /// The scene of this model.
  Scene? _scene;
  Scene? get scene => _scene;
  set scene(Scene? value) {
    _scene = value;
    for (Model child in children) {
      child.scene = value;
    }
  }

  /// The parent of this model.
  Model? parent;

  /// The children of this model.
  late List<Model> children;

  /// The mesh of this model
  late Mesh mesh;

  /// The backface will be culled without rendering.
  bool backfaceCulling;

  /// Enable basic lighting, default to false.
  bool lighting;

  /// Is this model visiable.
  bool visiable;

  /// The transformation of the model in the scene, including position, rotation, and scaling.
  final Matrix4 transform = Matrix4.identity();

  void updateTransform() {
    final Matrix4 m = Matrix4.compose(
        position, Quaternion.euler(radians(rotation.y), radians(rotation.x), radians(rotation.z)), scale);
    transform.setFrom(m);
  }

  /// Add a child
  void add(Model model) {
    assert(model != this);
    model.scene = scene;
    model.parent = this;
    children.add(model);
  }

  /// Remove a child
  void remove(Model model) {
    children.remove(model);
  }

  /// Find a child matching the name
  Model? find(Pattern name) {
    for (Model child in children) {
      if (child.name != null && (name as RegExp).hasMatch(child.name!)) return child;
      final Model? result = child.find(name);
      if (result != null) return result;
    }
    return null;
  }
}
