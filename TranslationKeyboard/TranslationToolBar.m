//
//  FaceToolBar.m
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//

#import "TranslationToolBar.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

// Board
#import "CustomBoardView.h"
#import "SocialBoardView.h"
#import "DictionaryBoardView.h"

@interface TranslationToolBar () {
    CGRect languageBarFrame;
    CGRect gotoWebButtonFrame;
    CGRect textViewFrame;
    CGRect socialButtonFrame;
    CGRect dictionaryButtonFrame;
    CGRect keyboardButtonFrame;
    CGRect socialBoardViewFrame;
    CGRect dictionaryBoardViewFrame;
    
    CGRect toolBarUpperFrame;
    CGRect toolBarMiddleFrame;
    CGRect toolBarLowerFrame;
    CGRect superBoardViewShowFrame;
    CGRect superBoardViewHiddenFrame;
    CGRect customBoardViewShowFrame;
    CGRect customBoardViewHiddenFrame;
    
    BOOL   isBarPositionUpper; // バーの位置が上か下か
}
@end

@implementation TranslationToolBar

@synthesize textView=textView;
@synthesize languageBar=languageBar;
@synthesize stockBar=stockBar;
@synthesize socialButton=socialButton;

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardDidShowNotification  object:nil];
    [nc removeObserver:self name:kPinchout                      object:nil];
    [nc removeObserver:self name:kDictionaryBoardOpen           object:nil];
    [nc removeObserver:self name:kBarPositionMiddle             object:nil];
}
- (void)addNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(inputKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(dismissKeyBoard)        name:kPinchout                      object:nil];
    [nc addObserver:self selector:@selector(dictionaryChange)       name:kDictionaryBoardOpen           object:nil];
    [nc addObserver:self selector:@selector(setBarPositionMiddle)   name:kBarPositionMiddle             object:nil];
}

- (void)layoutHoge
{
    CGRect appFrame          = [[UIScreen mainScreen] applicationFrame];
    CGSize toolBarSize       = CGSizeMake(appFrame.size.width, toolBarHeight);
    
    // 固定
    gotoWebButtonFrame       = CGRectMake(appFrame.size.width-45, 0, 45, languageBarHeight);
    
    CGFloat margin = 40;
    textViewFrame            = CGRectMake(margin, 3, toolBarSize.width-margin*2, 35);
    socialButtonFrame        = CGRectMake((margin-buttonWh)/2, 5, buttonWh, buttonWh);
    dictionaryButtonFrame    = CGRectMake(toolBarSize.width-(margin-buttonWh)/2-buttonWh, 5, buttonWh, buttonWh);
    keyboardButtonFrame      = CGRectMake(textViewFrame.size.width-buttonWh-8, (textViewFrame.size.height - buttonWh)/2+2, buttonWh, buttonWh);
    
    socialBoardViewFrame     = CGRectMake(0, 35, appFrame.size.width, keyboardHeight);
    dictionaryBoardViewFrame = CGRectMake(0, 35, appFrame.size.width, keyboardHeight);
    
    // 変動する
    toolBarUpperFrame            = CGRectMake(0, appFrame.size.height-keyboardHeight-35-toolBarHeight, toolBarSize.width, toolBarHeight);
    toolBarMiddleFrame           = CGRectMake(0, appFrame.size.height-keyboardHeight-toolBarHeight, toolBarSize.width, toolBarHeight);
    toolBarLowerFrame            = CGRectMake(0, appFrame.size.height-toolBarHeight,  toolBarSize.width, toolBarHeight);
    languageBarFrame             = CGRectMake(0, appFrame.size.height-keyboardHeight-35-toolBarHeight-languageBarHeight, appFrame.size.width, languageBarHeight);
    
    superBoardViewShowFrame      = CGRectMake(0, appFrame.size.height-keyboardHeight-35, appFrame.size.width, keyboardHeight+35);
    superBoardViewHiddenFrame    = CGRectMake(0, appFrame.size.height-35, appFrame.size.width, keyboardHeight+35);
    customBoardViewShowFrame     = CGRectMake(0, appFrame.size.height-keyboardHeight, appFrame.size.width, keyboardHeight);
    customBoardViewHiddenFrame   = CGRectMake(0, appFrame.size.height, appFrame.size.width, keyboardHeight);
}

