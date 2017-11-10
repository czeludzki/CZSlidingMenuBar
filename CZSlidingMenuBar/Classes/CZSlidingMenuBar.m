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
@property (weak, nonatomic) UIView *scrollLine;
@property (weak, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) NSMutableArray <NSValue *>*itemSizes;
// 记录点击状态,适时禁用contentOffset的监听
@property (assign, nonatomic, getter=isBtnOnClick) BOOL btnOnClick;
/**
 记录dragging状态,为了实时监听 dragging从 YES 变为 NO
 */
@property (assign, nonatomic) BOOL trackingScrollViewIsDragging;
/**
 当trackingScrollView滑动停止时,不需要通知代理,记录滑动停止的状态
 */
@property (assign, nonatomic) BOOL trackingFlag;
// 在相对应的scrollview scrollViewDidScroll 代理方法中,获取 scrollview 的 contextOffsetX 赋值 startX
@property (assign, nonatomic) CGFloat offsetX;
// 在相对应的scrollview scrollViewDidEndScrollingAnimation 代理方法中,获取 scrollview 的 contextOffsetX 赋值 startX
@property (nonatomic ,assign) CGFloat startX;
@end

@implementation CZSlidingMenuBar
@synthesize selectedColor = _selectedColor;

static NSString *CZSlidingMenuBarCollectionCellID = @"CZSlidingMenuBarCollectionCellID";

- (UIColor *)selectedColor
{
    if (!_selectedColor) {
        _selectedColor = [UIColor colorWithRed:208/255.0 green:1/255.0 blue:24/255.0 alpha:1];
    }
    return _selectedColor;
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    self.scrollLine.backgroundColor = _selectedColor;
}

- (UIColor *)barTintColor
{
    if (!_barTintColor) {
        _barTintColor = [UIColor darkGrayColor];
    }
    return _barTintColor;
}

- (void)setLinkedScrollView:(UIScrollView *)linkedScrollView
{
    _linkedScrollView = linkedScrollView;
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(trackingScrollViewLooping:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink = displayLink;
}

- (void)setAverageBarWidth:(NSInteger)averageBarWidth
{
    _averageBarWidth = averageBarWidth;
    if (_averageBarWidth < 0) {
        _averageBarWidth = 0;
    }
    if (_averageBarWidth > 8) {
        _averageBarWidth = 8;
    }
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
    CZSlidingMenuBar *bar = [[CZSlidingMenuBar alloc] initWithItems:items];
    return bar;
}

- (instancetype)initWithItems:(NSArray<CZSlidingMenuBarItem *> *)items
{
    if (self = [super initWithFrame:CGRectZero]) {
        [self changeSelectedIndex:0];
        _items = items;
        _transformScale = 1.2;
        _averageBarWidth = 0;
        _itemFont = [UIFont systemFontOfSize:17];
        
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
        scrollLine.backgroundColor = self.selectedColor;
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
    // 计算 item 的 size
    [self depolyItemSizes];
    [self.scrollLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.frame.size.height);
    }];
}

#pragma mark - Action
- (void)trackingScrollViewLooping:(CADisplayLink *)sender
{
    if (self.linkedScrollView.isDragging) {
        [self setOffsetX:self.linkedScrollView.contentOffset.x];
    }
    
    if (self.trackingScrollViewIsDragging && !self.linkedScrollView.isDragging) {
        self.trackingFlag = YES;
        [self sourceScrollViewDidEndDecelerating:self.linkedScrollView];
        self.trackingFlag = NO;
    }
    self.trackingScrollViewIsDragging = self.linkedScrollView.isDragging;
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
    cell.contentButton.titleLabel.font = self.itemFont;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize = [self.itemSizes[indexPath.item] CGSizeValue];
    return CGSizeMake(itemSize.width, self.frame.size.height);
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

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(CZSlidingMenuBarCollectionCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 计算当前选中的item的center位置
    if (self.selectedIndex == indexPath.item) {
        [self.scrollLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(-self.frame.size.width * .5f + cell.center.x);
            make.width.mas_equalTo([self.itemSizes[indexPath.item] CGSizeValue].width);
        }];
        [self layoutIfNeeded];
        cell.contentButton.transform = CGAffineTransformMakeScale(self.transformScale, self.transformScale);
        cell.contentButton.tintColor = self.selectedColor;
    }else{
        cell.contentButton.transform = CGAffineTransformIdentity;
        cell.contentButton.tintColor = self.barTintColor;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectItemAtIndex:indexPath.item];
}

