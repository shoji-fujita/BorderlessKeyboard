//
//  WebViewController.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/30.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "WebViewController.h"
#import "KxMenu.h"
#import "UrlManager.h"
#import "UrlItem.h"

@interface WebViewController () {
    NSString *encodingSearchWord;
    NSString *watchPasteboard;
}
@end

@implementation WebViewController

#pragma mark - lifecycle -

- (void)loadView
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appFrame.size.width, appFrame.size.height-44*2)];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.frame = self.view.frame;
    self.webView.scalesPageToFit = YES;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.view addSubview:self.webView];
    
    UIImage *image = [UIImage imageNamed:@"link.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(self.view.frame.size.width - 40, 10, 30, 30);
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    btn.alpha = 0.5;
    btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [btn addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    encodingSearchWord = [self encoding:self.searchWord];
    // 検索時にまず開くurl
    UrlItem *firstWeb = [[UrlManager sharedManager].array objectAtIndex:0];
    NSString *firstUrl = firstWeb.url;
    NSString *urlString = [firstUrl stringByReplacingOccurrencesOfString:@"%@" withString:encodingSearchWord];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
    _webView.delegate = self;
}

- (void)showMenu:(UIButton *)sender
{
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    
    // 要素item
    NSInteger index = 0;
    for (UrlItem *urlItem in [UrlManager sharedManager].array) {
        
        KxMenuItem *menuItem = [KxMenuItem menuItem:urlItem.title
                                              image:[UIImage imageNamed:urlItem.imagePath]
                                             target:self
                                             action:@selector(pushMenuItem:)];
        menuItem.index = index;
        index++;
        
        [menuItems addObject:menuItem];
    }
    
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

- (void)pushMenuItem:(id)sender
{
    // urlを取得する
    KxMenuItem *item = (KxMenuItem *)sender;
    UrlItem *urlItem = [[UrlManager sharedManager].array objectAtIndex:item.index];
    
    // urlを表示する
    NSString *urlStr = urlItem.url;
    NSString *urlString = [urlStr stringByReplacingOccurrencesOfString:@"%@" withString:encodingSearchWord];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.webView stopLoading];
	self.webView.delegate = nil;
    self.webView = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// ペーストボードの監視
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    watchPasteboard = pasteboard.string;
    NSLog(@"watchPasteboard%@", watchPasteboard);
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"watchPasteboard%@", watchPasteboard);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    // ペーストボードに何か入ってる and 前回と違う
    NSDictionary *dic = nil;
    if (pasteboard.string && ![pasteboard.string isEqualToString:watchPasteboard]) {
        dic = [NSDictionary dictionaryWithObject:pasteboard.string forKey:@"text"];
    }
    NSNotification *n = [NSNotification notificationWithName:kPasteBoardChange object:self userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:n];
    
    self.searchWord = nil;
}

- (NSString *)encoding:(NSString *)string
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 ));
}

// ページ読込開始時にインジケータをくるくるさせる
-(void)webViewDidStartLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// ページ読込完了時にインジケータを非表示にする
-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end