- (void)createTranslationBar
{
    toolBar = [[UIToolbar alloc] initWithFrame:toolBarUpperFrame];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [toolBar setBarStyle:UIBarStyleBlack];
    
    textView = [[UIExpandingTextView alloc] initWithFrame:textViewFrame];
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 0.0f, 10.0f, 0.0f);
    [textView.internalTextView setReturnKeyType:UIReturnKeyDone];
    textView.delegate = self;
    textView.maximumNumberOfLines=5;
    textView.placeholder = @"中国語へ変換";
    [toolBar addSubview:textView];
    
    socialButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *socialImage = [UIImage imageNamed:@"social.png"];
    [socialButton setImage:socialImage forState:UIControlStateNormal];
    socialButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    [socialButton addTarget:self action:@selector(socialChange) forControlEvents:UIControlEventTouchUpInside];
    socialButton.frame = socialButtonFrame;
    [toolBar addSubview:socialButton];
    socialButton.enabled = NO;
    
    dictionaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *dictionaryImage = [UIImage imageNamed:@"dictionary.png"];
    [dictionaryButton setImage:dictionaryImage forState:UIControlStateNormal];
    dictionaryButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [dictionaryButton addTarget:self action:@selector(dictionaryChange) forControlEvents:UIControlEventTouchUpInside];
    dictionaryButton.frame = dictionaryButtonFrame;
    [toolBar addSubview:dictionaryButton];
    
    keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *customImage = [UIImage imageNamed:@"custom.png"];
    [keyboardButton setImage:customImage forState:UIControlStateNormal];
    keyboardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [keyboardButton addTarget:self action:@selector(keyBoardChange) forControlEvents:UIControlEventTouchUpInside];
    keyboardButton.frame = keyboardButtonFrame;
    [textView addSubview:keyboardButton];
}

- (void)createLanguageBar
{
    languageBar = [[UIView alloc] initWithFrame:languageBarFrame];
    languageBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    languageBar.backgroundColor = kOutputBackgroundColor;
    languageBar.hidden = YES;
    languageBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    languageBar.layer.borderWidth = 1;
    
    gotoWebButton = [UIButton buttonWithType:UIButtonTypeCustom];
    gotoWebButton.frame = gotoWebButtonFrame;
    UIImage *img = [UIImage imageNamed:@"right.png"];
    [gotoWebButton setBackgroundImage:img forState:UIControlStateNormal];
    [gotoWebButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [languageBar addSubview:gotoWebButton];
}

- (void)createStockBar:(NSArray *)array
{
    [stockBar removeAll];
    stockBar = [[StockBar alloc] initWithArray:array];
    stockBar.frame = languageBar.frame;
    [self.superview addSubview:stockBar];
}

- (void)createBoard
{
    customBoardView = [[CustomBoardView alloc] initWithFrame:customBoardViewShowFrame viewController:_viewController];
    customBoardView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    superBoardView = [[UIView alloc] initWithFrame:superBoardViewShowFrame];
    superBoardView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self gradient:superBoardView];
    
    socialBoardView = [[SocialBoardView alloc] initWithFrame:socialBoardViewFrame viewController:_viewController];
    socialBoardView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;

    dictionaryBoardView = [[DictionaryBoardView alloc] initWithFrame:dictionaryBoardViewFrame viewController:_viewController];
    dictionaryBoardView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
}

- (void)gradient:(UIView *)view
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)RGB(218, 223, 226).CGColor,
                       (id)RGB(185, 185, 185).CGColor, nil];
    [view.layer insertSublayer:gradient atIndex:0];
}

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController *)viewController
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _viewController = (ViewController *)viewController;
        [self addNotification];
        
        [self layoutHoge];
        keyboardIsShow=YES;
        customboardIsShow=YES;
        isBarPositionUpper=YES;
        
        [self createTranslationBar];
        [self createLanguageBar];
        [self createBoard];
        
        [_viewController.view addSubview:languageBar];
        [_viewController.view addSubview:superBoardView];
        [_viewController.view addSubview:customBoardView];
        [_viewController.view addSubview:toolBar];
    }
    return self;
}

#pragma mark -
#pragma mark UIExpandingTextView delegate

// textViewの高さが変わるとき
-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
    float diff = (textView.frame.size.height - height);
    CGRect r = toolBar.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    toolBar.frame = r;

    [self languageBarFrame];
}
// 文字が変わった
-(void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
    if (textView.text.length == 0) {
        
        languageBar.hidden = YES;
        if (stockBar) stockBar.hidden = NO;
    } else {
        
        languageBar.hidden = NO;
        if (stockBar) stockBar.hidden = YES;
    }
}
// Enterを押されたときの処理
-(BOOL)expandingTextView:(UIExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)expandingTextViewDidBeginEditing:(UIExpandingTextView *)expandingTextView
{
    if ([expandingTextView.text length] == 0) {
        languageBar.hidden = YES;
    } else {
        languageBar.hidden = NO;
    }
}
- (void)expandingTextViewDidEndEditing:(UIExpandingTextView *)expandingTextView
{
    languageBar.hidden = YES;
}

#pragma mark -
#pragma mark アクションメソッド３つ

