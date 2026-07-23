import 'dart:io';

import 'package:flutter/services.dart';

class InstagramStoryShareException implements Exception {
  const InstagramStoryShareException(this.code);

  final String code;
}

class InstagramStoryShareService {
  InstagramStoryShareService._();

  static final InstagramStoryShareService instance =
      InstagramStoryShareService._();

  static const MethodChannel _channel = MethodChannel(
    'com.firstlook/instagram_story_share',
  );

  Future<void> shareImage({
    required String imagePath,
    String? attributionUrl,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw const InstagramStoryShareException('unsupported_platform');
    }

    try {
      final bool opened = await _channel.invokeMethod<bool>(
            'shareImage',
            <String, String?>{
              'imagePath': imagePath,
              'attributionUrl': attributionUrl,
            },
          ) ??
          false;

      if (!opened) {
        throw const InstagramStoryShareException('instagram_unavailable');
      }
    } on PlatformException catch (error) {
      throw InstagramStoryShareException(error.code);
    } on MissingPluginException {
      throw const InstagramStoryShareException('unsupported_platform');
    }
  }
}
