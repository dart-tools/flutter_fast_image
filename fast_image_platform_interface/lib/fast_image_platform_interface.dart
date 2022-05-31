// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:fast_image_platform_interface/src/method_channel_fast_image.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FastImagePlatform extends PlatformInterface {
  static final Object _token = Object();
  FastImagePlatform() : super(token: _token);

  static FastImagePlatform _instance = MethodChannelFastImage();
  static FastImagePlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [SharedPreferencesStorePlatform] when they register themselves.
  static set instance(FastImagePlatform value) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = value;
  }

  Future<void> resizeImage(
    String path,
    String targetPath, {
    int? width,
    int? height,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
  });
}
