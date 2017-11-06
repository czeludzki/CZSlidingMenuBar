//
//  CZListScrollView.m
//  ZaiHu
//
//  Created by siu on 15/12/7.
//  Copyright © 2015年 Remind. All rights reserved.
//

#import "CZSlidingMenuBar.h"
#import "CZSlidingMenuBarItem.h"
#import "Masonry.h"
#import "NSString+CZSlidingMenuBar_StringExtension.h"
#import "UIView+CZSlidingMenuBar_ViewExtension.h"
#import "UIColor+CZSlidingMenu_ColorExtension.h"

#define UIWindowWidth [UIScreen mainScreen].bounds.size.width
#define kRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@interface CZSlidingMenuBar ()
@property (strong,nonatomic) NSMutableArray<UIButton *> *scrollButtonArray;
@property (strong,nonatomic) UIView *scrollLine;
@property (assign, nonatomic, getter=isBtnOnClick) BOOL btnOnClick;
@property (weak, nonatomic) UIView *testView;
@property (assign, nonatomic) CGFloat transFormScale;
@end

@implementation CZSlidingMenuBar
@synthesize selectedColor = _selectedColor;
@dynamic delegate;

- (CGFloat)transFormScale
{
    if (_transFormScale == 0) {
        _transFormScale = 1.15;
    }
    return _transFormScale;
}

- (UIColor *)selectedColor
{
    if (!_selectedColor) {
        _selectedColor = [UIColor colorWithRed:208/255 green:0/255 blue:24/255 alpha:1];
    }
    return _selectedColor;
}

- (NSMutableArray<UIButton *> *)scrollButtonArray
{
    if (!_scrollButtonArray) {
        _scrollButtonArray = [NSMutableArray array];
    }
    return _scrollButtonArray;
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    self.scrollLine.backgroundColor = _selectedColor;
}

- (instancetype)init
{
    __weak __typeof(self)weakSelf = self;
    if (self = [super init]) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor blueColor];
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakSelf);
            make.height.mas_equalTo(4);
            make.width.mas_equalTo(60);
            make.top.mas_equalTo(40);
        }];
        [self layoutIfNeeded];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        NSAssert(YES, @"不要直接使用initWithFrame OR ini方法直接创建CZListScrollView");
    }
    return self;
}

+ (instancetype)slidingMenuBarWithItems:(NSArray<CZSlidingMenuBarItem *> *)items andFrame:(CGRect)frame
{
    CZSlidingMenuBar *sView = [[CZSlidingMenuBar alloc] initWithItems:items andFrame:frame];
    return sView;
}

- (instancetype)initWithItems:(NSArray <CZSlidingMenuBarItem *>*)items andFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _items = items;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.scrollsToTop = NO;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1.4f)];
        view.backgroundColor = self.selectedColor;
        [self addSubview:view];
        self.scrollLine = view;
        
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat btnY = 0;
        CGFloat btnH = frame.size.height - 1.4f;
        CGFloat btnW = 0;
        
        UIButton *lastBtn = nil;
        CGFloat contentSizeW = 0;
        for (int i = 0; i < items.count; i++) {
            CZSlidingMenuBarItem *item = items[i];
            NSString *title = item.title;
            CGSize textSize = [title sizeWithFont:[UIFont boldSystemFontOfSize:16] maxSize:CGSizeMake(MAXFLOAT, frame.size.height)];
            btnW = textSize.width > UIWindowWidth /4 ? textSize.width + 10 : UIWindowWidth / 4;
            CGFloat btnX = lastBtn.frame.size.width;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            [btn setTitle:title forState:UIControlStateNormal];
            btn.tintColor = self.selectedColor;
            btn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
            if (item.imageName.length > 0) [btn setImage:[UIImage imageNamed:item.imageName] forState:UIControlStateNormal];
            btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
            [btn addTarget:self action:@selector(listBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [self.scrollButtonArray addObject:btn];
            lastBtn = btn;
            contentSizeW += btn.fs_width;
        }
        
        self.contentSize = CGSizeMake(contentSizeW, btnH);
        self.scrollLine.fs_top = btnH;
    }
    return self;
}

