import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String weatherText;
  final int weatherCode;
  final double windSpeed;
  final double temperature;
  final double feelsLike;
  final int clouds;
  final int humidity;
  final double airPressure;
  final int? time;

  const Weather({
    required this.weatherText,
    required this.weatherCode,
    required this.windSpeed,
    required this.temperature,
    required this.feelsLike,
    required this.clouds,
    required this.humidity,
    required this.airPressure,
    this.time,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        weatherText: json["condition"]["text"],
        weatherCode: json["condition"]["code"],
        windSpeed: json["wind_kph"],
        temperature: json["temp_c"],
        feelsLike: json["feelslike_c"],
        clouds: json["cloud"],
        humidity: json["humidity"],
        airPressure: json["pressure_mb"],
        time: json["last_updated_epoch"],
      );

  String get timeString {
    if (time == null) return "";

    DateTime date = DateTime.fromMillisecondsSinceEpoch(time! * 1000);

    String minute = date.minute.toString().padLeft(2, '0');
    String hour = date.hour.toString().padLeft(2, '0');

    return "$hour:$minute Uhr";
  }

  @override
  List<Object?> get props => [
        weatherText,
        weatherCode,
        windSpeed,
        temperature,
        feelsLike,
        clouds,
        humidity,
        airPressure,
        time,
      ];
}
