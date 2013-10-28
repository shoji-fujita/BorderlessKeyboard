//
//  ItemManager.h
//  CollectionViewSample
//
//  Created by SHOJI FUJITA on 2013/07/25.
//  Copyright (c) 2013年 Natsuko Nishikata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomManager : NSObject

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *cellSizeArray;

+ (CustomManager*)sharedManager;
+ (UIColor *)getColor:(NSInteger)colorInteger;
+ (NSString *)getColorName:(NSInteger)colorInteger;

- (void)reloadCellSizeArray;
- (BOOL)writeAllCustom;

@end
