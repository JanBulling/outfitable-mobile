import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/clothing/clothing.dart';
import '../../models/clothing/utils.dart';
import '../../models/clothing/outfit.dart';
import '../../models/weather/weather_forecast.dart';
import '../../services/outfit_generator_service.dart';
import '../local_storage/database.dart';

class OutfitGenerator {
  static String messageTooCold = "Outfit could be too cold in the morning";
  static String messageTooWarm = "Outfit could be too warm in the midday";
  static String messageTooColdRain = "Outfit could be too cold, because of rain";

  static const int windThreshold = 60;

  OutfitGenerator(this._service);

  /// Service for database requests (find clothing from the closet, caching)
  final OutfitGeneratorService _service;

  /// Random number generator. Used for getting a random outfit every day
  late math.Random _random;

  ///
  /// ---------------------------------------------------------------------------------
  /// ----------- Algorithm for generating a random outfit every day ------------------
  /// ---------------------------------------------------------------------------------
  /// @Version: 1     @Auhor: Jan Bulling     @Date: 06.04.2022
  ///
  /// [weather] - required, nullable
  /// the weather is used to determin the current temperature and warmingness the
  /// outfit should have. The algorithm takes rain, wind, snow, average-temperature,
  /// max-temperarure and min-temperature into consideration.
  /// if null: the current temperature is approximated with the current month we
  ///   are in.
  ///
  /// [style] - default ClothingStyle.CASUAL:
  /// the style of the outfit
  ///
  /// [random] - default false:
  /// if false: if run on the same day, you always will get the same result
  /// if true: a truly new random outfit is generated. The outfit is NOT saved in
  ///   cache and is not available on the next app-start
  ///
  Future<Outfit> generateOutfit(
    WeatherForecast? weather, {
    int style = ClothingStyle.CASUAL,
    bool random = false,
  }) async {
    Outfit outfit = Outfit();

    int seed = _generateDailySeed();
    print("Seed: $seed");

    // Check, if the outfit of this day is already in cache. If it is, the cached outfit is
    // immediately returned.
    // Only runs, if the outfit is not truely random
    if (random == false) {
      var cacheOutfit = await _getFromCache(seed);

      if (cacheOutfit != null) {
        print("Outfit from Cache: $cacheOutfit");
        return cacheOutfit;
      }
    }

    _random = random ? math.Random() : math.Random(seed);

    // ------ Determin temperature category -------------------------------------------
    int temperature;

    // if there is no weather-data, the temperature gets approximated with the current
    // month. Otherwise, an algorithm is determining the temperature-category
    if (weather == null) {
      temperature = _getTemperatureFromMonth();

      outfit.message = "Not sure if the outfit fits perfectky. No Weather data available.";
      outfit.alertionType = AlertionType.OPTIMAL;
    } else {
      temperature = _getTemperatureCategory(weather);

      if (weather.maxWindSpeed > windThreshold) {
        outfit.icon = Icons.air;
        outfit.message = "It is stormy today. Take a jacket!";
        outfit.alertionType = AlertionType.OPTIMAL;
      }

      if (weather.rain) {
        outfit.icon = Icons.water_drop;
        outfit.message = "It is raining today. Take a jacket!";
        outfit.alertionType = AlertionType.OPTIMAL;
      }

      if (weather.snow) {
        outfit.icon = Icons.snowing;
        outfit.message = "It is snowing today. Take a jacket!";
        outfit.alertionType = AlertionType.OPTIMAL;
      }
    }

    print("temperature: ${temperature}");

    // --------------------------------------------------------------------------------
    // ------ Generate top-clothing part ----------------------------------------------
    // --------------------------------------------------------------------------------
    List<Clothing> topPartList = _service.findClothing(temperature, ClothingPart.TOP_PART, style);

    // if the list is empty, the algorithm tries to find a piece with a simular, but not
    // optimal temperature.
    for (int i = 1; i <= 2; i++) {
      if (topPartList.isNotEmpty) break;

      Map<String, dynamic> mostSimularTemperature = _getSimularTemperature(temperature, i);

      if (mostSimularTemperature["temp"] == null) break;

      topPartList = _service.findClothing(mostSimularTemperature["temp"], ClothingPart.TOP_PART, style);
      outfit.alertionType = mostSimularTemperature["alertion"];
    }

    // if the list is still empty,
    // If it can't succeed, a message (type: AlertionType.ERROR) is shown.
    if (topPartList.isEmpty) {
      int closestStyle = _getClosestStyle(style);
      topPartList = _service.findClothing(temperature, ClothingPart.TOP_PART, closestStyle);

      if (topPartList.isNotEmpty) {
        outfit.message = "Not exactly the style you wanted, but it is the best, we could find.";
        outfit.alertionType = AlertionType.ERROR;
      } else {
        outfit.message = "No Outfit could be generated because there is no fitting piece for you.";
        outfit.alertionType = AlertionType.ERROR;
      }
    }

    print("top Parts: ${topPartList.length}");

    // Pick randomly one of the top-parts
    Clothing topPart;
    int length = topPartList.length;
    if (length > 0) {
      int randomIndex = _random.nextInt(length);

      topPart = topPartList[randomIndex];
      outfit.upperClothing = topPart;
    } else {
      return outfit; // TODO: not sure, maybe pick random pants??
    }

    // --------------------------------------------------------------------------------
    // ------ Find matching lower-part ------------------------------------------------
    // --------------------------------------------------------------------------------
    List<Clothing> lowerPartList = _service.findClothing(temperature, ClothingPart.LOWER_PART, style);

    // if the list is empty, the algorithm tries to find a piece with a simular, but not
    // optimal temperature.
    for (int i = 1; i <= 2; i++) {
      if (lowerPartList.isNotEmpty) break;

      Map<String, dynamic> mostSimularTemperature = _getSimularTemperature(temperature, i);

      if (mostSimularTemperature["temp"] == null) break;

      lowerPartList = _service.findClothing(mostSimularTemperature["temp"], ClothingPart.LOWER_PART, style);
      //outfit.alertionType = mostSimularTemperature["alertion"]; // No message - top-part makes a bigger difference
    }

    // if the list is still empty,
    // If it can't succeed, a message (type: AlertionType.ERROR) is shown.
    if (lowerPartList.isEmpty) {
      int closestStyle = _getClosestStyle(style);
      lowerPartList = _service.findClothing(temperature, ClothingPart.LOWER_PART, closestStyle);

      if (lowerPartList.isNotEmpty) {
        outfit.message = "Not exactly the style you wanted, but it is the best, we could find.";
        outfit.alertionType = AlertionType.ERROR;
      } else {
        outfit.message = "No Outfit could be generated because there is no fitting piece for you.";
        outfit.alertionType = AlertionType.ERROR;
      }
    }

    print("lower Parts: ${lowerPartList.length}");

    // Asigning scores to every outfit combination and find the colors, that fit
    // together the best.
    int maxScoreIndex = 0;
    double maxScore = 0;
    for (int i = 0; i < lowerPartList.length; i++) {
      double score = _calculateOutfitScore(topPart.color, lowerPartList[i].color);

      if (score > maxScore) {
        maxScore = score;
        maxScoreIndex = i;
      }
    }

    outfit.lowerClothing = lowerPartList[maxScoreIndex];

    // save outfit as it is in cache. Only do that, when the outfit is generated the first
    // time for this day
    if (random == false) {
      _saveInCache(outfit, seed);
    }

    return outfit;
  }

