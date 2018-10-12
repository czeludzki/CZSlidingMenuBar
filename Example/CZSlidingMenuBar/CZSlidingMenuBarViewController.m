//
//  CZSlidingMenuBarViewController.m
//  CZSlidingMenuBar
//
//  Created by czeludzki on 11/06/2017.
//  Copyright (c) 2017 czeludzki. All rights reserved.
//

#import "CZSlidingMenuBarViewController.h"
#import <Masonry/Masonry.h>
#import <CZSlidingMenuBar/CZSlidingMenuBar.h>

@interface CZSlidingMenuBarViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CZSlidingMenuBarDelegate>
@property (nonatomic, weak) CZSlidingMenuBar *slidingMenuBar;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <UIColor *>*randomColors;
@property (nonatomic, assign) BOOL showNipple;
@end

@implementation CZSlidingMenuBarViewController

- (NSMutableArray<UIColor *> *)randomColors
{
    if (!_randomColors) {
        _randomColors = [NSMutableArray array];
        for (int i = 0; i < 30; i++) {
            UIColor *c = [UIColor colorWithRed:(arc4random_uniform(256) / 255.0) green:(arc4random_uniform(256) / 255.0) blue:(arc4random_uniform(256) / 255.0) alpha:1];
            [_randomColors addObject:c];
        }
    }
    return _randomColors;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < self.randomColors.count; i++) {
        CZSlidingMenuBarItem *item = [[CZSlidingMenuBarItem alloc] init];
        item.title = [NSString stringWithFormat:@"%i%i%i",i,i,i];
        [items addObject:item];
    }
    CZSlidingMenuBar *slidingMenuBar = [CZSlidingMenuBar slidingMenuBarWithItems:items];
    slidingMenuBar.transformScale = 1;
    slidingMenuBar.delegate = self;
    slidingMenuBar.selectedColor = [UIColor colorWithRed:.0f green:.9f blue:.9f alpha:1];
    slidingMenuBar.barTintColor = [UIColor colorWithRed:.3f green:.1f blue:.2f alpha:1];
    slidingMenuBar.bottomLineColor = [UIColor redColor];
    slidingMenuBar.averageBarWidth = 0;     // 0 ~ 8
    slidingMenuBar.scrollLineWidth = 16.0f;
    slidingMenuBar.scrollLineBottomOffset = 5.0f;
    slidingMenuBar.scrollLineColor = [UIColor yellowColor];
    slidingMenuBar.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:slidingMenuBar];
    self.slidingMenuBar = slidingMenuBar;
    [slidingMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_topLayoutGuideBottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.pagingEnabled = YES;
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(slidingMenuBar.mas_bottom);
//        make.left.right.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.bottom.mas_equalTo(0);
    }];
    self.collectionView = collectionView;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"TestCellID"];
    
    // 设置 collectionView 为 menuBar 的联动视图
    slidingMenuBar.linkedScrollView = self.collectionView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.showNipple = YES;
        [slidingMenuBar reloadItemsNippleState];
    });
    
    
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.randomColors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TestCellID" forIndexPath:indexPath];
    cell.backgroundColor = self.randomColors[indexPath.item];
    UILabel *lab = [cell.contentView viewWithTag:826];
    if (!lab) {
        lab = [[UILabel alloc] initWithFrame:CGRectZero];
        lab.tag = 826;
        lab.font = [UIFont boldSystemFontOfSize:60];
        [cell.contentView addSubview:lab];
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
        }];
    }
    lab.text = [NSString stringWithFormat:@"%ld",indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.bounds.size;
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.showNipple = !self.showNipple;
    [self.slidingMenuBar reloadItemsNippleState];
}

#pragma mark - CZSlidingMenuBarDelegate
- (void)slidingMenuBar:(CZSlidingMenuBar *)menuBar didSelectedItem:(CZSlidingMenuBarItem *)item atIndex:(NSInteger)index
{
    if (self.collectionView.isTracking || self.collectionView.isDragging || self.collectionView.isDecelerating) return;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

- (UIView *)slidingMenuBar:(CZSlidingMenuBar *)menuBar nippleForItem:(CZSlidingMenuBarItem *)item index:(NSInteger)index
{
    if (self.showNipple && index % 2 == 0) {
        UIView *nipple = [[UIView alloc] init];
        nipple.backgroundColor = [UIColor redColor];
        nipple.layer.cornerRadius = 3;
        return nipple;
    }
    return nil;
}

- (CGSize)slidingMenuBar:(CZSlidingMenuBar *)menuBar nippleSizeForItem:(CZSlidingMenuBarItem *)item index:(NSInteger)index
{
    return CGSizeMake(6, 6);
}

- (CGPoint)slidingMenuBar:(CZSlidingMenuBar *)menuBar nipplePositionForItem:(CZSlidingMenuBarItem *)item index:(NSInteger)index
{
    return CGPointMake(-1, 1);
}

@end
