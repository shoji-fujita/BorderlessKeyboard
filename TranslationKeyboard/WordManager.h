//
//  WordManager.h
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/20.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordManager : NSObject

@property (nonatomic, strong) NSMutableArray*   items;

// 初期化
+ (WordManager*)sharedManager;

@end
