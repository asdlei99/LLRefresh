//
//  YKGoodsCollectionCell.m
//  LLRefreshDemo
//
//  Created by kevin on 2017/2/9.
//  Copyright © 2017年 Ecommerce. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "YKGoodsCollectionCell.h"

@implementation YKGoodsCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setGoodsDic:(NSDictionary *)goodsDic{
    if (_goodsDic != goodsDic) {
        _goodsDic = goodsDic;
        [_imgView setImageWithURL:[NSURL URLWithString:_goodsDic[@"GOODS_MAIN_IMG"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        _titleLbl.text = _goodsDic[@"GOODS_TITLE"];
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥ %.1f  ",[goodsDic[@"GOODS_DISCOUNT_PRICE"] floatValue]] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:50/255.0 alpha:1],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
        [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥ %.1f",[goodsDic[@"GOODS_PRICE"] floatValue]] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:204/255.0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:13],NSStrikethroughStyleAttributeName:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle)}]];
        _priceLbl.attributedText = attStr;
        _volumeLbl.text = [NSString stringWithFormat:@"%@人已买",goodsDic[@"GOODS_VOLUME"]];
    }
}

@end
