import 'location.dart';
import 'weather.dart';
import 'weather_forecast.dart';

class WeatherForecastResponse {
  final Location location;
  final Weather current;
  final WeatherForecast forecastday;
  final List<Weather> forecast;

  WeatherForecastResponse(this.location, this.current, this.forecastday, this.forecast);
}
