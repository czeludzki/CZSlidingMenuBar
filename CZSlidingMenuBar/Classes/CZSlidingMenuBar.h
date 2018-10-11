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
/**
 不论滑动后选定item 或 点击item选定,都会走这个方法
 */
- (void)slidingMenuBar:(CZSlidingMenuBar *)menuBar didSelectedItem:(CZSlidingMenuBarItem *)item atIndex:(NSInteger)index;
@end

@interface CZSlidingMenuBar : UIView
@property (strong, nonatomic, readonly) NSArray <CZSlidingMenuBarItem *>*items;
/**
 delegate
 */
@property (weak, nonatomic) id <CZSlidingMenuBarDelegate> delegate;
/**
 需要联动的 scrollView
 */
@property (weak, nonatomic) UIScrollView *linkedScrollView;
/**
 默认颜色
 */
@property (strong, nonatomic) UIColor *barTintColor;
/**
 选中的颜色 || 底部滚动条的颜色
 */
@property (strong, nonatomic) UIColor *selectedColor;
/**
 底部线的颜色,作为底部滚动条的背景
 */
@property (strong, nonatomic) UIColor *bottomLineColor;
/**
 自己翻译
 */
@property (strong, nonatomic) UIColor *nippleColor;
/**
 font
 */
@property (strong, nonatomic) UIFont *itemFont;
/**
 当前选中的 index
 */
@property (assign, nonatomic, readonly) NSInteger selectedIndex;
/**
 选中后放大的比例 default is 1.2
 */
@property (assign, nonatomic) CGFloat transformScale;
/**
 根据bar的宽度均分item, 可决定item的宽度是否自适应 及 item 的宽度
 取值范围 : 0 ~ 8
    default is 0
    if 0, item 将根据自身内容自适应 ----> |A|AAA|AAAAAAAAA|
    if 1 ~ 8, item宽度 = bar.width / 1 ~ 8  ----> |  a  | aaa |aaaaa|
 */
@property (assign, nonatomic) NSInteger averageBarWidth;

/**
 底部游标宽度，如果大于0，则由averageBarWidth计算得到的游标宽度无效
 */
@property (assign, nonatomic) CGFloat scrollLineWidth;

#pragma mark - initialization
+ (instancetype)slidingMenuBarWithItems:(NSArray<CZSlidingMenuBarItem *> *)items;
- (instancetype)initWithItems:(NSArray<CZSlidingMenuBarItem *> *)items;

#pragma mark - helper
- (void)selectItemAtIndex:(NSInteger)index;
/**
 你可能会根据需求随时改变 CZSlidingMenuBarItem.showNipple 的属性, 但 CZSlidingMenuBar 并不知道你的业务细则, 所以提供 reloadItemsNippleState 方法 将nipple显示变更响应到视图上
 */
- (void)reloadItemsNippleState;
@end

