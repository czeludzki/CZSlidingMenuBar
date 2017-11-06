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
@protocol CZListScrollMenuDelegate <UIScrollViewDelegate>
- (void)listScrollMenu:(CZSlidingMenuBar *)listView btnOnClickWithItem:(CZSlidingMenuBarItem *)item;
@end

@interface CZSlidingMenuBar : UIView
@property (strong, nonatomic,readonly) NSArray <CZSlidingMenuBarItem *>*items;

@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,weak) id<CZListScrollMenuDelegate> delegate;
@property (strong, nonatomic) UIColor *selectedColor;
// 在相对应的scrollview scrollViewDidScroll 代理方法中,获取 scrollview 的 contextOffsetX 赋值 startX
@property (assign, nonatomic) CGFloat offsetX;
// 在相对应的scrollview scrollViewDidEndScrollingAnimation 代理方法中,获取 scrollview 的 contextOffsetX 赋值 startX
@property (nonatomic ,assign) CGFloat startX;

- (void)sourceScrollViewDidEndDecelerating:(UIScrollView *)sourceScrollView;

- (void)selectButtonAtIndex:(NSInteger)index;
+ (instancetype)slidingMenuBarWithItems:(NSArray<CZSlidingMenuBarItem *> *)items;
@end
