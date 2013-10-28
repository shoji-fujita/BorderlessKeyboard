//
//  searchWebManager.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/30.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "UrlManager.h"
#import "UrlItem.h"
#import "WordDB.h"

@implementation UrlManager

static UrlManager *_sharedInstance = nil;

+ (UrlManager *)sharedManager
{
    if (!_sharedInstance) {
        _sharedInstance = [[UrlManager alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {    
        self.array = [[WordDB new] getAllUrls];
    }
    return self;
}

@end
