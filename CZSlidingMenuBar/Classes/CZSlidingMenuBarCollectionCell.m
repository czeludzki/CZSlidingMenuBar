//
//  CZSlidingMenuBarCollectionCell.m
//  CZSlidingMenuBar
//
//  Created by siu on 6/11/17.
//

#import "CZSlidingMenuBarCollectionCell.h"
#import "Masonry.h"

@interface CZSlidingMenuBarCollectionCell ()
@property (nonatomic, weak) UIView *nipple;
@end

@implementation CZSlidingMenuBarCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.userInteractionEnabled = NO;
        [btn setBackgroundColor:[UIColor colorWithRed:(arc4random_uniform(256) / 255.0) green:(arc4random_uniform(256) / 255.0) blue:(arc4random_uniform(256) / 255.0) alpha:1]];
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
    UIImage *img = [_item.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.contentButton setTitle:_item.title forState:UIControlStateNormal];
    [self.contentButton setImage:img forState:UIControlStateNormal];
    self.contentButton.contentEdgeInsets = _item.contentEdgeInsets;
    self.contentButton.titleEdgeInsets = _item.titleEdgeInsets;
    self.contentButton.imageEdgeInsets = _item.imageEdgeInsets;
    [self layoutNipple];
}

- (void)layoutNipple
{
    UIView *nipple = nil;
    if ([self.nippleSource respondsToSelector:@selector(slidingMenuBarCell:nippleForItem:)]) {
        nipple = [self.nippleSource slidingMenuBarCell:self nippleForItem:self.item];
    }
    
    if (!nipple){        // 返回空, 则表示不需要显示 nipple, return
        [self.nipple removeFromSuperview];
        self.nipple = nil;
        return;
    }else{              // 有值, 就尝试将 self.nipple removeFromSuperView, 并添加新的 nipple 到视图
        [self.nipple removeFromSuperview];
        [self.contentView addSubview:nipple];
        self.nipple = nipple;
    }
    
    CGSize size = CGSizeZero;
    if ([self.nippleSource respondsToSelector:@selector(slidingMenuBarCell:nippleSizeForItem:)]) {
        size = [self.nippleSource slidingMenuBarCell:self nippleSizeForItem:self.item];
    }
    
    CGPoint position = CGPointZero;
    if ([self.nippleSource respondsToSelector:@selector(slidingMenuBarCell:nipplePositionForItem:)]) {
        position = [self.nippleSource slidingMenuBarCell:self nipplePositionForItem:self.item];
    }
    
    [self.nipple mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(position.x);
        make.top.mas_equalTo(position.y);
        make.size.mas_equalTo(size);
    }];
}

@end
