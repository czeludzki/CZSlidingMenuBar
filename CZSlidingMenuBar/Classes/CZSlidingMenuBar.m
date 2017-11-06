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
#import "CZSlidingMenuBarCollectionCell.h"

#define UIWindowWidth [UIScreen mainScreen].bounds.size.width
#define kRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@interface CZSlidingMenuBar () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak,nonatomic) UIView *scrollLine;

@property (strong,nonatomic) NSMutableArray<UIButton *> *scrollButtonArray;
@property (assign, nonatomic, getter=isBtnOnClick) BOOL btnOnClick;
@property (assign, nonatomic) CGFloat transformScale;
@end

@implementation CZSlidingMenuBar
@synthesize selectedColor = _selectedColor;
@dynamic delegate;

static NSString *CZSlidingMenuBarCollectionCellID = @"CZSlidingMenuBarCollectionCellID";

- (CGFloat)_transformScale
{
    if (_transformScale == 0) {
        _transformScale = 1.15;
    }
    return _transformScale;
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

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        NSAssert(YES, @"不要直接使用initWithFrame OR ini方法直接创建CZListScrollView");
    }
    return self;
}

+ (instancetype)slidingMenuBarWithItems:(NSArray<CZSlidingMenuBarItem *> *)items
{
    CZSlidingMenuBar *sView = [[CZSlidingMenuBar alloc] initWithItems:items];
    return sView;
}

- (instancetype)initWithItems:(NSArray <CZSlidingMenuBarItem *>*)items
{
    if (self = [super initWithFrame:CGRectZero]) {
        _selectedIndex = 3;
        _items = items;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        [collectionView registerClass:[CZSlidingMenuBarCollectionCell class] forCellWithReuseIdentifier:CZSlidingMenuBarCollectionCellID];
        
        UIView *scrollLine = [[UIView alloc] initWithFrame:CGRectZero];
        scrollLine.backgroundColor = [UIColor redColor];
        [collectionView addSubview:scrollLine];
        self.scrollLine = scrollLine;
        [scrollLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
            make.height.mas_equalTo(2);
            make.width.mas_equalTo(UIWindowWidth / 5);
        }];
    }
    return self;
}

#pragma mark - Overide
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.scrollLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.frame.size.height);
    }];
}

#pragma mark - <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CZSlidingMenuBarCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CZSlidingMenuBarCollectionCellID forIndexPath:indexPath];
    cell.item = self.items[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, 44);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 计算当前选中的item的center位置
    if (self.selectedIndex == indexPath.item) {
        [self.scrollLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(-self.frame.size.width * .5f + cell.center.x);
        }];
        [self layoutIfNeeded];
    }
}

/*
- (void)listBtnOnClick:(UIButton *)button
{
    __weak __typeof (self) weakSelf = self;
    NSInteger index = [self.scrollButtonArray indexOfObject:button];    // 选中第几个
    self.selectedIndex = index;
    [self makeAllBtnDeSelection];
    button.tintColor = self.selectedColor;
    button.transform = CGAffineTransformMakeScale(self.transformScale, self.transformScale);
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
*/
 
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
//    [self listBtnOnClick:b];
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
    targetBtn.transform = CGAffineTransformMakeScale(1 + (self.transformScale - 1) * progress, 1 + (self.transformScale - 1) * progress);
    sourecBtn.transform = CGAffineTransformMakeScale(self.transformScale + (1 - self.transformScale) * progress, self.transformScale + (1 - self.transformScale) * progress);
}

@end
