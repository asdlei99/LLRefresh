//
//  LLNetworkEngine.m
//  LLNetworkEngineDemo
//
//  Created by kevin on 17/2/9.
//  Copyright © 2017年 Ecommerce. All rights reserved.
//

#define isEmptyStr(str) (!str||[str isKindOfClass:[NSNull class]]||[str isEqualToString:@""]) //判断是否空字符串
#define isEqualValue(String_Number,Integer) ([String_Number integerValue]==Integer) //判断参数1与参数2是否相等 适用于NSNumber,NSString类型与整型判断

#import <AFNetworking.h>
#import "LLNetworkEngine.h"

@implementation LLNetworkEngine

/**发送GET异步请求
 1.relativeAdd  : 请求的地址
 2.paraDic      : 参数字典
 3.successBlock : 请求成功时回调
 4.failedBlock  : 请求失败时回调
 */
+ (void)getWithUrl:(NSString *)urlStr paraDic:(NSDictionary *)paraDic successBlock:(requestSuccessBlock)successBlock failedBlock:(requestFailedBlock)failedBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //以json格式提交参数给后台
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //默认响应JSON
    
    [manager GET:urlStr parameters:paraDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (successBlock) {
            successBlock(isEqualValue(jsonObj[@"status"], 0),jsonObj[@"message"],jsonObj);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"failed!\nerror===>%@",error.localizedDescription);
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

/**发送POST异步请求
 1.relativeAdd  : 请求的地址
 2.paraDic      : 参数字典
 3.successBlock : 请求成功时回调
 4.failedBlock  : 请求失败时回调
 */
+ (void)postWithUrl:(NSString *)urlStr paraDic:(NSDictionary *)paraDic successBlock:(requestSuccessBlock)successBlock failedBlock:(requestFailedBlock)failedBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //以json格式提交参数给后台
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //默认响应JSON
    
    [manager POST:urlStr parameters:paraDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (successBlock) {
            successBlock(isEqualValue(jsonObj[@"status"], 0),jsonObj[@"message"],jsonObj);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        NSLog(@"failed!\nerror===>%@",error.localizedDescription);
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

/**上传单张图片
 1.urlStr      : 请求的地址
 2.dic         : 参数字典    eg. @{@"paraName1":@"paraValue1"}
 3.imgParaName : 图片参数名称 eg. @"pic1"
 4.data        : 图片的二进制数据(NSData)
 5.successBlock: 上传成功的回调
 6.failedBlock : 上传失败时的回调
 */
+(void)uploadSingleImageWithUrl:(NSString *)urlStr param:(NSDictionary *)dic imgParaName:(NSString *)imgParaName imgData:(NSData *)data successBlock:(requestSuccessBlock)successBlock failedBlock:(requestFailedBlock)failedBlock
{
    [LLNetworkEngine uploadFileWithUrl:urlStr param:dic serviceName:imgParaName fileName:@"0.jpg" mimeType:@"image/jpeg" fileData:data successBlock:successBlock failedBlock:failedBlock];
}

/**上传多张图片
 1.urlStr         : 请求的地址
 2.dic            : 参数字典       eg. @{@"paraName1":@"paraValue1"}
 3.imgParaNameArr : 图片参数名的数组 eg. @[@"pic1",@"pic2",@"pic3"]
 4.dataArr        : 图片二进制数据(NSData) 数组
 5.successBlock   : 上传成功回调
 6.failedBlock    : 上传失败回调
 */
+(void)uploadMultipleImageWithUrl:(NSString *)urlStr param:(NSDictionary *)dic imgParaNameArr:(NSArray *)imgParaNameArr imgDataArr:(NSArray *)dataArr successBlock:(requestSuccessBlock)successBlock failedBlock:(requestFailedBlock)failedBlock
{
    NSMutableArray *fileNameArr = [NSMutableArray array];
    for (int i = 0; i < imgParaNameArr.count; i++) {
        [fileNameArr addObject:@"0.png"];
    }
    [LLNetworkEngine uploadFileWithUrl:urlStr param:dic serviceNameArr:imgParaNameArr fileNameArr:fileNameArr mimeType:@"image/jpeg" fileDataArr:dataArr successBlock:successBlock failedBlock:failedBlock];
}

/**上传单个文件
 1.urlStr      : 请求的地址
 2.dict        : 参数字典
 3.name        : 对应后台网站上[upload.php中]处理文件的[字段"head"]
 4.fileName    : 要保存在服务器上的[文件名]
 5.mimeType    : 上传文件的[mimeType]
 6.data        : 上传文件的Data[二进制数据]
 7.successBlock: 上传成功的回调
 8.failedBlock : 上传失败时的回调
 */
+ (void)uploadFileWithUrl:(NSString *)urlStr param:(NSDictionary *)dict serviceName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)data successBlock:(requestSuccessBlock)successBlock failedBlock:(requestFailedBlock)failedBlock
{
    if (isEmptyStr(urlStr)) {
        failedBlock(nil);
        return ;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //以json格式提交参数给后台
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 20.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];  // 此处设置content-Type生效
    //修改返回格式为二进制
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/plain",@"image/.jpg",@"image/jpeg",nil];
    
    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFormData:[[LLNetworkEngine jsonStrWithJSONObject:dict] dataUsingEncoding:NSUTF8StringEncoding] name:@"json"];
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            successBlock(isEqualValue(jsonObj[@"status"], 0),jsonObj[@"message"],jsonObj);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedBlock) {
            failedBlock(error);
        }
    }];
    
}

/**上传多个文件
 1.urlStr      : 请求的地址
 2.dict        : 参数字典
 3.nameArr     : 对应后台网站上[upload.php中]处理文件的[字段"head"] 数组
 4.fileNameArr : 要保存在服务器上的[文件名] 数组
 5.mimeType    : 上传文件的[mimeType]
 6.dataArr     : 上传文件的Data[二进制数据] 数组
 7.successBlock: 上传成功的回调
 8.failedBlock : 上传失败时的回调
 */
+(void)uploadFileWithUrl:(NSString *)urlStr param:(NSDictionary *)dict serviceNameArr:(NSArray *)nameArr fileNameArr:(NSArray *)fileNameArr mimeType:(NSString *)mimeType fileDataArr:(NSArray *)dataArr successBlock:(requestSuccessBlock)successBlock failedBlock:(requestFailedBlock)failedBlock
{
    if (fileNameArr.count != dataArr.count || nameArr.count != fileNameArr.count) {
        NSLog(@"fileNameArr,dataArr,nameArr数组个数不匹配，请检查传入参数!");
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //以json格式提交参数给后台
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 20.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];  // 此处设置content-Type生效
    //修改返回格式为二进制
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/plain",@"image/.jpg",@"image/jpeg",nil];
    
    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFormData:[[LLNetworkEngine jsonStrWithJSONObject:dict] dataUsingEncoding:NSUTF8StringEncoding] name:@"json"];
        
        for (int i = 0 ; i < fileNameArr.count ; i++) {
            NSString *fileName = fileNameArr[i];
            NSData *data = dataArr[i];
            NSString *name = nameArr[i];
            [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
        }
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            successBlock(isEqualValue(jsonObj[@"status"], 0),jsonObj[@"message"],jsonObj);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

+ (NSString *)jsonStrWithJSONObject:(id)jsonObj
{
    if (!jsonObj || ![NSJSONSerialization isValidJSONObject:jsonObj]) {
        return @"";
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:&error];
    if (error || !jsonData) {
        return @"";
    }
    else
    {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
