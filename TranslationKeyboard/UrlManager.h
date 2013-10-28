//
//  SearchWebManager.h
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/30.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlManager : NSObject

@property (nonatomic, strong) NSMutableArray *array;

+ (UrlManager *)sharedManager;

@end
