# LLRefresh
- One line of code sets the pull-up to refresh and load more based on MJRefresh

- 一行代码设置TableView或者CollectionView的下拉刷新、上拉加载
- 内部实现页码的增减,避免每次设置刷新加载时计算页码

# ScreenShots
<img src="https://github.com/kevll/LLRefresh/raw/master/screenshots/screenshots_1.jpg" style="zoom:20%;">

<img src="https://github.com/kevll/LLRefresh/raw/master/screenshots/screenshots_2.jpg" style="zoom:20%;">

<img src="https://github.com/kevll/LLRefresh/raw/master/screenshots/screenshots_3.jpg" style="zoom:20%;">

# How to use LLRefresh

- Installation with CocoaPods：pod 'LLRefresh'

- Manual import：
- Drag All files in the LLRefresh folder to project
- Import the main file：#import "LLRefresh.h"

#Code Examples
```objective-c
[self setScroll:_collectionView firstPageNor:1 networkCallback:^(NSInteger page, CompletionCallback completionCallback) {
   [LLNetworkEngine postWithUrl:@"http://api.tunjifen.com/nineAndTwentyBuy" 	  
    	paraDic:@{@"data":@{@"size":@"10",@"bjmoney":@"2",@"index":@(page)}} 
    	successBlock:^(BOOL isSuccess, NSString *message, id jsonObj) {
            completionCallback(isSuccess,jsonObj[@"data"][@"list"]);
        } failedBlock:^(NSError *error) {
            completionCallback(NO,@[]);
   }];
 }];
[self refreshScroll]; //立即下拉刷新
```
#Remind
- ARC

- iOS>=6.0
- iPhone \ iPad screen anyway

#Hope
- For more information, please see demo project or connect me with kevliule@gmail.com



- If you find any bugs or any other good ideas , please issues me , thanks very much!
