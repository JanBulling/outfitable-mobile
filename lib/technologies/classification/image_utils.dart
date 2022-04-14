import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class ImageUtils {
  /// Convert a [CameraImage] to an [Image] from the image-library.
  /// This method differentiates between different image formats like YUV420 (default on android) and BGRA8888
  ///
  /// Params:
  ///   [cameraImage] - the camera Image you want to convert
  ///   [predictColor] - boolean, weather you also want the method to predict the vibrant color on the
  ///       image (default true)
  ///
  /// Returns: Map<String, dynamic> with following form:
  ///    {
  ///      "color": predicted color,
  ///      "image": the image
  ///    }
  static Future<Map<String, dynamic>> convertCameraImage(CameraImage cameraImage, {bool predictColor = true}) async {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return convertYUV420ToImage(cameraImage, predictColor);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return convertBGRA8888ToImage(cameraImage, predictColor);
    } else {
      return {};
    }
  }

  /// convertes a [CameraImage] in bgra8888 to an [Image]
  static Future<Map<String, dynamic>> convertBGRA8888ToImage(CameraImage cameraImage, bool predictColor) async {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    img.Image image = img.Image.fromBytes(width, height, cameraImage.planes[0].bytes, format: img.Format.bgra);
    Color? color;

    int redCount = 0, greenCount = 0, blueCount = 0, total = 0;

    if (predictColor) {
      for (int i = 0; i < width; i += 5) {
        for (int j = 0; j < height; j += 5) {
          int color = image.getPixel(i, j);

          int r = 0xff & (color >> 16);
          int g = 0xff & (color >> 8);
          int b = 0xff & (color >> 0);

          redCount += r;
          greenCount += g;
          blueCount += b;

          total++;
        }
      }

      int avgRed = (redCount / total).floor().clamp(0, 255);
      int avgGreen = (greenCount / total).floor().clamp(0, 255);
      int avgBlue = (blueCount / total).floor().clamp(0, 255);

      color = Color.fromARGB(255, avgRed, avgGreen, avgBlue);
    }

    return {"color": color, "image": image};
  }

  /// convertes a [CameraImage] in yuv420 to an [Image]
  static Future<Map<String, dynamic>> convertYUV420ToImage(CameraImage cameraImage, bool predictColor) async {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel ?? 1;

    final image = img.Image(width, height);
    Color? color;

    int redCount = 0, greenCount = 0, blueCount = 0, total = 0;

    for (int w = 0; w < width; w++) {
      for (int h = 0; h < height; h++) {
        final int uvIndex = uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final int index = h * width + w;

        final y = cameraImage.planes[0].bytes[index];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        int r = (y + v * 1436 / 1024 - 179).round();
        int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
        int b = (y + u * 1814 / 1024 - 227).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        if (predictColor && index % 5 == 0) {
          redCount += r;
          greenCount += g;
          blueCount += b;
          total++;
        }

        int rgbColor = 0xff000000 | ((b << 16) & 0xff0000) | ((g << 8) & 0xff00) | (r & 0xff);

        image.data[index] = rgbColor;
      }
    }

    if (predictColor) {
      int avgRed = (redCount / total).floor().clamp(0, 255);
      int avgGreen = (greenCount / total).floor().clamp(0, 255);
      int avgBlue = (blueCount / total).floor().clamp(0, 255);

      color = Color.fromARGB(255, avgRed, avgGreen, avgBlue);
    }

    return {"color": color, "image": image};
  }

  /// Saves an [Image] to the phones gallery and prints the path
  static void saveImageToGallery(img.Image image) async {
    List<int> jpeg = img.JpegEncoder().encodeImage(image);
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(jpeg));
    print("[ImageUtils] - Saved image to gallery: $result");
  }

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
