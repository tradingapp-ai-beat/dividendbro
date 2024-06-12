import 'web_image_service.dart' if (dart.library.html) 'web_image_service.dart';
import 'mobile_image_service.dart' if (dart.library.io) 'mobile_image_service.dart';

abstract class ImageService {
  Future<String> processImage(String imageUrl, String strategy, List<String> timeframes, String additionalParameter);
}

ImageService getImageService() {
  if (Uri.base.scheme == 'http' || Uri.base.scheme == 'https') {
    return WebImageService();
  } else {
    return MobileImageService();
  }
}
