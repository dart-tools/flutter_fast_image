#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface ResizeImageHandler : NSObject
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;
+ (NSData *)compressDataWithImage:(UIImage *)image quality:(float)quality format:(int)format;
@end