#pragma mark - Helper
- (void)depolyItemSizes
{
    self.itemSizes = [NSMutableArray array];
    if (self.averageBarWidth == 0) {
        UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        for (CZSlidingMenuBarItem *item in self.items) {
            [tempBtn setTitle:item.title forState:UIControlStateNormal];
            [tempBtn setImage:item.image forState:UIControlStateNormal];
            tempBtn.contentEdgeInsets = item.contentEdgeInsets;
            tempBtn.titleEdgeInsets = item.titleEdgeInsets;
            tempBtn.imageEdgeInsets = item.imageEdgeInsets;
            tempBtn.titleLabel.font = self.itemFont;
            [tempBtn sizeToFit];
            [self.itemSizes addObject:[NSValue valueWithCGSize:tempBtn.bounds.size]];
        }
    }else{
        for (int i = 0; i < self.items.count; i++) {
            [self.itemSizes addObject:[NSValue valueWithCGSize:CGSizeMake(self.frame.size.width / self.averageBarWidth, self.frame.size.height)]];
        }
    }
}

- (void)makeAllBtnDeselected
{
    for (CZSlidingMenuBarCollectionCell *cell in self.collectionView.visibleCells) {
        cell.contentButton.tintColor = self.barTintColor;
        cell.contentButton.transform = CGAffineTransformIdentity;
    }
}

/*
- (void)selectItemAtIndex:(NSInteger)index
{
    __weak __typeof (self) weakSelf = self;
    [self changeSelectedIndex:index];
    [self makeAllBtnDeselected];
    CZSlidingMenuBarCollectionCell *cell = (CZSlidingMenuBarCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    NSLog(@"selectItemAtIndex  --  cell = %@",cell);
    UIButton *button = cell.contentButton;
    button.tintColor = self.selectedColor;
    button.transform = CGAffineTransformMakeScale(self.transformScale, self.transformScale);
    [self.scrollLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(cell.fs_width);
        make.centerX.mas_equalTo(-self.frame.size.width * .5f + cell.fs_centerX);
    }];
    [UIView animateWithDuration:.3f animations:^{
        [weakSelf layoutIfNeeded];
        if (cell.fs_centerX > weakSelf.collectionView.contentSize.width/2) { // 目前选中的item在整个collectionView的右方
            CGPoint offset = cell.fs_centerX + UIWindowWidth/2 < weakSelf.collectionView.contentSize.width ? CGPointMake(cell.fs_centerX - UIWindowWidth / 2, 0) : CGPointMake(weakSelf.collectionView.contentSize.width - UIWindowWidth, 0);
            if (offset.x >= 0) [weakSelf.collectionView setContentOffset:offset];
        }else{      // 目前选中的item在整个collectionView的左方
            CGPoint offset = cell.fs_centerX > UIWindowWidth/2 ? CGPointMake(cell.fs_centerX - UIWindowWidth / 2, 0) : CGPointMake(0, 0);
            if ((offset.x + weakSelf.fs_width) <= weakSelf.collectionView.contentSize.width) [weakSelf.collectionView setContentOffset:offset];
        }
    } completion:^(BOOL finished) {
        
    }];
    self.btnOnClick = YES;
    if ([self.delegate respondsToSelector:@selector(slidingMenuBar:btnOnClickWithItem:index:)]) {
        [self.delegate slidingMenuBar:self btnOnClickWithItem:self.items[index] index:index];
    }
    self.startX = UIWindowWidth * index;
    self.btnOnClick = NO;
}
*/

- (void)selectItemAtIndex:(NSInteger)index
{
    __weak __typeof (self) weakSelf = self;
    [self changeSelectedIndex:index];
    [self makeAllBtnDeselected];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    // 当cell存在
    CZSlidingMenuBarCollectionCell *cell = (CZSlidingMenuBarCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (cell) {
        UIButton *button = cell.contentButton;
        button.tintColor = self.selectedColor;
        button.transform = CGAffineTransformMakeScale(self.transformScale, self.transformScale);
        [self.scrollLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(cell.fs_width);
            make.centerX.mas_equalTo(-self.frame.size.width * .5f + cell.fs_centerX);
        }];
        [UIView animateWithDuration:.3f animations:^{
            [weakSelf layoutIfNeeded];
        } completion:nil];
    }
    
    self.btnOnClick = YES;
    if ([self.delegate respondsToSelector:@selector(slidingMenuBar:didSelectItem:atIndex:)]) {
        [self.delegate slidingMenuBar:self didSelectItem:self.items[index] atIndex:index];
    }
    self.startX = UIWindowWidth * index;
    self.btnOnClick = NO;
}

