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
- (void)slidingMenuBar:(CZSlidingMenuBar *)menuBar btnOnClickWithItem:(CZSlidingMenuBarItem *)item index:(NSInteger)index;
@end

@interface CZSlidingMenuBar : UIView
@property (weak, nonatomic) id <CZSlidingMenuBarDelegate> delegate;
@property (weak, nonatomic) UIScrollView *linkedScrollView;
@property (strong, nonatomic, readonly) NSArray <CZSlidingMenuBarItem *>*items;
@property (strong, nonatomic) UIColor *defaultColor;
@property (strong, nonatomic) UIColor *selectedColor;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (assign, nonatomic) CGFloat transformScale;

- (void)selectItemAtIndex:(NSInteger)index;
+ (instancetype)slidingMenuBarWithItems:(NSArray<CZSlidingMenuBarItem *> *)items;
@end

