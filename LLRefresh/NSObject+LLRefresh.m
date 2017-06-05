//
//  NSObject+LLRefresh.m
//  LLRefreshDemo
//
//  Created by kevin on 2017/2/9.
//  Copyright © 2017年 Ecommerce. All rights reserved.
//

#import <objc/runtime.h>
#import "MJRefresh.h"
#import "NSObject+LLRefresh.h"

typedef void(^requestBlock)(NSInteger page);

#define WeakObj(o) __weak typeof(o) o##Weak = o;

static const char scrollPageCountKey;
static const char scrollViewKey;
static const char scrollContentArrKey;
static const char refreshRequestBlockKey;
static const char firstPageNorKey;

@implementation NSObject (LLRefresh)

- (void)setScrollRefreshHandle:(requestBlock)actionHandler
{
    [self setRefreshRequestBlock:actionHandler];
    
    NSInteger firstPageNor = [self firstPageNor];
    
    [self setPageCount:firstPageNor];
    
    __weak UIScrollView *_bg_ScrollView = self.bg_ScrollView;
    
    WeakObj(self)
    _bg_ScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        [selfWeak setPageCount:firstPageNor];
        actionHandler(firstPageNor);
    }];
    
    _bg_ScrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        actionHandler([selfWeak increasePage]);
    }];
}

- (void)setScroll:(UIScrollView *)scrollView firstPageNor:(NSInteger)firstPageNor pageSize:(NSInteger)pageSize networkCallback:(NetworkCallback)networkCallback noMoreDataCallback:(NoMoreDataCallback)noMoreDataCallback
{
    WeakObj(self)
    
    if (!scrollView) {
        NSLog(@"plase set tableView or collectionView");
        return;
    }
    
    [self setFirstPageNor:firstPageNor];
    
    [self setBg_ScrollView:scrollView];
    
    [self setScrollRefreshHandle:^(NSInteger page) {
        networkCallback(page,^(BOOL isSuccess,NSArray *dataArr){
            if (isSuccess) {
                //请求成功
                if (page==firstPageNor) {
                    //Drop down
                    selfWeak.contentArr = [dataArr mutableCopy];
                    [selfWeak.bg_ScrollView reloadData];
                    [selfWeak.bg_ScrollView.mj_header endRefreshing];
                    [selfWeak contentArrDidRefresh:selfWeak.contentArr];
                    selfWeak.bg_ScrollView.mj_footer.hidden = NO;
                }
                else
                {
                    if (dataArr.count) {
                        //还有数据 （追加）
                        [selfWeak.contentArr addObjectsFromArray:dataArr];
                        [selfWeak.bg_ScrollView reloadData];
                        [selfWeak contentArrDidLoadMoreData:dataArr];
                    }
                    else
                    {
                        //No more data
                        [selfWeak decreasePage];
                    }
                    [selfWeak.bg_ScrollView.mj_footer endRefreshing];
                }
                if (dataArr.count < pageSize) {
                    //No more data
                    selfWeak.bg_ScrollView.mj_footer.hidden = YES;
                    if (noMoreDataCallback) {
                        noMoreDataCallback(page);
                    }
                    [selfWeak noMoreData:page];
                }
            } else {
                //请求失败
                [selfWeak decreasePage];
                [selfWeak.bg_ScrollView.mj_header endRefreshing];
                [selfWeak.bg_ScrollView.mj_footer endRefreshing];
            }
        });
    }];
}

//增加页码
- (NSUInteger)increasePage{
    NSUInteger page = [self getPageCount];
    [self setPageCount:++page];
    return page;
}

//降低页码
- (NSUInteger)decreasePage{
    NSUInteger page = [self getPageCount];
    if (page>[self firstPageNor]) {
        [self setPageCount:--page];
    }
    return page;
}

//静默刷新
- (void)silenceRefresh{
    [self refreshRequestBlock]([self firstPageNor]);
}

//已经重新加载了数据
- (void)contentArrDidRefresh:(NSArray *)newArr
{
    
}

//已经追加了数据
- (void)contentArrDidLoadMoreData:(NSArray *)appendArr
{
    
}

//没有更多数据了
- (void)noMoreData:(NSInteger)page
{
    
}

//触发下拉刷新
- (void)refreshScroll{
    [self.bg_ScrollView.mj_header beginRefreshing];
}

#pragma mark - GET && SET

- (NSUInteger)getPageCount{
    return [objc_getAssociatedObject(self, &scrollPageCountKey) unsignedIntegerValue];
}
- (void)setPageCount:(NSUInteger)pageCount{
    objc_setAssociatedObject(self, &scrollPageCountKey, @(pageCount), OBJC_ASSOCIATION_RETAIN);
}
- (NSMutableArray *)contentArr{
    return objc_getAssociatedObject(self, &scrollContentArrKey);
}
- (void)setContentArr:(NSMutableArray *)contentArr{
    objc_setAssociatedObject(self, &scrollContentArrKey, contentArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIScrollView *)bg_ScrollView{
    return objc_getAssociatedObject(self, &scrollViewKey);;
}
- (void)setBg_ScrollView:(UIScrollView *)bg_ScrollView{
    objc_setAssociatedObject(self, &scrollViewKey, bg_ScrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (requestBlock)refreshRequestBlock{
    return objc_getAssociatedObject(self, &refreshRequestBlockKey);
}
- (void)setRefreshRequestBlock:(requestBlock)requestBlock{
    objc_setAssociatedObject(self, &refreshRequestBlockKey, requestBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)firstPageNor{
    return [objc_getAssociatedObject(self, &firstPageNorKey) integerValue];
}
- (void)setFirstPageNor:(NSInteger)firstPageNor{
    objc_setAssociatedObject(self, &firstPageNorKey, @(firstPageNor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIScrollView (LLReloadExtension)

- (void)reloadData{
    if ([self isKindOfClass:[UITableView class]]) {
        [(UITableView *)self reloadData];
    } else if([self isKindOfClass:[UICollectionView class]]) {
        [(UICollectionView *)self reloadData];
    }  else{
        NSLog(@"plase invoke 'setScroll' to set the tableView or collectionView");
    }
}

@end
