//
//  CustomItem.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/09/05.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "CustomItem.h"

@implementation CustomItem

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _text           = [decoder decodeObjectForKey:@"text"];
    _colorInteger   = [decoder decodeIntegerForKey:@"color"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:_text forKey:@"text"];
    [encoder encodeInteger:_colorInteger forKey:@"color"];
}

@end
