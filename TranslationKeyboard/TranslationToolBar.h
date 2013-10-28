//
//  TranslationToolBar.h
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//
#define Time  0.25
#define keyboardHeight 216

#define toolBarHeight 45
#define languageBarHeight 35

#define buttonWh 35
#import <UIKit/UIKit.h>
#import "UIExpandingTextView.h"
#import "StockBar.h"

@class ViewController;

@class CustomBoardView;
@class SocialBoardView;
@class DictionaryBoardView;

@interface TranslationToolBar : UIToolbar <UIExpandingTextViewDelegate,UIScrollViewDelegate>
{
    UIView *languageBar;            // 言語バー
    UIButton *gotoWebButton;
    
    StockBar *stockBar;             // ストックバー
    
    UIToolbar *toolBar;             // メインバー
    UIExpandingTextView *textView;
    UIButton *socialButton;
    UIButton *dictionaryButton;
    UIButton *keyboardButton;
    
    BOOL keyboardIsShow;
    BOOL customboardIsShow;
    
    UIScrollView *scrollView;
    
    UIView *superBoardView;
    CustomBoardView     *customBoardView;
    SocialBoardView     *socialBoardView;
    DictionaryBoardView *dictionaryBoardView;
    
    ViewController *_viewController;
}

@property(nonatomic,strong)UIView *languageBar;
@property(nonatomic,strong)UIView *stockBar;
@property(nonatomic,strong)UIExpandingTextView *textView;
@property(nonatomic,strong)UIButton *socialButton;

-(void)dismissKeyBoard;
-(id)initWithFrame:(CGRect)frame viewController:(UIViewController *)viewController;
-(void)createStockBar:(NSArray *)array;

@end
