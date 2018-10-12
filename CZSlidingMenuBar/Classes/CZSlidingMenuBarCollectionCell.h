//
//  CZSlidingMenuBarCollectionCell.h
//  CZSlidingMenuBar
//
//  Created by siu on 6/11/17.
//

#import <UIKit/UIKit.h>
#import "CZSlidingMenuBarItem.h"

@class CZSlidingMenuBarCollectionCell;
@protocol CZSlidingMenuBarCollectionCell_nippleSource <NSObject>
- (UIView *)slidingMenuBarCell:(CZSlidingMenuBarCollectionCell *)menuBarCell nippleForItem:(CZSlidingMenuBarItem *)item;
- (CGSize)slidingMenuBarCell:(CZSlidingMenuBarCollectionCell *)menuBarCell nippleSizeForItem:(CZSlidingMenuBarItem *)item;
- (CGPoint)slidingMenuBarCell:(CZSlidingMenuBarCollectionCell *)menuBarCell nipplePositionForItem:(CZSlidingMenuBarItem *)item;
@end

@interface CZSlidingMenuBarCollectionCell : UICollectionViewCell
@property (nonatomic, strong) CZSlidingMenuBarItem *item;
@property (nonatomic, weak) UIButton *contentButton;
@property (nonatomic, weak) id <CZSlidingMenuBarCollectionCell_nippleSource> nippleSource;
/**
 在 bar 内部调用 collectionView reload 会导致 cells 闪烁, 所以提供此方法以主动更新 nipple 状态, 而 cell 不闪烁
 */
- (void)layoutNipple;
@end
