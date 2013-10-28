//
//  DictionaryBoardView.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/23.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DictionaryBoardView.h"
#import "DictionaryEditViewController.h"
#import "ViewController.h"

#define kAddButtonWidth     80
#define kEditButtonHeight   44

@interface DictionaryBoardView () {
    UIViewController *_viewController;
}
@end

@implementation DictionaryBoardView

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController *)viewController
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _viewController = viewController;

        // +ボタン
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.frame = CGRectMake((self.frame.size.width - kAddButtonWidth)/2, (self.frame.size.height - kEditButtonHeight - kAddButtonWidth)/2, kAddButtonWidth, kAddButtonWidth);
        [addBtn setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
        [addBtn setBackgroundImage:[UIImage imageNamed:@"addH.png"] forState:UIControlStateHighlighted];
        [addBtn addTarget:self action:@selector(addWord:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addBtn];
        
        // 編集バー
        UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.frame = CGRectMake(0, self.frame.size.height - kEditButtonHeight, self.frame.size.width, kEditButtonHeight);
        [editBtn addTarget:self action:@selector(editDictionary:) forControlEvents:UIControlEventTouchUpInside];
        editBtn.backgroundColor = RGB(200, 200, 200);
        [[editBtn titleLabel] setFont:[UIFont systemFontOfSize:15]];
        [editBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [editBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [editBtn setTitle:@"辞書の管理画面へ" forState:UIControlStateNormal];
        [self addSubview:editBtn];
        
        editBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        editBtn.layer.borderWidth = 1;
    }
    return self;
}

- (void)addWord:(id)sender
{
    NSNotification *n = [NSNotification notificationWithName:kWordAddOpen object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)editDictionary:(id)sender
{
    DictionaryEditViewController *viewController = [[DictionaryEditViewController alloc] init];
    [_viewController presentViewController:viewController animated:YES completion:nil];
    ((ViewController*)_viewController).keyboardOpenFromDicEdit = YES;
}


@end
