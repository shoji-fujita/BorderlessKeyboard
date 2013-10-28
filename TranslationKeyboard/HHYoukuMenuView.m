//
//  HHYoukuMenuView.m
//  youku
//
//  Created by Eric on 12-3-12.
//  Copyright (c) 2012年 Tian Tian Tai Mei Net Tech (Bei Jing) Lt.d. All rights reserved.
//

#import "HHYoukuMenuView.h"
#import <QuartzCore/QuartzCore.h>
#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)


@implementation HHYoukuMenuView
@synthesize rotationView,arrayButtonIcon,bgView;


+ (CGRect)getFrame
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    return CGRectMake((appFrame.size.width - 296.0)/2.0, appFrame.size.height - 148.0 + 14,296.0,148.0);
}

+ (CGRect)getHideFrame
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    return CGRectMake((appFrame.size.width - 296.0)/2.0, appFrame.size.height,296.0,148.0);
}

- (void)setButtonsFrame
{
//    rect[10] =  CGRectMake(251,93,25,25);
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"mvideo.png",@"nomal",
//                         @"mvideoh.png",@"high",nil];
//    [arrayButtonIcon addObject:dic];
//    
//    rect[9] =  CGRectMake(224,52,25,25);
//    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"mserial.png",@"nomal",
//                         @"mserialh.png",@"high",nil];
//    [arrayButtonIcon addObject:dic];
//    
//    rect[8] =  CGRectMake(186,22,25,25);
//    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"mmovie.png",@"nomal",
//           @"mmovieh.png",@"high",nil];
//    [arrayButtonIcon addObject:dic];
//    
//    rect[7] =  CGRectMake(136,10,25,25);
//    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"mrank.png",@"nomal",
//           @"mrankh.png",@"high",nil];
//    [arrayButtonIcon addObject:dic];
//    
//    rect[6] =  CGRectMake(85,22,25,25);
//    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"mcartoon.png",@"nomal",
//           @"mcartoonh.png",@"high",nil];
//    [arrayButtonIcon addObject:dic];
//    
//    rect[5] =  CGRectMake(43,52,25,25);
//    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"menter.png",@"nomal",
//           @"menterh.png",@"high",nil];
//    [arrayButtonIcon addObject:dic];
//    
//    rect[4] =  CGRectMake(18,93,25,25);
//    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"mmusic.png",@"nomal",
//           @"mmusich.png",@"high",nil];
//    [arrayButtonIcon addObject:dic];
//    
//    //////////////////////////////////////////////////////////////////////////////
//    
//    rect[3] =  CGRectMake(207,103,25,25);
//    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"mmyi.png",@"nomal",nil];
//    [arrayButtonIcon addObject:dic];
//    
//    rect[2] =  CGRectMake(136,54,25,25);
//    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"mmenu.png",@"nomal",nil];
//    [arrayButtonIcon addObject:dic];
//    
//    rect[1] =  CGRectMake(63,103,25,25);
//    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"msearch.png",@"nomal",nil];
//    [arrayButtonIcon addObject:dic];
//    
    ///////////////////////////////////////////////////////////////////////////////
    rect[0] =  CGRectMake(125,91,44,44);
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"mhome.png",@"nomal",
                         @"mhomel.png",@"high",nil];
    [arrayButtonIcon addObject:dic];
    
    rect[1] =  CGRectMake(58,91,44,44);
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"up.png",@"nomal",nil];
    [arrayButtonIcon addObject:dic];
    
    rect[2] =  CGRectMake(125,48,44,44);
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"plus.png",@"nomal",nil];
    [arrayButtonIcon addObject:dic];
    
    rect[3] =  CGRectMake(193,91,44,44);
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"down.png",@"nomal",nil];
    [arrayButtonIcon addObject:dic];
}

- (void)initView
{
    bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"menu1.png"]];
    bgView.frame = CGRectMake(53.0,49.0,191.0, 86.0);
    [self addSubview:bgView];
    
    rotationView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"menu2.png"]];
    rotationView.frame = CGRectMake(0.0, 0.0+ 148.0/2.0,296, 148);
    rotationView.userInteractionEnabled = YES;
    rotationView.layer.anchorPoint = CGPointMake(0.5,1.0);
    if (rotationViewIsNomal)
    {
        rotationView.layer.transform = CATransform3DIdentity;
    }
    else
    {
        rotationView.layer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(180),0.0, 0.0, 1.0);;
    }
    [self addSubview:rotationView];
    
//    for (int i = 0;i<7;i++)
//    {
//        NSDictionary *dic = [arrayButtonIcon objectAtIndex:i];
//        
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = rect[i];
//        if ([dic objectForKey:@"nomal"])
//        {
//            [button setImage:[UIImage imageNamed:[dic objectForKey:@"nomal"]] forState:UIControlStateNormal];
//        }
//        if ([dic objectForKey:@"high"])
//        {
//            [button setImage:[UIImage imageNamed:[dic objectForKey:@"high"]] forState:UIControlStateHighlighted];
//        }
//        [button addTarget:self action:@selector(meunButtonDown:) forControlEvents:UIControlEventTouchUpInside];
//        button.tag = i;
//        button.showsTouchWhenHighlighted = YES;
//        [rotationView  addSubview:button]; // ここだけ違う
//    }
    
    for (int i = 0;i < 4 ;i++ )
    {
        NSDictionary *dic = [arrayButtonIcon objectAtIndex:i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = rect[i];
        if ([dic objectForKey:@"nomal"])
        {
            [button setImage:[UIImage imageNamed:[dic objectForKey:@"nomal"]] forState:UIControlStateNormal];
        }
        if ([dic objectForKey:@"high"])
        {
            [button setImage:[UIImage imageNamed:[dic objectForKey:@"high"]] forState:UIControlStateHighlighted];
        }
        [button addTarget:self action:@selector(meunButtonDown:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        button.showsTouchWhenHighlighted = YES;
        [self  addSubview:button];
    }
}


- (void)meunButtonDown:(id)sender
{
    UIButton *button = (UIButton *)sender;

    NSDictionary *dic = [NSDictionary dictionaryWithObject:@(button.tag) forKey:@"tag"];
    NSNotification *n = [NSNotification notificationWithName:kTapYoukuMenu object:self userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:n];
    
//    if (button.tag == 8) // メニューリスト
//    {
//        //kIsAdShow;
//        [UIView animateWithDuration:0.5
//                              delay:0
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             button.userInteractionEnabled = NO;
//                             CGFloat angle = rotationViewIsNomal ? 180.0:0.0;
//                             rotationView.layer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(angle),0.0, 0.0, 1.0);
//                         }
//                         completion:^(BOOL finished){
//                             button.userInteractionEnabled = YES;
//                             rotationViewIsNomal = !rotationViewIsNomal;
//                         }];
//    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        rotationViewIsNomal = NO; // 外周の円を表示させないときはNO
        isMenuHide = NO; // tableViewを動かすと隠れるかどうか
        arrayButtonIcon = [[NSMutableArray alloc]init];
        [self setButtonsFrame];
        [self initView];
    }
    return self;
}

- (void)showOrHideMenu
{
    //kIsAdShow;
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         if (!isMenuHide)
                             self.frame = [HHYoukuMenuView getHideFrame];
                         else
                             self.frame = [HHYoukuMenuView getFrame];
                         
                         isMenuHide = !isMenuHide;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (BOOL)getisMenuHide
{
    return isMenuHide;
}


@end
