import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/clothing/clothing.dart';
import '../services/closet_service.dart';

class ClosetCubit extends Cubit<ClosetState> {
  final ClosetService _service;

  ValueListenable<Box<Clothing>>? _closetListenable;

  ClosetCubit(this._service) : super(LoadingClosetState());

  void monitorClosetItems() {
    emit(LoadingClosetState());

    try {
      _closetListenable = _service.listenable();

      _closetListenable!.addListener(_closetChangeListener);

      _closetChangeListener(); // First call. Necesary to emit the first state
    } catch (err) {
      emit(ErrorClosetState(err.toString()));
    }
  }

  void _closetChangeListener() {
    Map<int, int> clothing = {};

    for (Clothing c in _closetListenable!.value.values) {
      clothing[c.type] = (clothing[c.type] ?? 0) + 1;
    }

    emit(SuccessClosetState(clothing));
  }

  @override
  Future<void> close() {
    _closetListenable?.removeListener(_closetChangeListener);
    return super.close();
  }
}

// ======= States ===============================================
@immutable
abstract class ClosetState {}

class LoadingClosetState extends ClosetState {}

class ErrorClosetState extends ClosetState {
  final String message;
  ErrorClosetState(this.message);
}

class SuccessClosetState extends ClosetState {
  final Map<int, int> clothing;
  SuccessClosetState(this.clothing);
}
