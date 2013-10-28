//
//  CollectionCell.m
//  CollectionViewSample
//
//  Created by Natsuko Nishikata on 2012/09/17.
//  Copyright (c) 2012年 Natsuko Nishikata. All rights reserved.
//

#import "CollectionCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];

//        self.label.adjustsFontSizeToFitWidth = YES;
//        self.label.minimumScaleFactor = 10.0/15.0;

        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(1, 0, frame.size.width-2, frame.size.height);
        self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIImage *normalImage = [UIImage imageNamed:@"key.png"];
        UIImage *stretchImage = [normalImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
        UIImage *pushImage = [UIImage imageNamed:@"keyH.png"];
        UIImage *stretchImage2 = [pushImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
        
        [self.button setBackgroundImage:stretchImage forState:UIControlStateNormal];
        [self.button setBackgroundImage:stretchImage2 forState:UIControlStateHighlighted];
        [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        
        [self.contentView addSubview:self.button];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = [UIColor grayColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
