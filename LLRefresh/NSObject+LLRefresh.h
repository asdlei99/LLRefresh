//
//  NSObject+LLRefresh.h
//  LLRefreshDemo
//
//  Created by kevin on 2017/2/9.
//  Copyright © 2017年 Ecommerce. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionCallback)(BOOL isSuccess,NSArray *dataArr);
typedef void(^NetworkCallback)(NSInteger page,CompletionCallback completionCallback);
typedef void(^NoMoreDataCallback)(NSInteger page);

@interface NSObject (LLRefresh)

/**
 设置网络下拉上拉时网络请求的地址和请求参数，页码参数名、以及指定如何解析返回数据
 1.scrollView        : 需要下拉刷新 下拉加载的tableView 或者 collectionView
 2.firstPageNor      : 起始页码
 3.networkCallback   : 网络请求回调
 */
- (void)setScroll:(UIScrollView *)scrollView firstPageNor:(NSInteger)firstPageNor pageSize:(NSInteger)pageSize networkCallback:(NetworkCallback)networkCallback noMoreDataCallback:(NoMoreDataCallback)noMoreDataCallback;

/**
 获取数据源
 如果在 setNetwrokAdd 时指定了modelClass 则 此方法返回的数组由指定的model类对象组成
 如果在 setNetwrokAdd 时modelClass参数传入nil 则 此方法返回的数组是由字典组成
 */
- (NSMutableArray *)contentArr;

/**
 获取表
 */
- (UIScrollView *)bg_ScrollView;

/**
 触发下拉刷新
 */
- (void)refreshScroll;

/**
 触发静默刷新,刷新第一页数据
 */
- (void)silenceRefresh;

/**
 没有更多数据了
 可以覆盖此方法，监测没有数据
 */
- (void)noMoreData:(NSInteger)page;

@end

@interface UIScrollView (LLReloadExtension)

- (void)reloadData;

@end
