// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fast_image_platform_interface/fast_image_platform_interface.dart';
import 'package:flutter/services.dart';

const MethodChannel _channel = MethodChannel('dev.dart-tools/fast_image');

/// An implementation of [FastImagePlatform] that uses method channels.
class MethodChannelFastImage extends FastImagePlatform {
  @override
  Future<void> resizeImage(String path, String targetPath,
      {int? width,
      int? height,
      int quality = 95,
      int rotate = 0,
      bool autoCorrectionAngle = true}) async {
    await _channel.invokeMethod("resizeImage", [
      path,
      width,
      height,
      quality,
      targetPath,
      rotate,
      autoCorrectionAngle,
    ]);
  }
}
