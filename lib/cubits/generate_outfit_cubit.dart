import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/clothing/outfit.dart';
import '../models/clothing/utils.dart';
import '../models/weather/weather_forecast.dart';
import '../technologies/outfit_generator/outfit_generator.dart';

class GenerateOutfitCubit extends Cubit<OutfitState> {
  final OutfitGenerator _generator;

  GenerateOutfitCubit(this._generator) : super(LoadingOutfitState());

  void generateDailyOutfit(WeatherForecast? weather) async {
    emit(LoadingOutfitState());

    await Future.delayed(Duration(milliseconds: 500));

    try {
      var outfit = await _generator.generateOutfit(weather);
      emit(SuccessOutfitState(outfit));
    } catch (err) {
      emit(ErrorOutfitState(err.toString()));
    }
  }

  void generateRandomOutfit(WeatherForecast? weather, {int style = ClothingStyle.CASUAL}) async {
    emit(LoadingOutfitState());

    await Future.delayed(Duration(milliseconds: 500));

    try {
      var outfit = await _generator.generateOutfit(weather, style: style, random: true);
      emit(SuccessOutfitState(outfit));
    } catch (err) {
      emit(ErrorOutfitState(err.toString()));
    }
  }
}

// ======= States ===============================================
@immutable
abstract class OutfitState {}

class LoadingOutfitState extends OutfitState {}

class ErrorOutfitState extends OutfitState {
  final String message;
  ErrorOutfitState(this.message);
}

class SuccessOutfitState extends OutfitState {
  final Outfit outfit;
  SuccessOutfitState(this.outfit);
}
