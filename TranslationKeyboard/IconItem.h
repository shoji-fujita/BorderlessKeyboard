//
//  IconItem.h
//  test
//
//  Created by SHOJI FUJITA on 2013/08/05.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconItem : NSObject

@property (nonatomic, strong) NSString*   title;
@property (nonatomic, strong) NSString*   imagePath;
@property (nonatomic, retain) NSString*   identifier;
@property (nonatomic, assign) NSInteger   row;

@end
