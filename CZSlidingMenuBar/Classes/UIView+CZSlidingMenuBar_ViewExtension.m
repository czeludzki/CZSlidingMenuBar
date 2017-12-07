//
//  UIView+CZSlidingMenuBar_ViewExtension.m
//  CZSlidingMenuBar
//
//  Created by siu on 6/11/17.
//

#import "UIView+CZSlidingMenuBar_ViewExtension.h"

@implementation UIView (CZSlidingMenuBar_ViewExtension)
- (CGFloat)CSM_width
{
    return CGRectGetWidth(self.frame);
}

- (void)setCSM_width:(CGFloat)CSM_width
{
    self.frame = CGRectMake(self.CSM_left, self.CSM_top, CSM_width, self.CSM_height);
}

- (CGFloat)CSM_height
{
    return CGRectGetHeight(self.frame);
}

- (void)setCSM_height:(CGFloat)CSM_height
{
    self.frame = CGRectMake(self.CSM_left, self.CSM_top, self.CSM_width, CSM_height);
}

- (CGFloat)CSM_top
{
    return CGRectGetMinY(self.frame);
}

- (void)setCSM_top:(CGFloat)CSM_top
{
    self.frame = CGRectMake(self.CSM_left, CSM_top, self.CSM_width, self.CSM_height);
}

- (CGFloat)CSM_bottom
{
    return CGRectGetMaxY(self.frame);
}

- (void)setCSM_bottom:(CGFloat)CSM_bottom
{
    self.CSM_top = CSM_bottom - self.CSM_height;
}

- (CGFloat)CSM_left
{
    return CGRectGetMinX(self.frame);
}

- (void)setCSM_left:(CGFloat)CSM_left
{
    self.frame = CGRectMake(CSM_left, self.CSM_top, self.CSM_width, self.CSM_height);
}

- (CGFloat)CSM_right
{
    return CGRectGetMaxX(self.frame);
}

- (void)setCSM_right:(CGFloat)CSM_right
{
    self.CSM_left = self.CSM_right - self.CSM_width;
}

- (CGFloat)CSM_centerX
{
    return self.center.x;
}

- (void)setCSM_centerX:(CGFloat)CSM_centerX
{
    CGPoint center = self.center;
    center.x = CSM_centerX;
    self.center = center;
}

- (CGFloat)CSM_centerY
{
    return self.center.y;
}

- (void)setCSM_centerY:(CGFloat)CSM_centerY
{
    CGPoint center = self.center;
    center.y = CSM_centerY;
    self.center = center;
}
@end
