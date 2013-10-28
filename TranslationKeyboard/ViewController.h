//
//  ViewController.h
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/20.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong)   UITextView  *bigTextView;
@property (nonatomic, assign)   BOOL        keyboardOpenFromDicEdit;
@property (nonatomic, assign)   NSRange     range;

@end
