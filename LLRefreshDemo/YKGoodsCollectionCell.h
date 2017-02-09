//
//  YKGoodsCollectionCell.h
//  LLRefreshDemo
//
//  Created by kevin on 2017/2/9.
//  Copyright © 2017年 Ecommerce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YKGoodsCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *priceLbl;
@property (weak, nonatomic) IBOutlet UILabel *volumeLbl;

@property (nonatomic ,strong) NSDictionary *goodsDic;

@end
