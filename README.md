# LLRefresh
One line of code sets the pull-up to refresh and load more based on MJRefresh

# ScreenShots
![image](https://github.com/kevll/LLRefresh/raw/master/screenshots/screenshots_1.jpg)
![image](https://github.com/kevll/LLRefresh/raw/master/screenshots/screenshots_2.jpg)
![image](https://github.com/kevll/LLRefresh/raw/master/screenshots/screenshots_3.jpg)

# How to use LLRefresh

Installation with CocoaPods：pod 'LLRefresh'
Manual import：
Drag All files in the LLRefresh folder to project
Import the main file：#import "LLRefresh.h"

#Examples
[self setScroll:_collectionView firstPageNor:1 networkCallback:^(NSInteger page, CompletionCallback completionCallback) {
    [LLNetworkEngine postWithUrl:@"http://api.tunjifen.com/nineAndTwentyBuy" paraDic:@{@"data":@{@"size":@"10",@"bjmoney":@"2",@"index":@(page)}} successBlock:^(BOOL isSuccess, NSString *message, id jsonObj) {
            completionCallback(isSuccess,jsonObj[@"data"][@"list"]);
                } failedBlock:^(NSError *error) {
                    completionCallback(NO,@[]);
     }];
}];
[self refreshScroll]; //立即下拉刷新

#For more information, please see demo project or connect me with kevliule@gmail.com

#If you find any bugs or any other good ideas , please issues me , thanks very much!