  // ============= Helper Methods =====================================================

  /// Generates a seed, which is unique for every day. For the next day, the
  /// seed is always a bigger number than for the day before
  ///
  /// returns: random seed
  int _generateDailySeed() {
    DateTime time = DateTime.now();
    String day = time.day.toString().padLeft(2, '0');
    String month = time.month.toString().padLeft(2, '0');
    String timeString = "${time.year}$month$day";

    return int.parse(timeString);
  }

  /// determinates the temperature category of today. It uses from the [weather]:
  /// - average temperature,
  /// - max temperature
  /// - min temperature
  /// - max windspeed
  ///
  /// returns: todays TemperatureCategory
  int _getTemperatureCategory(WeatherForecast weather) {
    int temperatureCategory;

    double avgTemp = weather.avgTemperatrue;
    double morningTemp = (weather.minTemperature + weather.avgTemperatrue) / 2;
    double eveningTemp = (weather.maxTemperature + weather.avgTemperatrue) / 2;

    if (avgTemp < 3) {
      temperatureCategory = TemperatureCategory.ICY;
    } else if (avgTemp < 8) {
      temperatureCategory = TemperatureCategory.COLD;
    } else if (avgTemp < 15) {
      temperatureCategory = TemperatureCategory.MODERATE;
    } else if (avgTemp < 22) {
      temperatureCategory = TemperatureCategory.WARM;
    } else {
      temperatureCategory = TemperatureCategory.HOT;
    }

    return temperatureCategory;
  }

