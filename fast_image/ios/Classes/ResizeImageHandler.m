#import "ResizeImageHandler.h"
#import "SYPictureMetaData/SYMetadata.h"
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import <SDWebImage/SDWebImage.h>
#import "UIImage+adjust.h"

@implementation ResizeImageHandler {

}
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {

    NSArray *args = call.arguments;
    NSString *filePath = args[0];
    int width = 0;
    int height = 0;
    if(![args[1] isEqual:[NSNull null]]){
        width = [args[1] intValue];
    }
    if(![args[2] isEqual:[NSNull null]]){
        height = [args[2] intValue];
    }
    int quality = [args[3] intValue];
    NSString *targetPath = args[4];
    int rotate = [args[5] intValue];


    
    UIImage *img;
    
    NSURL *imageUrl = [NSURL fileURLWithPath:filePath];
    NSData *nsdata = [NSData dataWithContentsOfURL:imageUrl];
    
    NSString *imageType = [self mimeTypeByGuessingFromData:nsdata];
    
    SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:webPCoder];
    
    if([imageType  isEqual: @"image/webp"]) {
        img = [[SDImageWebPCoder sharedCoder] decodedImageWithData:nsdata options:nil];
    } else {
        img = [UIImage imageWithData:nsdata];
    }

    img = [img scaleWithWidth:width height:height];
    if(rotate % 360 != 0){
        img = [img rotate: rotate];
    }
    NSData *data = [ResizeImageHandler compressDataWithImage:img quality:quality format:0];


    [data writeToURL:[[NSURL alloc] initFileURLWithPath:targetPath] atomically:YES];

    result(targetPath);
}

+ (NSData *)compressDataWithImage:(UIImage *)image quality:(float)quality format:(int)format  {
    NSData *data;
    if (format == 2) { // heic
        CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
        CIContext *ciContext = [[CIContext alloc]initWithOptions:nil];
        NSString *tmpDir = NSTemporaryDirectory();
        double time = [[NSDate alloc]init].timeIntervalSince1970;
        NSString *target = [NSString stringWithFormat:@"%@%.0f.heic",tmpDir, time * 1000];
        NSURL *url = [NSURL fileURLWithPath:target];
        
        NSMutableDictionary *options = [NSMutableDictionary new];
        NSString *qualityKey = (__bridge NSString *)kCGImageDestinationLossyCompressionQuality;
//        CIImageRepresentationOption
        [options setObject:@(quality / 100) forKey: qualityKey];
        
        if (@available(iOS 11.0, *)) {
            [ciContext writeHEIFRepresentationOfImage:ciImage toURL:url format: kCIFormatARGB8 colorSpace: ciImage.colorSpace options:options error:nil];
            data = [NSData dataWithContentsOfURL:url];
        } else {
            // Fallback on earlier versions
            data = nil;
        }
    } else if(format == 3){ // webp
        SDImageCoderOptions *option = @{SDImageCoderEncodeCompressionQuality: @(quality / 100)};
        data = [[SDImageWebPCoder sharedCoder]encodedDataWithImage:image format:SDImageFormatWebP options:option];
    } else if(format == 1){ // png
        data = UIImagePNGRepresentation(image);
    }else { // 0 or other is jpeg
        data = UIImageJPEGRepresentation(image, (CGFloat) quality / 100);
    }

    return data;
}

- (NSString *)mimeTypeByGuessingFromData:(NSData *)data {

    char bytes[12] = {0};
    [data getBytes:&bytes length:12];

    const char bmp[2] = {'B', 'M'};
    const char gif[3] = {'G', 'I', 'F'};
    const char swf[3] = {'F', 'W', 'S'};
    const char swc[3] = {'C', 'W', 'S'};
    const char jpg[3] = {0xff, 0xd8, 0xff};
    const char psd[4] = {'8', 'B', 'P', 'S'};
    const char iff[4] = {'F', 'O', 'R', 'M'};
    const char webp[4] = {'R', 'I', 'F', 'F'};
    const char ico[4] = {0x00, 0x00, 0x01, 0x00};
    const char tif_ii[4] = {'I','I', 0x2A, 0x00};
    const char tif_mm[4] = {'M','M', 0x00, 0x2A};
    const char png[8] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};
    const char jp2[12] = {0x00, 0x00, 0x00, 0x0c, 0x6a, 0x50, 0x20, 0x20, 0x0d, 0x0a, 0x87, 0x0a};


    if (!memcmp(bytes, bmp, 2)) {
        return @"image/x-ms-bmp";
    } else if (!memcmp(bytes, gif, 3)) {
        return @"image/gif";
    } else if (!memcmp(bytes, jpg, 3)) {
        return @"image/jpeg";
    } else if (!memcmp(bytes, psd, 4)) {
        return @"image/psd";
    } else if (!memcmp(bytes, iff, 4)) {
        return @"image/iff";
    } else if (!memcmp(bytes, webp, 4)) {
        return @"image/webp";
    } else if (!memcmp(bytes, ico, 4)) {
        return @"image/vnd.microsoft.icon";
    } else if (!memcmp(bytes, tif_ii, 4) || !memcmp(bytes, tif_mm, 4)) {
        return @"image/tiff";
    } else if (!memcmp(bytes, png, 8)) {
        return @"image/png";
    } else if (!memcmp(bytes, jp2, 12)) {
        return @"image/jp2";
    }

    return @"application/octet-stream"; // default type

}

@end
