//
//  IconManager.m
//  test
//
//  Created by SHOJI FUJITA on 2013/08/05.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "IconManager.h"
#import "IconItem.h"
#import "WordDB.h"

#define kWeixiSession   @"weixiSession"
#define kWeixiTimeline  @"weixiTimeline"
#define kSinaWeibo      @"sinaWeibo"
#define kCut            @"cut"

@implementation IconManager

#pragma mark - 初期化 -
static IconManager*  _sharedInstance = nil;

+ (IconManager*)sharedManager
{
    if (!_sharedInstance) {
        _sharedInstance = [[IconManager alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.iconItems = [[WordDB new] getAllIcons];
    
    return self;
}

@end



