import 'dart:ui';
import 'dart:math' as math;

import 'package:camera/camera.dart';

class ImageUtils {
  static const List<Color> _mainColors = [
    Color.fromARGB(255, 240, 205, 8),
    //Color(0xFFCD950C),
    Color(0xFFFF8C00),
    //Color(0xFFEE4500),
    Color.fromARGB(255, 235, 0, 0),
    Color.fromARGB(255, 109, 20, 20),
    //Color(0xFF8B008B),
    Color(0xFFEE30A7),
    //Color(0xFFEEB4B4),
    //Color(0xFFA4D3EE),
    Color.fromARGB(255, 135, 149, 167),
    Color.fromARGB(255, 39, 86, 255),
    //Color(0xFF425D8C),
    Color.fromARGB(255, 0, 0, 107),
    //Color(0xFF8B5A2B),
    //Color(0xFFA52A2A),
    Color.fromARGB(255, 231, 231, 231),
    //Color(0xFFBEBEBE),
    Color(0xFF696969),
    Color(0xFF0A0A0A),
    //Color(0xFF9ACD32),
    Color.fromARGB(255, 0, 228, 0),
    Color.fromARGB(255, 10, 99, 10),
    //Color(0xFF6E8B3D),
    //Color(0xFFEED8AE),
  ];

  static const List<Color> _defaultColors = [
    Color(0xff000000),
    Color(0xff00ffff),
    Color(0xff0000ff),
    Color(0xffff00ff),
    Color(0xff808080),
    Color(0xff008000),
    Color(0xff00ff00),
    Color(0xff800000),
    Color(0xff000080),
    Color(0xff808000),
    Color(0xffffa500),
    Color(0xff800080),
    Color(0xffff0000),
    Color(0xffc0c0c0),
    Color(0xff008080),
    Color(0xffffffff),
    Color(0xffffff00),
  ];

  static Future<Color> predictColor(CameraImage image) async {
    // TODO: Test on IOS (not sure if widht > height there as well)
    int startX = ((image.width - image.height) / 2).round();
    int endX = (image.height + (image.width - image.height) / 2).round();
    int startY = 0;
    int endY = image.height;

    Color avgColor = await getAverageColor(image, startX, startY, endX, endY);

    Color prediction = await findCloseColor(avgColor);

    return prediction;
  }

  /// gets the approximate average color
  static Future<Color> getAverageColor(CameraImage image, int x1, int y1, int x2, int y2, {int resolution = 5}) async {
    int count = 0;
    int r = 0;
    int g = 0;
    int b = 0;

    int width = image.width;
    List<Plane> planes = image.planes;

    int uvRowStride = planes[1].bytesPerRow;
    int? uvPixelStride = planes[1].bytesPerPixel;
    //TODO: Test on IOS (not sure if it works)
    uvPixelStride ??= (uvRowStride / planes[1].width!).floor();

    for (int x = x1; x <= x2; x += resolution) {
      for (int y = y1; y < y2; y += resolution) {
        int index = width * y + x;
        int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();

        final yp = planes[0].bytes[index];
        final up = planes[1].bytes[uvIndex];
        final vp = planes[2].bytes[uvIndex];

        r += (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        g += (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
        b += (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        count++;
      }
    }

    int avgRed = (r / count).floor().clamp(0, 255);
    int avgGreen = (g / count).floor().clamp(0, 255);
    int avgBlue = (b / count).floor().clamp(0, 255);

    return Color.fromARGB(255, avgRed, avgGreen, avgBlue);
  }

  static Future<Color> findCloseColor(Color color) async {
    // make color brighter if its too dark
    var hsv = rgbToHsv(color.red, color.green, color.blue);
    if (hsv[2] > 0.60) {
      hsv[2] = 1.0;
    } else if (hsv[2] > 0.3) {
      hsv[2] = 0.6;
    }

    hsv[1] = hsv[1] > 0.4 ? 1.0 : 0.0;

    var rgb = hsvToRgb(hsv[0], hsv[1], hsv[2]);
    color = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);

    // find the closest color from the list of colors;
    num minDistance = double.infinity;
    Color nearestColor = _defaultColors[0];

    for (Color c in _defaultColors) {
      num distanceSq =
          math.pow(c.red - color.red, 2) + math.pow(c.green - color.green, 2) + math.pow(c.blue - color.blue, 2);

      if (distanceSq < minDistance) {
        minDistance = distanceSq;
        nearestColor = c;
      }
    }

    return nearestColor;
  }

  // From https://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
  static List<double> rgbToHsv(int red, int green, int blue) {
    double r = red / 255;
    double g = green / 255;
    double b = blue / 255;

    double maxRGB = math.max(math.max(r, g), b);
    double minRGB = math.min(math.min(r, g), b);
    double h = maxRGB, s = maxRGB, v = maxRGB;

    double d = maxRGB - minRGB;

    if (maxRGB == minRGB) {
      h = 0;
    } else {
      if (maxRGB == r) {
        h = (g - b) / d + (g < b ? 6 : 0);
      } else if (maxRGB == g) {
        h = (b - r) / d + 2;
      } else {
        h = (r - g) / d + 4;
      }
      h /= 6;
    }

    return [h, s, v];
  }

  // From https://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
  static List<int> hsvToRgb(double h, double s, double v) {
    double r = 0, g = 0, b = 0;

    int i = (h * 6).floor();
    double f = h * 6 - i;
    double p = v * (1 - s);
    double q = v * (1 - f * s);
    double t = v * (1 - (1 - f) * s);

    switch (i % 6) {
      case 0:
        r = v;
        g = t;
        b = p;
        break;
      case 1:
        r = q;
        g = v;
        b = p;
        break;
      case 2:
        r = p;
        g = v;
        b = t;
        break;
      case 3:
        r = p;
        g = q;
        b = v;
        break;
      case 4:
        r = t;
        g = p;
        b = v;
        break;
      case 5:
        r = v;
        g = p;
        b = q;
        break;
    }

    return [(r * 255).round(), (g * 255).round(), (b * 255).round()];
  }
}