  int _getTemperatureFromMonth() {
    int month = DateTime.now().month;
    switch (month) {
      case DateTime.january:
      case DateTime.december:
        return TemperatureCategory.ICY;
      case DateTime.february:
      case DateTime.march:
      case DateTime.november:
        return TemperatureCategory.ICY;
      case DateTime.april:
      case DateTime.may:
      case DateTime.october:
        return TemperatureCategory.MODERATE;
      case DateTime.june:
      case DateTime.september:
        return TemperatureCategory.WARM;
      case DateTime.july:
      case DateTime.august:
        return TemperatureCategory.HOT;
      default:
        return TemperatureCategory.MODERATE;
    }
  }

  /// finds the closest temperature to [temperature].
  /// The algorithm uses a [depth]-value to find different kinds of matching
  /// temperature. [depth] can be a number between 1 and 2.
  /// If 1: returns the nearest temperature. It prefers colder temperatures, because
  ///   if it is too hot for you, you can always just put down one piece of clothing
  /// If 2: returns the second most simular temperature
  ///
  /// returns `null`, if no matching temperautr is found. That means, the closest temperature
  /// is not acceptable for an outfit.
  Map<String, dynamic> _getSimularTemperature(int temperature, int depth) {
    if (depth > 2) return {"temp": null, "alertion": AlertionType.ERROR};

    switch (temperature) {
      case TemperatureCategory.HOT:
        if (depth == 1) return {"temp": TemperatureCategory.WARM, "alertion": AlertionType.TOO_HOT};
        return {"temp": null, "alertion": AlertionType.ERROR};
      case TemperatureCategory.WARM:
        if (depth == 1) return {"temp": TemperatureCategory.MODERATE, "alertion": AlertionType.TOO_HOT};
        return {"temp": TemperatureCategory.HOT, "alertion": AlertionType.TOO_COLD};
      case TemperatureCategory.MODERATE:
        if (depth == 1) return {"temp": TemperatureCategory.COLD, "alertion": AlertionType.TOO_HOT};
        return {"temp": TemperatureCategory.WARM, "alertion": AlertionType.TOO_COLD};
      case TemperatureCategory.COLD:
        if (depth == 1) return {"temp": TemperatureCategory.ICY, "alertion": AlertionType.TOO_HOT};
        return {"temp": TemperatureCategory.MODERATE, "alertion": AlertionType.TOO_COLD};
      case TemperatureCategory.ICY:
        if (depth == 1) return {"temp": TemperatureCategory.COLD, "alertion": AlertionType.TOO_COLD};
        return {"temp": null, "alertion": AlertionType.ERROR};
      default:
        return {"temp": null, "alertion": AlertionType.ERROR};
    }
  }

  /// finds the closets style that matches to [style]
  /// the algorithm uses randomness to find matching styles, if there are
  /// multiple styles that match pretty well.
  ///
  /// returns: the best matchig style
  int _getClosestStyle(int style) {
    switch (style) {
      case ClothingStyle.CASUAL:
        bool formal = _random.nextBool();
        return formal ? ClothingStyle.FORMAL : ClothingStyle.SPORTS;
      case ClothingStyle.FORMAL:
      case ClothingStyle.SPORTS:
      default:
        return ClothingStyle.CASUAL;
    }
  }

  /// Determins a score between {0...1} for an outfit.
  ///
  /// It uses the [firstColor] and the [secondColor] and calculates, how well these colors
  /// fit together.
  ///
  /// returns: score
  double _calculateOutfitScore(Color firstColor, Color secondColor) {
    return _random.nextDouble();
  }

  /// Retrieves the outfit with the key [dailySeed] from the Cache
  ///
  /// returns: `null`, if todays outfit is not in the cache
  Future<Outfit?> _getFromCache(int dailySeed) async {
    await Database.openOutfitCache();

    var outfit = _service.findOutfitInCache(dailySeed);

    return outfit;
  }

  /// Stores the [outfit] in the cache with [dailySeed] as the key.
  ///
  /// After that, older outfits get deleted, so there are always just the
  /// latest 3 in cache.
  Future _saveInCache(Outfit outfit, int dailySeed) async {
    await Database.openOutfitCache();

    _service.savOutfitInCache(outfit, dailySeed);

    await _service.deleteOldOutfitFromCache();

    await Database.closeOutfitCache();
  }
}
