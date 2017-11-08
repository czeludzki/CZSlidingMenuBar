//
//  CZSlidingMenuBarCollectionCell.m
//  CZSlidingMenuBar
//
//  Created by siu on 6/11/17.
//

#import "CZSlidingMenuBarCollectionCell.h"
#import "Masonry.h"

@interface CZSlidingMenuBarCollectionCell ()

@end

@implementation CZSlidingMenuBarCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.userInteractionEnabled = NO;
        [self.contentView addSubview:btn];
        self.contentButton = btn;
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(2);
        }];
    }
    return self;
}

- (void)setItem:(CZSlidingMenuBarItem *)item
{
    _item = item;
    [self.contentButton setTitle:_item.title forState:UIControlStateNormal];
    [_item.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.contentButton setImage:_item.image forState:UIControlStateNormal];
}

@end
