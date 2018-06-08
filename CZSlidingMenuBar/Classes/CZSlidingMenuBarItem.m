//
//  CZListScrollMenuItem.m
//  我是房东
//
//  Created by siu on 2016/11/15.
//  Copyright © 2016年 siu. All rights reserved.
//

#import "CZSlidingMenuBarItem.h"

@implementation CZSlidingMenuBarItem

- (instancetype)init
{
    if (self = [super init]) {
        _contentEdgeInsets = UIEdgeInsetsZero;
        _imageEdgeInsets = UIEdgeInsetsZero;
        _titleEdgeInsets = UIEdgeInsetsZero;
    }
    return self;
}

@end
