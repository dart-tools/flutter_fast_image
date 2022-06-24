#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (adjust)

- (UIImage *)scaleWithWidth:(CGFloat)width height:(CGFloat)height;
- (UIImage *)rotate:(CGFloat) rotate;
- (CGFloat)calcScale:(CGFloat)width height:(CGFloat)height newWidth:(CGFloat)newWidth newHeight:(CGFloat)newHeight;
@end