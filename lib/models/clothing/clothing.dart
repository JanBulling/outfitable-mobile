import 'dart:ui';

import 'package:hive/hive.dart';

import 'utils.dart';

part "clothing.g.dart";

@HiveType(typeId: 0)
class Clothing extends HiveObject {
  /// Type of the clothing. E.g. T-Shirt, Hoodie, ...
  @HiveField(0)
  int type;

  /// part, where the cloth is worn. E.g. top_part, lower_part, ...
  @HiveField(1)
  int part;

  /// List of temperatures (from 0(icy) to 4(hot))
  @HiveField(2)
  final List<int> temperatures;

  /// list of styles (0-> casual, 1-> formal, 2-> sports)
  @HiveField(3)
  final List<int> styles;

  /// color of the shirt as an int-value in ARGB
  @HiveField(4)
  int colorValue;

  Clothing({
    this.type = ClothingType.NONE,
    this.part = ClothingPart.NONE,
    this.temperatures = const [],
    this.styles = const [],
    this.colorValue = 0xff000000,
  });

  Color get color => Color(colorValue);
  set color(Color? color) {
    colorValue = color?.value ?? 0xff000000;
  }

  factory Clothing.fromType(int typeIndex) {
    if (typeIndex == ClothingType.NONE) return Clothing();
    return _preSettings[typeIndex] ?? Clothing();
  }

  factory Clothing.fromJson(Map<String, dynamic> json) {
    return Clothing(
      type: json["type"],
      part: json["part"],
      temperatures: json["temperatures"],
      styles: json["styles"],
      colorValue: json["color"],
    );
  }

  Map<String, dynamic> toJson() => {
        "type": type,
        "part": part,
        "temperatures": temperatures,
        "styles": styles,
        "color": colorValue,
      };

  bool validate() {
    return type != ClothingType.NONE && part != ClothingPart.NONE && temperatures.isNotEmpty && styles.isNotEmpty;
  }

  static final Map<int, Clothing> _preSettings = {
    ClothingType.BLOUSE: Clothing(
      type: ClothingType.BLOUSE,
      part: ClothingPart.TOP_PART,
      temperatures: [TemperatureCategory.MODERATE, TemperatureCategory.WARM],
      styles: [ClothingStyle.FORMAL],
    ),
    ClothingType.DRESS: Clothing(
      type: ClothingType.DRESS,
      part: ClothingPart.BOTH,
      temperatures: [TemperatureCategory.MODERATE, TemperatureCategory.WARM],
      styles: [ClothingStyle.FORMAL, ClothingStyle.CASUAL],
    ),
    ClothingType.HOODIE: Clothing(
      type: ClothingType.HOODIE,
      part: ClothingPart.TOP_PART,
      temperatures: [TemperatureCategory.ICY, TemperatureCategory.COLD, TemperatureCategory.MODERATE],
      styles: [ClothingStyle.CASUAL],
    ),
    ClothingType.JACKET: Clothing(
      type: ClothingType.JACKET,
      part: ClothingPart.TOP_PART,
      temperatures: [
        TemperatureCategory.ICY,
        TemperatureCategory.COLD,
        TemperatureCategory.MODERATE,
        TemperatureCategory.WARM
      ],
      styles: [ClothingStyle.FORMAL, ClothingStyle.CASUAL],
    ),
    ClothingType.JEANS: Clothing(
      type: ClothingType.JEANS,
      part: ClothingPart.LOWER_PART,
      temperatures: [
        TemperatureCategory.ICY,
        TemperatureCategory.COLD,
        TemperatureCategory.MODERATE,
        TemperatureCategory.WARM
      ],
      styles: [ClothingStyle.FORMAL, ClothingStyle.CASUAL],
    ),
    ClothingType.PANTS: Clothing(
      type: ClothingType.PANTS,
      part: ClothingPart.LOWER_PART,
      temperatures: [
        TemperatureCategory.ICY,
        TemperatureCategory.COLD,
        TemperatureCategory.MODERATE,
        TemperatureCategory.WARM
      ],
      styles: [ClothingStyle.FORMAL, ClothingStyle.CASUAL],
    ),
    ClothingType.SHIRT: Clothing(
      type: ClothingType.SHIRT,
      part: ClothingPart.TOP_PART,
      temperatures: [TemperatureCategory.MODERATE, TemperatureCategory.WARM],
      styles: [ClothingStyle.FORMAL, ClothingStyle.CASUAL],
    ),
    ClothingType.SHORTS: Clothing(
      type: ClothingType.SHORTS,
      part: ClothingPart.LOWER_PART,
      temperatures: [TemperatureCategory.WARM, TemperatureCategory.HOT],
      styles: [ClothingStyle.SPORTS, ClothingStyle.CASUAL],
    ),
    ClothingType.SKIRT: Clothing(
      type: ClothingType.SKIRT,
      part: ClothingPart.LOWER_PART,
      temperatures: [TemperatureCategory.WARM, TemperatureCategory.HOT],
      styles: [ClothingStyle.FORMAL, ClothingStyle.CASUAL],
    ),
    ClothingType.SWEATER: Clothing(
      type: ClothingType.SWEATER,
      part: ClothingPart.TOP_PART,
      temperatures: [TemperatureCategory.COLD, TemperatureCategory.MODERATE, TemperatureCategory.WARM],
      styles: [ClothingStyle.CASUAL],
    ),
    ClothingType.TANKTOP: Clothing(
      type: ClothingType.TANKTOP,
      part: ClothingPart.TOP_PART,
      temperatures: [TemperatureCategory.MODERATE, TemperatureCategory.WARM, TemperatureCategory.HOT],
      styles: [ClothingStyle.FORMAL, ClothingStyle.CASUAL, ClothingStyle.SPORTS],
    ),
    ClothingType.TSHIRT: Clothing(
      type: ClothingType.TSHIRT,
      part: ClothingPart.TOP_PART,
      temperatures: [TemperatureCategory.MODERATE, TemperatureCategory.WARM, TemperatureCategory.HOT],
      styles: [ClothingStyle.CASUAL, ClothingStyle.SPORTS],
    ),
  };
}
