//
//  NSString+CZSlidingMenuBar_StringExtension.m
//  CZSlidingMenuBar
//
//  Created by siu on 6/11/17.
//

#import "NSString+CZSlidingMenuBar_StringExtension.h"

@implementation NSString (CZSlidingMenuBar_StringExtension)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *dict = @{NSFontAttributeName: font};
    CGSize textSize = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return textSize;
}

@end
