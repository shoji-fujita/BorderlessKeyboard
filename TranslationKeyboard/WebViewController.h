//
//  WebViewController.h
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/30.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSString*     searchWord;
@property (nonatomic, strong) UIWebView*       webView;

@end
