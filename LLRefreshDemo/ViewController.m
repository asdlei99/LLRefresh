//
//  ViewController.m
//  LLRefreshDemo
//
//  Created by kevin on 2017/2/9.
//  Copyright © 2017年 Ecommerce. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+LLRefresh.h"
#import <LLNetworkEngine.h>
#import "YKGoodsCollectionCell.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCollectionView];
    [self setRefresh];
}

- (void)setCollectionView{
    _layout.itemSize = CGSizeMake(kScreenWidth/2-6, 300*kScreenWidth/375.0f);
    _layout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    [_collectionView registerNib:[UINib nibWithNibName:@"YKGoodsCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"YKGoodsCollectionCell"];
}

#pragma mark - 核心代码 一个方法设置下拉刷新,上拉加载.避免每次都自行计算页码
/**
 1.scrollView        : 需要下拉刷新 下拉加载的tableView 或者 collectionView
 2.firstPageNor      : 起始页码
 3.networkCallback   : 网络请求回调
 */
- (void)setRefresh{
    [self setScroll:_collectionView firstPageNor:1 pageSize:10 networkCallback:^(NSInteger page, CompletionCallback completionCallback) {
        [LLNetworkEngine postWithUrl:@"http://www.ykds365.com/nineAndTwentyBuy" paraDic:@{@"data":@{@"size":@"10",@"bjmoney":@"2",@"index":@(page)}} successBlock:^(BOOL isSuccess, NSString *message, id jsonObj) {
            completionCallback(isSuccess,jsonObj[@"data"][@"list"]);
        } failedBlock:^(NSError *error) {
            completionCallback(NO,@[]);
        }];
    }];
    [self refreshScroll]; //立即下拉刷新
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.contentArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YKGoodsCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YKGoodsCollectionCell" forIndexPath:indexPath];
    cell.goodsDic = self.contentArr[indexPath.row];
    return cell;
}

@end