- (void)listBtnOnClick:(UIButton *)button
{
    __weak __typeof (self) weakSelf = self;
    NSInteger index = [self.scrollButtonArray indexOfObject:button];    // 选中第几个
    self.selectedIndex = index;
    [self makeAllBtnDeSelection];
    button.tintColor = self.selectedColor;
    button.transform = CGAffineTransformMakeScale(self.transFormScale, self.transFormScale);
    [UIView animateWithDuration:.3f animations:^{
        weakSelf.scrollLine.fs_width = button.fs_width;
        weakSelf.scrollLine.fs_centerX = button.fs_centerX;
        if (button.fs_centerX > weakSelf.contentSize.width/2) { // 按钮在整个scrollview的右方
            CGPoint offset = button.fs_centerX + UIWindowWidth/2 < weakSelf.contentSize.width ? CGPointMake(button.fs_centerX - UIWindowWidth / 2, 0) : CGPointMake(weakSelf.contentSize.width - UIWindowWidth, 0);
            if (offset.x >= 0) [weakSelf setContentOffset:offset];
        }else{      // 左方
            CGPoint offset = button.fs_centerX > UIWindowWidth/2 ? CGPointMake(button.fs_centerX - UIWindowWidth / 2, 0) : CGPointMake(0, 0);
            if ((offset.x + weakSelf.fs_width) <= weakSelf.contentSize.width) [weakSelf setContentOffset:offset];
        }
    } completion:^(BOOL finished) {
        
    }];
    self.btnOnClick = YES;
    if ([self.delegate respondsToSelector:@selector(listScrollMenu:btnOnClickWithItem:)]) {
        [self.delegate listScrollMenu:self btnOnClickWithItem:self.items[index]];
        self.startX = UIWindowWidth * index;
    }
    self.btnOnClick = NO;
}

- (void)makeAllBtnDeSelection
{
    for (UIButton *b in self.scrollButtonArray) {
        b.tintColor = [UIColor darkGrayColor];
        b.transform = CGAffineTransformIdentity;
    }
}

- (void)selectButtonAtIndex:(NSInteger)index
{
    UIButton *b = self.scrollButtonArray[index];
    [self listBtnOnClick:b];
}

- (void)sourceScrollViewDidEndDecelerating:(UIScrollView *)sourceScrollView
{
//    self.btnOnClick = NO;
    self.startX = sourceScrollView.contentOffset.x;
    CGPoint offset = sourceScrollView.contentOffset;
    CGFloat offsetX = offset.x;
    CGFloat width = sourceScrollView.frame.size.width;
    int pageNum = (offsetX + .5f *  width) / width;
    [self selectButtonAtIndex:pageNum];
}

- (void)setOffsetX:(CGFloat)offsetX
{
    if (self.isBtnOnClick) return;
    _offsetX = offsetX;
    UIButton *sourecBtn = nil;
    UIButton *targetBtn = nil;
    
    NSInteger targetIndex = 0;
    NSInteger sourceIndex = 0;
    
    CGFloat progress = fabs(_offsetX - self.startX) / UIWindowWidth;    // 滑动进度
    
    if (_offsetX > self.startX) {   // 向右
        if (progress != 0) {
            sourceIndex = self.selectedIndex;
            targetIndex = sourceIndex + 1;
            if (progress >= 1) {
                self.selectedIndex ++;
                self.startX += UIWindowWidth;
            }
        }
        if (targetIndex >= self.scrollButtonArray.count) return;
        sourecBtn = [self.scrollButtonArray objectAtIndex:sourceIndex];
        targetBtn = [self.scrollButtonArray objectAtIndex:targetIndex];
    }
    if (_offsetX < self.startX) {  // 向左
        if (progress != 0) {
            sourceIndex = self.selectedIndex;
            targetIndex = sourceIndex - 1;
            if (progress >= 1) {
                self.selectedIndex--;
                self.startX -= UIWindowWidth;
            }
        }
        if (targetIndex < 0) return;
        sourecBtn = [self.scrollButtonArray objectAtIndex:sourceIndex];
        targetBtn = [self.scrollButtonArray objectAtIndex:targetIndex];
    }
    if (_offsetX == self.startX) {
        return;
    }

    self.scrollLine.fs_width = sourecBtn.fs_width + ((targetBtn.fs_width - sourecBtn.fs_width) * progress);
    self.scrollLine.fs_centerX = sourecBtn.fs_centerX + ((targetBtn.fs_centerX - sourecBtn.fs_centerX) * progress);
    
    // 改变颜色
    // RGB值获取
    CGFloat R = [self.selectedColor r];
    CGFloat G = [self.selectedColor g];
    CGFloat B = [self.selectedColor b];
    
    // start + (end - start)*progress
    // 99 209 69
    UIColor *nextColor = kRGBColor(104.0 + (R - 104.0)*progress, 104.0 + (G - 104.0)*progress, 104.0 + (B - 104.0)*progress);
    targetBtn.titleLabel.textColor = nextColor;
    
    // 104 104 104
    UIColor *currentColor = kRGBColor(R + (104.0 - R)*progress, G + (104.0 - G)*progress, B + (104.0 - B)*progress);
    sourecBtn.titleLabel.textColor = currentColor;
    
    // 改变大小
    targetBtn.transform = CGAffineTransformMakeScale(1 + (self.transFormScale - 1) * progress, 1 + (self.transFormScale - 1) * progress);
    sourecBtn.transform = CGAffineTransformMakeScale(self.transFormScale + (1 - self.transFormScale) * progress, self.transFormScale + (1 - self.transFormScale) * progress);
}

@end
