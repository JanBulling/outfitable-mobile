import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outfitable_mobile_app/models/clothing/clothing.dart';

class AddClothingCubit extends Cubit<AddClothingState> {
  Clothing? _clothing;

  AddClothingCubit() : super(InitialAddClothingState());

  void init(Map<String, dynamic>? args) {
    if (args == null) {
      emit(UpdatedClothingState(Clothing()));
      return;
    }

    _clothing = Clothing.fromType(args["type"]);
    _clothing!.color = args["color"] ?? Colors.black;

    emit(UpdatedClothingState(_clothing!));
  }

  void changeType(int newType, {bool changeAttributes = true}) {
    if (_clothing == null) {
      _clothing = Clothing.fromType(newType);
      emit(UpdatedClothingState(_clothing!));
      return;
    }

    if (!changeAttributes) {
      _clothing!.type = newType;
      emit(UpdatedClothingState(_clothing!));
      return;
    }

    Color color = _clothing!.color;

    _clothing = Clothing.fromType(newType);
    _clothing!.color = color;
    emit(UpdatedClothingState(_clothing!));
  }

  void changeStyle(int style) {
    if (_clothing == null) {
      _clothing = Clothing();
      _clothing!.styles.add(style);
      emit(UpdatedClothingState(_clothing!));
      return;
    }

    if (_clothing!.styles.contains(style)) {
      _clothing!.styles.remove(style);
    } else {
      _clothing!.styles.add(style);
    }

    emit(UpdatedClothingState(_clothing!));
  }

  void changeTemperautr(int temperature) {
    if (_clothing == null) {
      _clothing = Clothing();
      _clothing!.temperatures.add(temperature);
      emit(UpdatedClothingState(_clothing!));
      return;
    }

    if (_clothing!.temperatures.contains(temperature)) {
      _clothing!.temperatures.remove(temperature);
    } else {
      _clothing!.temperatures.add(temperature);
    }

    emit(UpdatedClothingState(_clothing!));
  }

  void changeColor(Color newColor) {
    if (_clothing == null) {
      _clothing = Clothing();
      _clothing!.color = newColor;
      emit(UpdatedClothingState(_clothing!));
      return;
    }

    _clothing!.color = newColor;
    emit(UpdatedClothingState(_clothing!));
  }
}

// ======= States ===============================================
@immutable
abstract class AddClothingState {}

class InitialAddClothingState extends AddClothingState {}

class UpdatedClothingState extends AddClothingState {
  final Clothing clothing;
  UpdatedClothingState(this.clothing);
}
