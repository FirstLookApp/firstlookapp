import 'package:firstlook/services/environment_service.dart';

abstract final class UrlResolver {
  static String media(String path) {
    if (path.isEmpty || path.startsWith('http')) {
      return path;
    }

    return '${EnvironmentService.instance.baseUrl}$path';
  }
}
