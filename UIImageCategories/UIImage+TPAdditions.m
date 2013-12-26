//
//  UIImage+TPAdditions.m
//  veraflick
//
//  This was taken from gists by author Agassiyzh: https://gist.github.com/agassiyzh/1381253
//

#import "UIImage+TPAdditions.h"

@implementation UIImage (TPAdditions)
- (UIImage*)imageScaledToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end