//
//  CustomItem.h
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/09/05.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString*     text;
@property (nonatomic, assign) NSInteger     colorInteger;

@end
