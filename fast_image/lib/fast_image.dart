// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';

import 'package:fast_image_platform_interface/fast_image_platform_interface.dart';

class FastImage {
  static Future<void> resizeImage(
    String path,
    String targetPath, {
    int? width,
    int? height,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
  }) async {
    await FastImagePlatform.instance.resizeImage(
      path,
      targetPath,
      width: width,
      height: height,
      quality: quality,
      rotate: rotate,
      autoCorrectionAngle: autoCorrectionAngle,
    );
  }
}
