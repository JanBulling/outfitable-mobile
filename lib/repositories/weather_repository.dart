import 'package:outfitable_mobile_app/models/weather/location.dart';
import 'package:outfitable_mobile_app/models/weather/weather_forecast.dart';
import 'package:outfitable_mobile_app/services/weather_service.dart';

import '../models/weather/weather.dart';
import '../models/weather/weather_forecast_response.dart';

class WeatherRepository {
  final WeatherService _service;

  const WeatherRepository(this._service);

  Future<WeatherForecastResponse> getWeatherForecast() async {
    final response = await _service.getWeatherForecast();

    if (response.statusCode != 200) {
      return throw Exception("Could not load weather-data");
    }

    try {
      Map<String, dynamic> locationResponse = response.data["location"];
      Location location = Location.fromJson(locationResponse);

      Map<String, dynamic> currentResponse = response.data["current"];
      Weather current = Weather.fromJson(currentResponse);

      Map<String, dynamic> dailyResponse = response.data["forecast"]["forecastday"][0]["day"];
      WeatherForecast daily = WeatherForecast.fromJson(dailyResponse);

      List<dynamic> hourlyResponse = response.data["forecast"]["forecastday"][0]["hour"];
      List<Weather> hourly = hourlyResponse.map((weather) => Weather.fromJson(weather)).toList();

      WeatherForecastResponse result = WeatherForecastResponse(location, current, daily, hourly);

      return result;
    } catch (err) {
      print(err.toString());
      return throw Exception("Error while converting the API-response into weather-data");
    }
  }
}
