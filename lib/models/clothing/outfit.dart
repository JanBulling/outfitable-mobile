// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

import 'clothing.dart';

enum AlertionType { TOO_HOT, OPTIMAL, TOO_COLD, ERROR }

class Outfit {
  Clothing? upperClothing;
  Clothing? lowerClothing;
  String? message;
  AlertionType alertionType;
  IconData? icon;

  Outfit({
    this.upperClothing,
    this.lowerClothing,
    this.message,
    this.alertionType = AlertionType.OPTIMAL,
    this.icon,
  });

  Color get backgroundColor {
    switch (alertionType) {
      case AlertionType.TOO_HOT:
        return Colors.red.shade700;
      case AlertionType.TOO_COLD:
        return Colors.lightBlue.shade700;
      case AlertionType.ERROR:
        return Colors.amber;
      case AlertionType.OPTIMAL:
      default:
        return Colors.green.shade700;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "top": upperClothing?.toJson(),
      "lower": lowerClothing?.toJson(),
      "message": message,
      "alertion": alertionType.index,
      "icon": icon?.codePoint,
    };
  }

  factory Outfit.fromJson(Map<String, dynamic> json) {
    int? iconCode = json["icon"];
    int? alertionType = json["alertion"];

    print("converting");

    return Outfit(
      upperClothing: Clothing.fromJson(Map<String, dynamic>.from(json["top"])),
      lowerClothing: Clothing.fromJson(Map<String, dynamic>.from(json["lower"])),
      message: json["message"],
      alertionType: alertionType != null ? AlertionType.values[alertionType] : AlertionType.OPTIMAL,
      icon: iconCode == null ? null : IconData(iconCode, fontFamily: 'MaterialIcons'),
    );
  }
}
