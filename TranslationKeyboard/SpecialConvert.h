//
//  SpecialConvert.h
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/29.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpecialConvert : NSObject

// 変換先の国によって返す値を変えるようにする。
- (NSString *)moneyConvert:(NSString *)string;
- (BOOL)isNumber:(NSString *)string;

@end
