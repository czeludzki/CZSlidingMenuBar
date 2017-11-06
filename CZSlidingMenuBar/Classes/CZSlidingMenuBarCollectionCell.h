//
//  CZSlidingMenuBarCollectionCell.h
//  CZSlidingMenuBar
//
//  Created by siu on 6/11/17.
//

#import <UIKit/UIKit.h>
#import "CZSlidingMenuBarItem.h"

@interface CZSlidingMenuBarCollectionCell : UICollectionViewCell
@property (nonatomic, strong) CZSlidingMenuBarItem *item;
@property (nonatomic, weak) UIButton *contentButton;
@end
