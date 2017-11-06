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
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <UIColor *>*randomColors;
@end

@implementation CZSlidingMenuBarViewController

- (NSMutableArray<UIColor *> *)randomColors
{
    if (!_randomColors) {
        _randomColors = [NSMutableArray array];
        for (int i = 0; i < 20; i++) {
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
    [self.view addSubview:slidingMenuBar];
    [slidingMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
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
        make.left.right.bottom.mas_equalTo(0);
    }];
    self.collectionView = collectionView;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"TestCellID"];
    
    // 设置 collectionView 为 menuBar 的联动视图
    slidingMenuBar.linkedScrollView = self.collectionView;
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
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
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

#pragma mark - CZSlidingMenuBarDelegate
- (void)slidingMenuBar:(CZSlidingMenuBar *)listView btnOnClickWithItem:(CZSlidingMenuBarItem *)item index:(NSInteger)index
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

@end
