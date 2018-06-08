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

#define kRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@interface CZSlidingMenuBar () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, CZSlidingMenuBarCollectionCell_nippleSource>
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UIView *scrollLine;
@property (weak, nonatomic) UIView *bottomLine;
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
@synthesize selectedColor   = _selectedColor;
@synthesize bottomLineColor = _bottomLineColor;

static NSString *CZSlidingMenuBarCollectionCellID = @"CZSlidingMenuBarCollectionCellID";

- (UIColor *)selectedColor
{
    if (!_selectedColor) {
        _selectedColor = [UIColor colorWithRed:208/255.0 green:1/255.0 blue:24/255.0 alpha:1];
    }
    return _selectedColor;
}

- (UIColor *)bottomLineColor
{
    if (!_bottomLineColor) {
        _bottomLineColor = [UIColor clearColor];
    }
    return _bottomLineColor;
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    self.scrollLine.backgroundColor = _selectedColor;
}

- (void)setBottomLineColor:(UIColor *)bottomLineColor
{
    _bottomLineColor = bottomLineColor;
    self.bottomLine.backgroundColor = _bottomLineColor;
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
        NSAssert(YES, @"不要直接使用 initWithFrame || init 方法直接创建 CZListScrollView");
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
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        bottomLine.backgroundColor = self.bottomLineColor;
        [self addSubview:bottomLine];
        self.bottomLine = bottomLine;
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_offset(0);
            make.right.mas_offset(0);
            make.left.mas_offset(0);
            make.height.mas_equalTo(2);
        }];
        
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
            make.width.mas_equalTo(1);
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
    cell.nippleSource = self;
    cell.contentButton.titleLabel.font = self.itemFont;
    cell.item = self.items[indexPath.item];
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
    self.btnOnClick = YES;
    [self selectItemAtIndex:indexPath.item];
    self.btnOnClick = NO;
}

#pragma mark - CZSlidingMenuBarCollectionCell_nippleSource
- (UIView *)slidingMenuBarCell:(CZSlidingMenuBarCollectionCell *)menuBarCell nippleForItem:(CZSlidingMenuBarItem *)item
{
    UIView *nipple = nil;
    if ([self.delegate respondsToSelector:@selector(slidingMenuBar:nippleForItem:index:)]) {
        nipple = [self.delegate slidingMenuBar:self nippleForItem:item index:[self.items indexOfObject:item]];
    }
    return nipple;
}

- (CGSize)slidingMenuBarCell:(CZSlidingMenuBarCollectionCell *)menuBarCell nippleSizeForItem:(CZSlidingMenuBarItem *)item
{
    CGSize size = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(slidingMenuBar:nippleSizeForItem:index:)]) {
        size = [self.delegate slidingMenuBar:self nippleSizeForItem:item index:[self.items indexOfObject:item]];
    }
    return size;
}

- (CGPoint)slidingMenuBarCell:(CZSlidingMenuBarCollectionCell *)menuBarCell nipplePositionForItem:(CZSlidingMenuBarItem *)item
{
    CGPoint position = CGPointZero;
    if ([self.delegate respondsToSelector:@selector(slidingMenuBar:nipplePositionForItem:index:)]) {
        position = [self.delegate slidingMenuBar:self nipplePositionForItem:item index:[self.items indexOfObject:item]];
    }
    return position;
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
            make.width.mas_equalTo(cell.CSM_width);
            make.centerX.mas_equalTo(-self.frame.size.width * .5f + cell.CSM_centerX);
        }];
        [UIView animateWithDuration:.3f animations:^{
            [weakSelf layoutIfNeeded];
        } completion:nil];
    }
    
    self.startX = self.linkedScrollView.CSM_width * index;
    if ([self.delegate respondsToSelector:@selector(slidingMenuBar:didSelectedItem:atIndex:)]) {
        [self.delegate slidingMenuBar:self didSelectedItem:self.items[index] atIndex:index];
    }
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
    
    CGFloat progress = fabs(_offsetX - self.startX) / self.linkedScrollView.CSM_width;    // 滑动进度
    
    if (_offsetX > self.startX) {   // 向右
        if (progress != 0) {
            sourceIndex = self.selectedIndex;
            targetIndex = sourceIndex + 1;
            if (progress >= 1) {
                _selectedIndex++;
                self.startX += self.linkedScrollView.CSM_width;
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
                self.startX -= self.linkedScrollView.CSM_width;
            }
        }
        if (targetIndex < 0) return;
        sourecCell = (CZSlidingMenuBarCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:sourceIndex inSection:0]];
        targetCell = (CZSlidingMenuBarCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0]];
    }
    if (_offsetX == self.startX) {
        return;
    }

    CGFloat scrollLineW = sourecCell.CSM_width + (targetCell.CSM_width - sourecCell.CSM_width) * progress;
    CGFloat scrollLineCenterX = sourecCell.CSM_centerX + ((targetCell.CSM_centerX - sourecCell.CSM_centerX) * progress);
    [self.scrollLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(scrollLineW);
        make.centerX.mas_equalTo(-self.frame.size.width * .5f + scrollLineCenterX);
    }];
    
    // 改变颜色
    // RGB值获取
    CGFloat selectedR = [self.selectedColor CSM_r];
    CGFloat selectedG = [self.selectedColor CSM_g];
    CGFloat selectedB = [self.selectedColor CSM_b];
    
    CGFloat defaultR = [self.barTintColor CSM_r];
    CGFloat defaultG = [self.barTintColor CSM_g];
    CGFloat defaultB = [self.barTintColor CSM_b];
    
    // start + (end - start) * progress
    UIColor *nextColor = kRGBColor(defaultR + (selectedR - defaultR)*progress, defaultG + (selectedG - defaultG)*progress, defaultB + (selectedB - defaultB)*progress);
    targetCell.contentButton.tintColor = nextColor;
    
    UIColor *currentColor = kRGBColor(selectedR + (defaultR - selectedR)*progress, selectedG + (defaultG - selectedG)*progress, selectedB + (defaultB - selectedB)*progress);
    sourecCell.contentButton.tintColor = currentColor;
    
    // 改变大小
    targetCell.contentButton.transform = CGAffineTransformMakeScale(1 + (self.transformScale - 1) * progress, 1 + (self.transformScale - 1) * progress);
    sourecCell.contentButton.transform = CGAffineTransformMakeScale(self.transformScale + (1 - self.transformScale) * progress, self.transformScale + (1 - self.transformScale) * progress);
}

- (void)reloadItemsNippleState
{
    NSArray <NSIndexPath *>*visiblecell_idx = [self.collectionView indexPathsForVisibleItems];
    for (NSIndexPath *idx in visiblecell_idx) {
        CZSlidingMenuBarCollectionCell *cell = (CZSlidingMenuBarCollectionCell *)[self.collectionView cellForItemAtIndexPath:idx];
        [cell layoutNipple];
    }
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
