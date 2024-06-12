// This file is needed to avoid import errors when platform-specific files are missing
import 'dart:typed_data';

abstract class ImageService {
  static Future<String> processImage(dynamic imageSource, String strategy, List<String> timeframes, String additionalParameter) async {
    throw UnimplementedError('platform-specific implementation is missing');
  }
}
