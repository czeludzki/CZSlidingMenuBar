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

@interface CZSlidingMenuBarViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
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
    CZSlidingMenuBarItem *item1 = [[CZSlidingMenuBarItem alloc] init];
    item1.title = @"111";
    CZSlidingMenuBarItem *item2 = [[CZSlidingMenuBarItem alloc] init];
    item2.title = @"222";
    CZSlidingMenuBarItem *item3 = [[CZSlidingMenuBarItem alloc] init];
    item3.title = @"333";
    CZSlidingMenuBarItem *item4 = [[CZSlidingMenuBarItem alloc] init];
    item4.title = @"444";
    CZSlidingMenuBarItem *item5 = [[CZSlidingMenuBarItem alloc] init];
    item5.title = @"555";
    CZSlidingMenuBar *slidingMenuBar = [CZSlidingMenuBar slidingMenuBarWithItems:@[item1,item2,item3,item4,item5]];
    [self.view addSubview:slidingMenuBar];
    [slidingMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
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

@end
