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
@end
