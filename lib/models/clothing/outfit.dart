// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'clothing.dart';

enum AlertionType {
  NONE,
  OUTFIT_TOO_HOT,
  OUTFIT_TOO_COLD,
  RAINING,
  SNOWING,
  STORMING,
  WRONG_STYLE,
  NO_WEATHER_DATA_AVAILABLE,
  NOT_ENOUGH_CLOTHING,
  ERROR,
}

class Outfit {
  Clothing? topPart;
  Clothing? lowerPart;
  AlertionType alertionType;

  Outfit({
    this.topPart,
    this.lowerPart,
    this.alertionType = AlertionType.NONE,
  });

  Map<String, dynamic> toJson() {
    return {
      "top": topPart?.toJson(),
      "lower": lowerPart?.toJson(),
      "alertionType": alertionType.index,
    };
  }

  factory Outfit.fromJson(Map<String, dynamic> json) {
    int alertionTypeIndex = json["alertionType"];

    return Outfit(
      topPart: Clothing.fromJson(Map<String, dynamic>.from(json["top"])),
      lowerPart: Clothing.fromJson(Map<String, dynamic>.from(json["lower"])),
      alertionType: AlertionType.values[alertionTypeIndex],
    );
  }

  Color get color {
    switch (alertionType) {
      case AlertionType.NONE:
        return Colors.transparent;
      case AlertionType.OUTFIT_TOO_HOT:
        return Colors.red.shade700;
      case AlertionType.OUTFIT_TOO_COLD:
        return Colors.lightBlue.shade700;
      case AlertionType.ERROR:
      case AlertionType.NOT_ENOUGH_CLOTHING:
      case AlertionType.NO_WEATHER_DATA_AVAILABLE:
      case AlertionType.WRONG_STYLE:
        return Colors.amber;
      case AlertionType.RAINING:
      case AlertionType.SNOWING:
      case AlertionType.STORMING:
      default:
        return Colors.green.shade700;
    }
  }

  IconData? get icon {
    switch (alertionType) {
      case AlertionType.RAINING:
        return Icons.water_drop;
      case AlertionType.SNOWING:
        return Icons.snowing;
      case AlertionType.STORMING:
        return Icons.air;
      default:
        return null;
    }
  }

  String? message(AppLocalizations lang) {
    switch (alertionType) {
      case AlertionType.OUTFIT_TOO_HOT:
        return lang.outfit_message_too_hot;
      case AlertionType.OUTFIT_TOO_COLD:
        return lang.outfit_message_too_cold;
      case AlertionType.RAINING:
        return lang.outfit_message_raining;
      case AlertionType.STORMING:
        return lang.outfit_message_stormy;
      case AlertionType.SNOWING:
        return lang.outfit_message_snowing;
      case AlertionType.WRONG_STYLE:
        return lang.outfit_message_wrong_style;
      case AlertionType.NOT_ENOUGH_CLOTHING:
        return lang.outfit_message_not_enough_clothing;
      case AlertionType.NO_WEATHER_DATA_AVAILABLE:
        return lang.outfit_message_no_weather_data;
      case AlertionType.ERROR:
        return lang.outfit_message_error;
      case AlertionType.NONE:
      default:
        return null;
    }
  }
}
