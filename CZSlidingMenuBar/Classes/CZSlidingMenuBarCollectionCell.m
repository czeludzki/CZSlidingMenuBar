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
        
        UIView *nipple = [[UIView alloc] init];
        [self.contentView addSubview:nipple];
        self.nipple = nipple;
        [nipple mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(btn.titleLabel.mas_right).mas_offset(0);
            make.bottom.mas_equalTo(btn.titleLabel.mas_top).mas_offset(0);
            make.height.width.mas_equalTo(6);
        }];
        nipple.layer.cornerRadius = 3;
        nipple.layer.masksToBounds = YES;
        nipple.hidden = YES;
        nipple.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)setItem:(CZSlidingMenuBarItem *)item
{
    _item = item;
    UIImage *img = [_item.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.contentButton setTitle:_item.title forState:UIControlStateNormal];
    [self.contentButton setImage:img forState:UIControlStateNormal];
    self.contentButton.contentEdgeInsets = _item.contentEdgeInsets;
    self.contentButton.titleEdgeInsets = _item.titleEdgeInsets;
    self.contentButton.imageEdgeInsets = _item.imageEdgeInsets;
    self.nipple.hidden = !_item.showNipple;
}

@end
