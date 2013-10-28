//
//  IconManager.h
//  test
//
//  Created by SHOJI FUJITA on 2013/08/05.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IconItem;

@interface IconManager : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *iconItems;

+ (IconManager*)sharedManager;

@end
