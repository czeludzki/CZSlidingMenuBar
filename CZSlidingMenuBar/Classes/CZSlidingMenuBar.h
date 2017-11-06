//
//  CZListScrollView.h
//  ZaiHu
//
//  Created by siu on 15/12/7.
//  Copyright © 2015年 Remind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZSlidingMenuBarItem.h"

@class CZSlidingMenuBar;
@protocol CZSlidingMenuBarDelegate <NSObject>
- (void)slidingMenuBar:(CZSlidingMenuBar *)listView btnOnClickWithItem:(CZSlidingMenuBarItem *)item;
@end

@interface CZSlidingMenuBar : UIView
@property (weak, nonatomic) id <CZSlidingMenuBarDelegate> delegate;
@property (strong, nonatomic, readonly) NSArray <CZSlidingMenuBarItem *>*items;
@property (weak, nonatomic) UIScrollView *linkedScrollView;
@property (strong, nonatomic) UIColor *defaultColor;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) UIColor *selectedColor;
@property (assign, nonatomic) CGFloat transformScale;

- (void)selectButtonAtIndex:(NSInteger)index;
+ (instancetype)slidingMenuBarWithItems:(NSArray<CZSlidingMenuBarItem *> *)items;
@end
