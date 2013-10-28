//
//  HHYoukuMenuView.h
//  youku
//
//  Created by Eric on 12-3-12.
//  Copyright (c) 2012年 Tian Tian Tai Mei Net Tech (Bei Jing) Lt.d. All rights reserved.
//

#import <UIKit/UIKit.h>
#define  kButtonNum  11
@interface HHYoukuMenuView : UIView
{
    UIImageView *rotationView;
    UIImageView *bgView;
    CGRect rect[kButtonNum];
    NSMutableArray *arrayButtonIcon;
    BOOL rotationViewIsNomal;
    BOOL isMenuHide;
}
@property (nonatomic)  UIImageView *rotationView;
@property (nonatomic)  UIImageView *bgView;
@property (nonatomic)  NSMutableArray *arrayButtonIcon;
+ (CGRect)getFrame;
- (BOOL)getisMenuHide;
- (void)showOrHideMenu;
@end
