import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/weather/weather_forecast_response.dart';
import '../repositories/weather_repository.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository _repository;

  WeatherCubit(this._repository) : super(LoadingWeatherState());

  void getWeather() async {
    emit(LoadingWeatherState());

    try {
      var weather = await _repository.getWeatherForecast();
      emit(SuccessWeatherState(weather));
    } catch (err) {
      emit(ErrorWeatherState(err.toString()));
    }
  }
}

// ======= States ===============================================
@immutable
abstract class WeatherState {}

class LoadingWeatherState extends WeatherState {}

class ErrorWeatherState extends WeatherState {
  final String message;
  ErrorWeatherState(this.message);
}

class SuccessWeatherState extends WeatherState {
  final WeatherForecastResponse weather;
  SuccessWeatherState(this.weather);
}
