//
//  NSString+MD5Extension.m
//  StoreIntegral
//
//  Created by kevin on 2016/12/22.
//  Copyright © 2016年 Ecommerce. All rights reserved.
//

#import "NSString+MD5Extension.h"
#import<CommonCrypto/CommonDigest.h>

@implementation NSString (MD5Extension)

- (NSString *)md5{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
