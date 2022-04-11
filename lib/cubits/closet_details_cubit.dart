import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/clothing/clothing.dart';
import '../services/closet_service.dart';

class ClosetDetailsCubit extends Cubit<ClosetDetailsState> {
  final ClosetService _closetService;

  ClosetDetailsCubit(this._closetService) : super(LoadingClosetDetailsState());

  void loadClothing(int type) {
    try {
      List<Clothing> cloth = _closetService.findClothingType(type);
      emit(SuccessClosetDetailsState(cloth));
    } catch (err) {
      emit(ErrorClosetDetailsState(err.toString()));
    }
  }

  void deleteClothing(Clothing clothing) async {
    final int type = clothing.type;

    emit(LoadingClosetDetailsState());

    try {
      await _closetService.delete(clothing: clothing);

      loadClothing(type);
    } catch (err) {
      emit(ErrorClosetDetailsState(err.toString()));
    }
  }
}

// ======= States ===============================================
@immutable
abstract class ClosetDetailsState {}

class LoadingClosetDetailsState extends ClosetDetailsState {}

class SuccessClosetDetailsState extends ClosetDetailsState {
  final List<Clothing> clothing;
  SuccessClosetDetailsState(this.clothing);
}

class ErrorClosetDetailsState extends ClosetDetailsState {
  final String message;
  ErrorClosetDetailsState(this.message);
}
