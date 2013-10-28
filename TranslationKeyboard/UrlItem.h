//
//  SearchWebItem.h
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/30.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlItem : NSObject

@property(nonatomic, copy)      NSString*   title;
@property(nonatomic, copy)      NSString*   url;
@property(nonatomic, strong)    NSString*   imagePath;
@property(nonatomic, assign)    NSInteger   row;

@end
