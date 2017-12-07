//
//  UIColor+CZSlidingMenu_ColorExtension.m
//  CZSlidingMenuBar
//
//  Created by siu on 6/11/17.
//

#import "UIColor+CZSlidingMenu_ColorExtension.h"

@implementation UIColor (CZSlidingMenu_ColorExtension)
- (CGFloat)CSM_r
{
    CGColorRef color = self.CGColor;
    CGFloat R = 0;
    int numComponents = (int)CGColorGetNumberOfComponents(color);
    if (numComponents == 4){
        const CGFloat *components = CGColorGetComponents(color);
        R = components[0] * 255;
    }
    return R;
}

- (CGFloat)CSM_g
{
    CGColorRef color = self.CGColor;
    CGFloat G = 0;
    int numComponents = (int)CGColorGetNumberOfComponents(color);
    if (numComponents == 4){
        const CGFloat *components = CGColorGetComponents(color);
        G = components[1] * 255;
    }
    return G;
}

- (CGFloat)CSM_b
{
    CGColorRef color = self.CGColor;
    CGFloat B = 0;
    int numComponents = (int)CGColorGetNumberOfComponents(color);
    if (numComponents == 4){
        const CGFloat *components = CGColorGetComponents(color);
        B = components[2] * 255;
    }
    return B;
}
@end