- (void)sourceScrollViewDidEndDecelerating:(UIScrollView *)sourceScrollView
{
    self.startX = sourceScrollView.contentOffset.x;
    CGPoint offset = sourceScrollView.contentOffset;
    CGFloat offsetX = offset.x;
    CGFloat width = sourceScrollView.frame.size.width;
    int pageNum = (offsetX + .5f *  width) / width;
    [self selectItemAtIndex:pageNum];
}

- (void)changeSelectedIndex:(NSInteger)index
{
    [self willChangeValueForKey:@"selectedIndex"];
    _selectedIndex = index;
    [self didChangeValueForKey:@"selectedIndex"];
}

- (void)setOffsetX:(CGFloat)offsetX
{
    if (self.isBtnOnClick) return;
    _offsetX = offsetX;
    CZSlidingMenuBarCollectionCell *sourecCell = nil;
    CZSlidingMenuBarCollectionCell *targetCell = nil;
    
    NSInteger targetIndex = 0;
    NSInteger sourceIndex = 0;
    
    CGFloat progress = fabs(_offsetX - self.startX) / UIWindowWidth;    // 滑动进度
    
    if (_offsetX > self.startX) {   // 向右
        if (progress != 0) {
            sourceIndex = self.selectedIndex;
            targetIndex = sourceIndex + 1;
            if (progress >= 1) {
                _selectedIndex++;
                self.startX += UIWindowWidth;
            }
        }
        if (targetIndex >= self.items.count) return;
        sourecCell = (CZSlidingMenuBarCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:sourceIndex inSection:0]];
        targetCell = (CZSlidingMenuBarCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0]];
    }
    if (_offsetX < self.startX) {  // 向左
        if (progress != 0) {
            sourceIndex = self.selectedIndex;
            targetIndex = sourceIndex - 1;
            if (progress >= 1) {
                _selectedIndex--;
                self.startX -= UIWindowWidth;
            }
        }
        if (targetIndex < 0) return;
        sourecCell = (CZSlidingMenuBarCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:sourceIndex inSection:0]];
        targetCell = (CZSlidingMenuBarCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0]];
    }
    if (_offsetX == self.startX) {
        return;
    }

    CGFloat scrollLineW = sourecCell.fs_width + (targetCell.fs_width - sourecCell.fs_width) * progress;
    CGFloat scrollLineCenterX = sourecCell.fs_centerX + ((targetCell.fs_centerX - sourecCell.fs_centerX) * progress);
    [self.scrollLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(scrollLineW);
        make.centerX.mas_equalTo(-self.frame.size.width * .5f + scrollLineCenterX);
    }];
    
    // 改变颜色
    // RGB值获取
    CGFloat selectedR = [self.selectedColor r];
    CGFloat selectedG = [self.selectedColor g];
    CGFloat selectedB = [self.selectedColor b];
    
    CGFloat defaultR = [self.barTintColor r];
    CGFloat defaultG = [self.barTintColor g];
    CGFloat defaultB = [self.barTintColor b];
    
    // start + (end - start) * progress
    UIColor *nextColor = kRGBColor(defaultR + (selectedR - defaultR)*progress, defaultG + (selectedG - defaultG)*progress, defaultB + (selectedB - defaultB)*progress);
    targetCell.contentButton.tintColor = nextColor;
    
    UIColor *currentColor = kRGBColor(selectedR + (defaultR - selectedR)*progress, selectedG + (defaultG - selectedG)*progress, selectedB + (defaultB - selectedB)*progress);
    sourecCell.contentButton.tintColor = currentColor;
    
    // 改变大小
    targetCell.contentButton.transform = CGAffineTransformMakeScale(1 + (self.transformScale - 1) * progress, 1 + (self.transformScale - 1) * progress);
    sourecCell.contentButton.transform = CGAffineTransformMakeScale(self.transformScale + (1 - self.transformScale) * progress, self.transformScale + (1 - self.transformScale) * progress);

}

#pragma mark - override
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self.displayLink invalidate];
    }
}

@end