- (void)boardChange
{
    for (UIView *view in superBoardView.subviews) {
        [view removeFromSuperview];
    }
    
    if (isBarPositionUpper) {
        
        [UIView animateWithDuration:Time animations:^{
            
            customBoardView.frame = customBoardViewHiddenFrame;
            toolBar.frame         = toolBarMiddleFrame;
            [self languageBarFrame];
        }];
    } else {

        [UIView animateWithDuration:Time animations:^{
            
            superBoardView.frame = superBoardViewShowFrame;
            toolBar.frame        = toolBarMiddleFrame;
            [self languageBarFrame];
        }];
        isBarPositionUpper = YES;
    }
    
    [self keyboardClose];
    customboardIsShow = NO;
}
- (void)socialChange
{
    [self boardChange];
    [superBoardView addSubview:socialBoardView];
    
    // ソーシャルの個別画面があれば消す
    for (UIView *view in socialBoardView.subviews) {
        if ([view isMemberOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
}
-(void)dictionaryChange
{
    [self boardChange];
    [superBoardView addSubview:dictionaryBoardView];
}

-(void)keyBoardChange
{
    if (isBarPositionUpper) {
        
        // キーボードなし、カスタムボードなしなら、カスタムボードをアニメーションで出し、バーをアニメーションで動かす
        // キーボードなし、カスタムボードありなら、カスタムボードをアニメーションで消しキーボードを出す
        // キーボードあり、カスタムボードなしなら、キーボードを消してからカスタムボードをアニメーションで出す
        // キーボードあり、カスタムボードありは、キーボードを消す
        
        if (!keyboardIsShow) {
            if (!customboardIsShow) {
                [UIView animateWithDuration:Time animations:^{
                    
                    customBoardView.frame = customBoardViewShowFrame;
                    toolBar.frame         = toolBarUpperFrame;
                    [self languageBarFrame];
                }];
                customboardIsShow = YES;
            } else {
                [UIView animateWithDuration:Time animations:^{
                    
                    customBoardView.frame = customBoardViewHiddenFrame;
                }];
                [textView becomeFirstResponder];
                customboardIsShow = NO;
                
                // 背後を消す
                for (UIView *view in superBoardView.subviews) {
                    [view removeFromSuperview];
                }
            }
        } else {
            if (!customboardIsShow) {
                
                [UIView animateWithDuration:Time animations:^{
                    
                    customBoardView.frame = customBoardViewShowFrame;
                }];
                customboardIsShow = YES;
                [self keyboardClose];
            } else {
                
                [self keyboardClose];
            }
            
            // 背後を消す
            for (UIView *view in superBoardView.subviews) {
                [view removeFromSuperview];
            }
        }
    } else {
        
        // superBoard、カスタムボード、バーをアニメーションで動かす（キーボードなし、カスタムボードなし）
        [UIView animateWithDuration:Time animations:^{
            
            superBoardView.frame    = superBoardViewShowFrame;
            customBoardView.frame   = customBoardViewShowFrame;
            toolBar.frame           = toolBarUpperFrame;
            [self languageBarFrame];
        }];
        isBarPositionUpper = YES;
    }
}

#pragma mark バーを一番下の位置に
-(void)dismissKeyBoard{
 
    // superBoard、customBoad、toolBarをアニメーションで下げ、キーボードは消しておく
    [UIView animateWithDuration:Time animations:^{
        
        superBoardView.frame    = superBoardViewHiddenFrame;
        customBoardView.frame   = customBoardViewHiddenFrame;
        toolBar.frame           = toolBarLowerFrame;
        [self languageBarFrame];
    }];
    
    NSLog(@"%f", toolBarLowerFrame.origin.y);

    [self keyboardClose];
    isBarPositionUpper = NO;
}

#pragma mark キーボードが現れるとき
-(void)inputKeyboardWillShow:(NSNotification *)notification{
    
    if (!isBarPositionUpper) {
        
        // superBoardViewをアニメーションで動かす
        [UIView animateWithDuration:Time animations:^{
            
            superBoardView.frame = superBoardViewShowFrame;
        }];
        isBarPositionUpper = YES;
    }
    
    [UIView animateWithDuration:Time animations:^{

        toolBar.frame = toolBarUpperFrame;
        [self languageBarFrame];
    }];
    keyboardIsShow=YES;
}

#pragma mark キーボードが消えるとき
-(void)inputKeyboardWillHide:(NSNotification *)notification{

    keyboardIsShow=NO;
}

// メインバーに連動した言語バーの位置
-(void)languageBarFrame {
    languageBar.frame = CGRectMake(toolBar.frame.origin.x, toolBar.frame.origin.y-languageBarHeight, toolBar.frame.size.width, languageBarHeight);
    if (stockBar)   stockBar.frame = languageBar.frame;
}

// webOpenの通知
-(void)search:(id)sender {
    NSNotification *n = [NSNotification notificationWithName:kWebOpen object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

// 両方のキーボードを閉じる
- (void)keyboardClose {
    [textView resignFirstResponder];
    [_viewController.bigTextView resignFirstResponder];
}

- (void)setBarPositionMiddle
{
    toolBar.frame = toolBarMiddleFrame;
    [self languageBarFrame];
}


@end
