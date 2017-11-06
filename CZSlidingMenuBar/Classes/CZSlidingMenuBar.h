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
@property (strong, nonatomic, readonly) NSArray <CZSlidingMenuBarItem *>*items;
@property (weak, nonatomic) id <CZSlidingMenuBarDelegate> delegate;
// 需要联动的 scrollView
@property (weak, nonatomic) UIScrollView *linkedScrollView;
// 默认颜色
@property (strong, nonatomic) UIColor *defaultColor;
// 选中的颜色 || 底部滚动条的颜色
@property (strong, nonatomic) UIColor *selectedColor;
// 当前选中
@property (assign, nonatomic, readonly) NSInteger selectedIndex;
// 选中后放大的比例 default is 1.2
@property (assign, nonatomic) CGFloat transformScale;

- (void)selectItemAtIndex:(NSInteger)index;
+ (instancetype)slidingMenuBarWithItems:(NSArray<CZSlidingMenuBarItem *> *)items;
@end

