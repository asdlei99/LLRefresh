//
//  UIViewController+Refresh.m
//  KKXC_Franchisee
//
//  Created by LL on 16/10/26.
//  Copyright © 2016年 cqingw. All rights reserved.
//

typedef void(^requestBlock)(NSInteger page);

//定义起始页号
#define start_page 1

#import <objc/runtime.h>
#import <MJRefresh.h>
#import "UIViewController+Refresh.h"

static const char scrollPageCountKey;
static const char scrollViewKey;
static const char scrollContentArrKey;
static const char refreshRequestBlockKey;
static const char dataSourceChangeBlockKey;

@implementation UIViewController (Refresh)

- (void)setScrollRefreshHandle:(requestBlock)actionHandler
{
    [self setRefreshRequestBlock:actionHandler];
    
    [self setPageCount:start_page];
    
    __weak UIScrollView *_bg_ScrollView = self.bg_ScrollView;
    
    WeakObj(self)
    _bg_ScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        [selfWeak setPageCount:start_page];
        actionHandler(start_page);
    }];
    
    _bg_ScrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        actionHandler([selfWeak increasePage]);
    }];
}

- (void)setScroll:(UIScrollView *)scrollView networkAdd:(NSString *)add paraDic:(NSDictionary *)paraDic pageFiledName:(NSString *)pageFiledName parseDicKeyArr:(NSArray *)dicKeyArr parseModelName:(NSString *)modelName
{
    WeakObj(self)
    
    if (!scrollView) {
        NSLog(@"plase set tableView or collectionView");
        return;
    } else if(!add){
        NSLog(@"plase set network request address");
        return;
    }
    
    [self setBg_ScrollView:scrollView];
    
    [self setScrollRefreshHandle:^(NSInteger page) {
        NSMutableDictionary *paraMutDic = [paraDic mutableCopy];
        if (pageFiledName) {
            NSDictionary *dataDic = [paraDic objectForKey:@"data"];
            if (dataDic) {
                NSMutableDictionary *mutDataDic = [dataDic mutableCopy];
                [mutDataDic setObject:[NSString stringWithFormat:@"%ld",page] forKey:pageFiledName];
                [paraMutDic setObject:mutDataDic forKey:@"data"];
            } else {
                [paraMutDic setObject:[NSString stringWithFormat:@"%ld",page] forKey:pageFiledName];
            }
        }
        [KZNetworkEngine postWithUrl:add paraDic:paraMutDic successBlock:^(BOOL isSuccess,NSString *message,id jsonObj) {
            if (page==start_page) {
                //Drop down
                selfWeak.contentArr = [[selfWeak parseJsonDataWithJsonObj:jsonObj dicKeyArr:dicKeyArr parseModelName:modelName] mutableCopy];
                [selfWeak.bg_ScrollView reloadData];
                [selfWeak.bg_ScrollView.mj_header endRefreshing];
                [LLUtils dismiss];
                [selfWeak contentArrDidRefresh:selfWeak.contentArr];
                selfWeak.bg_ScrollView.mj_footer.hidden = NO;
                //修复weex使用时下拉刷新头部偏移不复位问题
                if ([selfWeak dataSourceChangeBlock]) {
                    [UIView animateWithDuration:0.4 animations:^{
                        selfWeak.bg_ScrollView.contentOffset = CGPointZero;
                    }];
                }
            }
            else
            {
                if (!isNull(jsonObj[@"data"])) {
                    NSArray *appendArr = [selfWeak parseJsonDataWithJsonObj:jsonObj dicKeyArr:dicKeyArr parseModelName:modelName];
                    if (appendArr.count) {
                        //还有数据 （追加）
                        [selfWeak.contentArr addObjectsFromArray:appendArr];
                        [selfWeak.bg_ScrollView reloadData];
                        [selfWeak contentArrDidLoadMoreData:appendArr];
                    }
                    else
                    {
                        //No more data
                        [selfWeak decreasePage];
                        [selfWeak noMoreData];
                    }
                }
                else
                {
                    [selfWeak decreasePage];
                }
                [selfWeak.bg_ScrollView.mj_footer endRefreshing];
            }
            if ([selfWeak dataSourceChangeBlock]) {
                [selfWeak dataSourceChangeBlock](selfWeak.contentArr);
            }
        } failedBlock:^(NSError *error) {
            [selfWeak.bg_ScrollView.mj_header endRefreshing];
            [selfWeak.bg_ScrollView.mj_footer endRefreshing];
            [LLUtils dismiss];
            [selfWeak decreasePage];
        }];
    }];
}

- (void)setScroll:(UIScrollView *)scrollView networkAdd:(NSString *)add paraDic:(NSDictionary *)paraDic pageFiledName:(NSString *)pageFiledName parseDicKeyArr:(NSArray *)dicKeyArr parseModelName:(NSString *)modelName dataSourceChangeBlock:(void(^)(NSArray *dataSource))dataSourceChangeBlock{
    [self setScroll:scrollView networkAdd:add paraDic:paraDic pageFiledName:pageFiledName parseDicKeyArr:dicKeyArr parseModelName:modelName];
    [self setDataSourceChangeBlock:dataSourceChangeBlock];
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
    if (page>start_page) {
        [self setPageCount:--page];
    }
    return page;
}

//静默刷新
- (void)silenceRefresh:(BOOL)isShowHUD{
    if (isShowHUD) {
        [LLUtils showOnlyProgressHud];
    }
    [self refreshRequestBlock](start_page);
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
- (void)noMoreData
{
    self.bg_ScrollView.mj_footer.hidden = YES;
    [self.view makeToast:@"无更多数据" duration:1.0f position:[CSToastManager defaultPosition]];
}

//触发下拉刷新
- (void)refreshScroll{
    [self.bg_ScrollView.mj_header beginRefreshing];
}

//解析json数据
- (NSArray *)parseJsonDataWithJsonObj:(id)jsonObj dicKeyArr:(NSArray *)dicKeyArr parseModelName:(NSString *)modelName
{
    id arr = nil;
    int i = 0;
    for (NSString *dicKey in dicKeyArr)
    {
        if (i==0)
        {
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                arr = jsonObj[dicKey];
            }
            else if([jsonObj isKindOfClass:[NSArray class]])
            {
                if (((NSArray *)jsonObj).count) {
                    arr = jsonObj[0];
                }
            }
        }
        else
        {
            if ([arr isKindOfClass:[NSDictionary class]]) {
                arr = arr[dicKey];
            }
            else if([arr isKindOfClass:[NSArray class]])
            {
                if (((NSArray *)arr).count) {
                    arr = arr[0];
                }
            }
        }
        i++;
    }
    
    if ([arr isKindOfClass:[NSArray class]]) {
        if (modelName) {
            return [NSClassFromString(modelName) mj_objectArrayWithKeyValuesArray:arr];
        } else {
            return arr;
        }
    }
    else if(!isNull(arr))
    {
        if (modelName) {
            return [NSClassFromString(modelName) mj_objectArrayWithKeyValuesArray:@[arr]];
        } else {
            return @[arr];
        }
    }
    else
    {
        return @[];
    }
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
- (void(^)(NSArray *dataSource))dataSourceChangeBlock{
    return objc_getAssociatedObject(self, &dataSourceChangeBlockKey);
}
- (void)setDataSourceChangeBlock:(void(^)(NSArray *dataSource))dataSourceChangeBlock{
    objc_setAssociatedObject(self, &dataSourceChangeBlockKey, dataSourceChangeBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIScrollView (ReloadExtension)

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
