//
//  FooterView.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/08/07.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "FooterView.h"

@implementation FooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _button.backgroundColor = [UIColor clearColor];
        [[_button titleLabel] setFont:[UIFont systemFontOfSize:15]];
        [_button setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_button setTitle:@"編集画面へ" forState:UIControlStateNormal];
        [self addSubview:_button];
    }
    return self;
}

@end
