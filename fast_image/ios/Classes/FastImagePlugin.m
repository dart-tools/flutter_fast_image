#import "FastImagePlugin.h"
#import "ResizeImageHandler.h"

@implementation FastImagePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"dev.dart-tools/fast_image"
            binaryMessenger:[registrar messenger]];
  FastImagePlugin* instance = [[FastImagePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"resizeImage" isEqualToString:call.method]) {
    ResizeImageHandler *handler = [[ResizeImageHandler alloc] init];
    [handler handleMethodCall:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
