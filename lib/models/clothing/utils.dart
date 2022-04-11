// ignore_for_file: constant_identifier_names

/// Type of Temperature, the piece is worn. E.g. T-Shirts are normally worn when it's warm.
class TemperatureCategory {
  static const int NONE = -1;

  static const int ICY = 0;
  static const int COLD = 1;
  static const int MODERATE = 2;
  static const int WARM = 3;
  static const int HOT = 4;
}

/// Different kinds of clothing supported by the app
class ClothingType {
  static const int NONE = -1;

  static const int BLOUSE = 0;
  static const int DRESS = 1;
  static const int HOODIE = 2;
  static const int JACKET = 3;
  static const int JEANS = 4;
  static const int PANTS = 5;
  static const int SHIRT = 6;
  static const int SHORTS = 7;
  static const int SKIRT = 8;
  static const int SWEATER = 9;
  static const int TANKTOP = 10;
  static const int TSHIRT = 11;
}

/// Where the piece of clothing is worn
class ClothingPart {
  static const int NONE = -1;

  static const int TOP_PART = 0;
  static const int LOWER_PART = 1;
  static const int BOTH = 2;
}

/// Style, where the piece of clothing is worn usually
class ClothingStyle {
  static const int NONE = -1;

  static const int CASUAL = 0;
  static const int FORMAL = 1;
  static const int SPORTS = 2;
}

class ClothingUtils {
  static String getTypeIconPath(int type) {
    String basePath = "assets/icons/";
    switch (type) {
      case ClothingType.BLOUSE:
        return basePath + "blouse.svg";
      case ClothingType.DRESS:
        return basePath + "dress.svg";
      case ClothingType.HOODIE:
        return basePath + "hoodie.svg";
      case ClothingType.JACKET:
        return basePath + "jacket.svg";
      case ClothingType.JEANS:
        return basePath + "jeans.svg";
      case ClothingType.PANTS:
        return basePath + "pants.svg";
      case ClothingType.SHIRT:
        return basePath + "shirt.svg";
      case ClothingType.SHORTS:
        return basePath + "shorts.svg";
      case ClothingType.SKIRT:
        return basePath + "skirt.svg";
      case ClothingType.SWEATER:
        return basePath + "sweater.svg";
      case ClothingType.TANKTOP:
        return basePath + "tank_top.svg";
      case ClothingType.TSHIRT:
        return basePath + "tshirt.svg";
      default:
        return basePath + "none.svg";
    }
  }

  static String getTemperatureIconPath(int temperature) {
    String basePath = "assets/icons/";
    switch (temperature) {
      case TemperatureCategory.ICY:
        return basePath + "temperature_icy.svg";
      case TemperatureCategory.COLD:
        return basePath + "temperature_cold.svg";
      case TemperatureCategory.MODERATE:
        return basePath + "temperature_moderate.svg";
      case TemperatureCategory.WARM:
        return basePath + "temperature_warm.svg";
      case TemperatureCategory.HOT:
        return basePath + "temperature_hot.svg";
      default:
        return basePath + "none.svg";
    }
  }
}
