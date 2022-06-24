#import "UIImage+adjust.h"
#import <math.h>

@implementation UIImage (adjust)
-(UIImage *)scaleWithWidth: (CGFloat)width height:(CGFloat)height {
    float actualHeight = self.size.height;
    float actualWidth = self.size.width;

    float intendedWidth = width;
    float intendedHeight = height;
    if (intendedWidth != 0.0 && intendedWidth > actualWidth) {
        intendedWidth = actualWidth;
        if(intendedHeight != 0.0){
            intendedHeight = height / width * intendedWidth;
        }
    }
    if(intendedHeight != 0.0 && intendedHeight > actualHeight){
        intendedHeight = actualHeight;
        if(intendedWidth != 0.0){
            intendedWidth = width / height * intendedHeight;
        }
    }
    
    float imgRatio = actualWidth/actualHeight;

    float newHeight = intendedHeight != 0.0 ? intendedHeight : actualHeight / actualWidth * intendedWidth;
    float newWidth = intendedWidth != 0.0 ? intendedWidth : actualWidth / actualHeight * newHeight;

    NSLog(@"src width = %.2f", actualWidth);
    NSLog(@"src height = %.2f", actualHeight);
    NSLog(@"input width = %.2f", width);
    NSLog(@"input height = %.2f", height);
    NSLog(@"intended width = %.2f", intendedWidth);
    NSLog(@"intended height = %.2f", intendedHeight);

    float scale = [self calcScale:actualWidth height:actualHeight newWidth:newWidth newHeight: newHeight];
    
    float destWidth = actualWidth / scale;
    float destHeight = actualHeight / scale;

    NSLog(@"dest width = %.2f", destWidth);
    NSLog(@"dest height = %.2f", destHeight);

    UIImage *cropped = self;

    if(newWidth / newHeight != imgRatio){
        int targetX = roundf(scale * (destWidth - newWidth) / 2);
        int targetY = roundf(scale * (destHeight - newHeight) / 2);

        NSLog(@"targetX = %d", targetX);
        NSLog(@"targetY = %d", targetY);

        CGRect cropRect = CGRectMake(targetX, targetY, roundf(scale * newWidth), roundf(scale * newHeight));
        CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], cropRect);
        cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:self.imageOrientation];
    }

    CGRect rect = CGRectMake(0.0, 0.0, newWidth, newHeight);
    UIGraphicsBeginImageContext(rect.size);
    [cropped drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (CGFloat)calcScale:(CGFloat)width height:(CGFloat)height newWidth:(CGFloat)newWidth newHeight:(CGFloat)newHeight{
    CGFloat scaleW = width / newWidth;
    CGFloat scaleH = height / newHeight;
    NSLog(@"width scale = %.2f", scaleW);
    NSLog(@"height scale = %.2f", scaleH);
    return fmax(1.0, fmin(scaleW, scaleH));
}

- (UIImage *)rotate:(CGFloat) rotate{
    return [self imageRotatedByDegrees:self deg:rotate];
}

- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
