//
//  UIImage+TPAdditions.m
//  veraflick
//
//  Created by Punit on 12/15/13.
//  Copyright (c) 2013 Punit. All rights reserved.
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