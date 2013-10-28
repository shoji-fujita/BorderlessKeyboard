//
//  Word.h
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/20.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Word : NSObject

@property (nonatomic, copy)   NSString* uid;
@property (nonatomic, strong) NSString* inputString;
@property (nonatomic, strong) NSString* outputString;
@property (nonatomic, strong) NSString* yomiString;
@property (nonatomic, assign) NSInteger usedCount;

@end
