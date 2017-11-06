//
//  UIView+CZSlidingMenuBar_ViewExtension.m
//  CZSlidingMenuBar
//
//  Created by siu on 6/11/17.
//

#import "UIView+CZSlidingMenuBar_ViewExtension.h"

@implementation UIView (CZSlidingMenuBar_ViewExtension)
- (CGFloat)fs_width
{
    return CGRectGetWidth(self.frame);
}

- (void)setFs_width:(CGFloat)fs_width
{
    self.frame = CGRectMake(self.fs_left, self.fs_top, fs_width, self.fs_height);
}

- (CGFloat)fs_height
{
    return CGRectGetHeight(self.frame);
}

- (void)setFs_height:(CGFloat)fs_height
{
    self.frame = CGRectMake(self.fs_left, self.fs_top, self.fs_width, fs_height);
}

- (CGFloat)fs_top
{
    return CGRectGetMinY(self.frame);
}

- (void)setFs_top:(CGFloat)fs_top
{
    self.frame = CGRectMake(self.fs_left, fs_top, self.fs_width, self.fs_height);
}

- (CGFloat)fs_bottom
{
    return CGRectGetMaxY(self.frame);
}

- (void)setFs_bottom:(CGFloat)fs_bottom
{
    self.fs_top = fs_bottom - self.fs_height;
}

- (CGFloat)fs_left
{
    return CGRectGetMinX(self.frame);
}

- (void)setFs_left:(CGFloat)fs_left
{
    self.frame = CGRectMake(fs_left, self.fs_top, self.fs_width, self.fs_height);
}

- (CGFloat)fs_right
{
    return CGRectGetMaxX(self.frame);
}

- (void)setFs_right:(CGFloat)fs_right
{
    self.fs_left = self.fs_right - self.fs_width;
}

- (CGFloat)fs_centerX
{
    return self.center.x;
}

- (void)setFs_centerX:(CGFloat)fs_centerX
{
    CGPoint center = self.center;
    center.x = fs_centerX;
    self.center = center;
}

- (CGFloat)fs_centerY
{
    return self.center.y;
}

- (void)setFs_centerY:(CGFloat)fs_centerY
{
    CGPoint center = self.center;
    center.y = fs_centerY;
    self.center = center;
}
@end
