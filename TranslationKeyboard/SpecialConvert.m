//
//  SpecialConvert.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/29.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "SpecialConvert.h"

@implementation SpecialConvert

#define EnconvertGen 0.0625935193

- (NSString *)moneyConvert:(NSString *)string
{
    // 通貨変換
    NSString *str;
    
    if ([string hasSuffix:@"円"])
    {
        NSString *subString = [string substringToIndex:([string length] - 1)];
        
        if ([self isNumber:subString]) // 前半が数字なら
        {
            NSInteger num = [subString integerValue];
            str = [NSString stringWithFormat:@"%d%@", (NSInteger)(num * EnconvertGen), @"元"];
        }
    }
    
    return str;
}

- (BOOL)isNumber:(NSString *)string
{
    int length = [string length];
    
    BOOL b = NO;
    for (int i = 0; i < length; i++) {
        
        NSString *str = [[string substringFromIndex:i] substringToIndex:1];
        const char *c = [str cStringUsingEncoding:NSASCIIStringEncoding];
        
        if ( c == NULL ) {
            b = NO;
            break;
        }
		
        if ((c[0] >= 0x30) && (c[0] <= 0x39)) // ASCIIコード表の「0〜9」
        {
            b = YES;
        } else {
            b = NO;
            break;
        }
    }
    
    return b;
}

@end
