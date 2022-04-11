import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:outfitable_mobile_app/services/closet_service.dart';
import 'package:outfitable_mobile_app/services/outfit_generator_service.dart';
import 'package:outfitable_mobile_app/services/tensorflow_service.dart';
import 'package:outfitable_mobile_app/technologies/outfit_generator/outfit_generator.dart';

import '../repositories/weather_repository.dart';
import '../services/weather_service.dart';

final injector = GetIt.instance;

void init() {
  // ===== Core =============================================================
  // Http client
  injector.registerLazySingleton<Dio>(() => Dio());

  // ====== Repositories and Services =======================================
  injector.registerLazySingleton<WeatherService>(() => WeatherService(injector()));
  injector.registerLazySingleton<WeatherRepository>(() => WeatherRepository(injector()));

  injector.registerLazySingleton<ClosetService>(() => ClosetService());

  injector.registerLazySingleton<TensorflowService>(() => TensorflowService());

  injector.registerLazySingleton<OutfitGeneratorService>(() => OutfitGeneratorService());
  injector.registerLazySingleton<OutfitGenerator>(() => OutfitGenerator(injector()));
}
