import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final int time;

  const Location({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.time,
  });

  String get timeString {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(time * 1000);

    String minute = date.minute.toString().padLeft(2, '0');
    String hour = date.hour.toString().padLeft(2, '0');

    return "$hour:$minute Uhr";
  }

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        name: json["name"],
        country: json["country"],
        latitude: json["lat"],
        longitude: json["lon"],
        time: json["localtime_epoch"],
      );

  @override
  List<Object?> get props => [name, country, latitude, longitude, time];
}
