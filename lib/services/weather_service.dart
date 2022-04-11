import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/url.dart';

class WeatherService {
  final Dio _client;

  const WeatherService(this._client);

  Future<Response> getCurrentWeather() async {
    String apiKey = dotenv.env['WEATHER_API_KEY'] ?? "";

    String url = Url.currentWeather + "?key=$apiKey&q=auto:ip&lang=de";
    return _client.get(url);
  }

  Future<Response> getWeatherForecast() async {
    String apiKey = dotenv.env['WEATHER_API_KEY'] ?? "";

    String url = Url.weatherForecast + "?key=$apiKey&q=auto:ip&lang=de&days=1&aqi=no";
    return _client.get(url);
  }
}
