//
//  CZListScrollMenuItem.h
//  我是房东
//
//  Created by siu on 2016/11/15.
//  Copyright © 2016年 siu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZSlidingMenuBarItem : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) UIImage *image;
@property (assign, nonatomic) UIEdgeInsets contentEdgeInsets;
@property (assign, nonatomic) UIEdgeInsets titleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets imageEdgeInsets;
@end
