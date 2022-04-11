class WeatherForecast {
  final String weatherText;
  final int weatherCode;
  final double maxTemperature;
  final double minTemperature;
  final double avgTemperatrue;
  final double maxWindSpeed;
  final bool rain;
  final bool snow;

  const WeatherForecast({
    required this.weatherText,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
    required this.avgTemperatrue,
    required this.maxWindSpeed,
    required this.rain,
    required this.snow,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      weatherText: json["condition"]["text"],
      weatherCode: json["condition"]["code"],
      maxTemperature: json["maxtemp_c"],
      minTemperature: json["mintemp_c"],
      avgTemperatrue: json["avgtemp_c"],
      maxWindSpeed: json["maxwind_kph"],
      rain: json["daily_will_it_rain"] == 1 ? true : false,
      snow: json["daily_will_it_snow"] == 1 ? true : false,
    );
  }
}
