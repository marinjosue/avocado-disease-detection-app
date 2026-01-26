import 'dart:io';
import 'package:image/image.dart' as img;

class ImageUtils {
  /// Resize image to specific dimensions
  static Future<File> resizeImage(
    File imageFile, {
    required int width,
    required int height,
  }) async {
    try {
      final image = img.decodeImage(imageFile.readAsBytesSync());
      if (image == null) throw Exception('Unable to decode image');

      final resized = img.copyResize(
        image,
        width: width,
        height: height,
      );

      final tempFile = File('${imageFile.path}_resized.jpg');
      return tempFile..writeAsBytesSync(img.encodeJpg(resized));
    } catch (e) {
      throw Exception('Error resizing image: $e');
    }
  }

  /// Compress image
  static Future<File> compressImage(
    File imageFile, {
    int quality = 80,
  }) async {
    try {
      final image = img.decodeImage(imageFile.readAsBytesSync());
      if (image == null) throw Exception('Unable to decode image');

      final compressed = img.encodeJpg(image, quality: quality);

      final tempFile = File('${imageFile.path}_compressed.jpg');
      return tempFile..writeAsBytesSync(compressed);
    } catch (e) {
      throw Exception('Error compressing image: $e');
    }
  }

  /// Get image dimensions
  static Future<Map<String, int>> getImageDimensions(File imageFile) async {
    try {
      final image = img.decodeImage(imageFile.readAsBytesSync());
      if (image == null) throw Exception('Unable to decode image');

      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      throw Exception('Error getting image dimensions: $e');
    }
  }

  /// Normalize image pixel values
  static List<List<List<num>>> normalizeImage(img.Image image) {
    final List<List<List<num>>> normalized = [];

    for (int y = 0; y < image.height; y++) {
      final List<List<num>> row = [];
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;
        row.add([r, g, b]);
      }
      normalized.add(row);
    }

    return normalized;
  }
}
