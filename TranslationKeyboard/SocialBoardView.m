//
//  SocialBoardView.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/08/20.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import "SocialBoardView.h"
#import "IconItem.h"
#import "IconManager.h"
#import "Weixin.h"
#import "ViewController.h"
#import "TKAlertCenter.h"
#import <Accounts/Accounts.h>
#import "LeoLoadingView.h"

#define kIconWidth          55
#define kIconHeight         90
#define kMarginWidth        20
#define kMarginHeight       15
#define kloadingViewWidth   30

#define kIdentifierWeixiSession     @"weixiSession"
#define kIdentifierWeixiTimeline    @"weixiTimeline"
#define kIdentifierSinaWeibo        @"sinaWeibo"
#define kIdentifierCut              @"cut"
#define kIdentifierSafari           @"safari"

@interface SocialBoardView () <UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIViewController*   _viewController;
    UIScrollView*       _scrollView;
    UIPageControl*      _pageControl;
    NSString*           _bigTextViewString;
    IconItem*           _nowItem;
    BOOL                _processing;
    UIView*             _overView;
    LeoLoadingView*     _loadingView;
}
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation SocialBoardView

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController *)viewController
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _viewController = viewController;
        
        NSArray *array = [[IconManager sharedManager] iconItems];
        
        // とりあえずページコントロール化しよう。
        
        NSInteger pageCount = [array count] / 8; // ページ数
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        
        // UIScrollViewのインスタンス化
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.frame = self.bounds;
        
        // 横スクロールのインジケータを非表示にする
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        // ページングを有効にする
        _scrollView.pagingEnabled = YES;
        
        _scrollView.userInteractionEnabled = YES;
        _scrollView.delegate = self;
        
        // スクロールの範囲を設定
        [_scrollView setContentSize:CGSizeMake((pageCount * width), height)];
        
        // スクロールビューを貼付ける
        [self addSubview:_scrollView];
        
        // スクロールビューにiconを貼付ける
        for (int i = 0; i < [array count]; i++) { // 4 * 2 * pageCount
            
            IconItem *iconItem = [array objectAtIndex:i];
            UIView *iconView = [self iconView:iconItem];
            
            NSInteger pageNow = i / 8;
            CGFloat originX = (kMarginWidth + (kIconWidth + kMarginWidth)*(i % 4)) + pageNow * width;
            CGFloat originY = kMarginHeight + kIconHeight * ((i / 4) % 2);
            
            iconView.frame = CGRectMake(originX, originY, kIconWidth, kIconHeight);
            [_scrollView addSubview:iconView];
        }
        
        // ページコントロールのインスタンス化
        CGFloat x = (width - 300) / 2;
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(x, self.frame.size.height - 50, 300, 50)];
        
        // 背景色を設定
        _pageControl.backgroundColor = [UIColor clearColor];
        
        // ページ数を設定
        _pageControl.numberOfPages = pageCount;
        
        // 現在のページを設定
        _pageControl.currentPage = 0;
        
        // ページコントロールをタップされたときに呼ばれるメソッドを設定
        _pageControl.userInteractionEnabled = YES;
        [_pageControl addTarget:self
                        action:@selector(pageControl_Tapped:)
              forControlEvents:UIControlEventValueChanged];
        
        // ページコントロールを貼付ける
        [self addSubview:_pageControl];
    }
    return self;
}

/**
 * スクロールビューがスワイプされたとき
 * @attention UIScrollViewのデリゲートメソッド
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    if ((NSInteger)fmod(scrollView.contentOffset.x , pageWidth) == 0) {
        // ページコントロールに現在のページを設定
        _pageControl.currentPage = scrollView.contentOffset.x / pageWidth;
    }
}

/**
 * ページコントロールがタップされたとき
 */
- (void)pageControl_Tapped:(id)sender
{
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * _pageControl.currentPage;
    [_scrollView scrollRectToVisible:frame animated:YES];
}

- (UIView *)iconView:(IconItem *)item
{
    UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIconWidth, kIconHeight)];
    
    UIImage *img = [UIImage imageNamed:item.imagePath];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kIconWidth, kIconWidth)];
    [btn setImage:img forState:UIControlStateNormal];
    btn.tag = item.row + 100;
    [btn addTarget:self action:@selector(btn_down:) forControlEvents:UIControlEventTouchUpInside];
    [iconView addSubview:btn];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, btn.frame.size.height, kIconWidth, kIconHeight - kIconWidth)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor darkGrayColor];
    lbl.font = [UIFont systemFontOfSize:10];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = item.title;
    [iconView addSubview:lbl];
    
    return iconView;
}

- (void)btn_down:(UIButton *)sender // アイコンをタップしたときの挙動
{
    _nowItem = [[[IconManager sharedManager] iconItems] objectAtIndex:(sender.tag - 100)];
    [Weixin initialize];
    
    ViewController *viewController = (ViewController *)_viewController;
    _bigTextViewString = viewController.bigTextView.text;
    
    if ([[_bigTextViewString substringWithRange:viewController.range] isEqualToString:@"_"]) {
        
        // 「_」があれば取り除く
        NSString *string = [_bigTextViewString stringByReplacingCharactersInRange:viewController.range withString:@""];
        _bigTextViewString = string;
    }
    
    if ([_nowItem.identifier isEqualToString:kIdentifierWeixiSession]) {
        NSLog(@"微信");
        if ([WXApi isWXAppInstalled]) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setValue:_bigTextViewString forPasteboardType:@"public.text"];
            [self clearText];
            [WXApi openWXApp];
        } else {
            [self alertOpenWithMessage:@"これは中国版LINEです。\n使用しますか？" buttonCount:2];
        }
    } else if ([_nowItem.identifier isEqualToString:kIdentifierWeixiTimeline]) {
        NSLog(@"微信タイムライン");
        if ([WXApi isWXAppInstalled]) {
            [self eachViewWithItem];
        } else {
            [self alertOpenWithMessage:@"これは中国版LINEです。\n使用しますか？" buttonCount:2];
        }
    } else if ([_nowItem.identifier isEqualToString:kIdentifierSinaWeibo]) {
        NSLog(@"微博");
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
            [self eachViewWithItem];
        } else {
            [self alertOpenWithMessage:@"これは中国版Twitterです。\n使用しますか？" buttonCount:2];
        }
    } else if ([_nowItem.identifier isEqualToString:kIdentifierCut]) {
        NSLog(@"切り取り");
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setValue:_bigTextViewString forPasteboardType:@"public.text"];
        [self clearText];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"切り取り成功"];
    } else if ([_nowItem.identifier isEqualToString:kIdentifierSafari]) {
        NSLog(@"Safari");
        NSString *urlString = [NSString stringWithFormat:@"https://www.google.com/?hl=zh-CN#fp=95ff786865a2d9b2&hl=zh-CN&q=%@&safe=off", [self encoding:_bigTextViewString]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        [self clearText];
    }
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

- (void)alertOpenWithMessage:(NSString *)message buttonCount:(NSInteger)count
{
    switch (count) {
        case 1:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
        }
            break;
        case 2:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            alert.delegate = self;
        }
            break;
    }
}

#pragma mark - alertViewDelegate

// 微信だけdelegate設定なので反応する
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: // キャンセル
            break;
        case 1: // OK
        {
            if ([_nowItem.identifier isEqualToString:kIdentifierWeixiSession] ||
                [_nowItem.identifier isEqualToString:kIdentifierWeixiTimeline]) {
                
                // AppStoreへ
                NSString *urlString = [WXApi getWXAppInstallUrl];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
            } else if ([_nowItem.identifier isEqualToString:kIdentifierSinaWeibo]) {
                
                [self alertOpenWithMessage:@"中国語キーボードを追加してから \"設定\" で微博アカウントの作成/登録をしてください" buttonCount:2];
            }
        }
            break;
    }
}

#pragma mark - private method -

- (void)sendWeiboText:(NSString *)text image:(UIImage *)image
{
    [self showLoadingView];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
    [accountStore
    requestAccessToAccountsWithType:accountType
    options:nil
    completion:^(BOOL granted, NSError *error) {
             
        if (!granted) { // アクセスを拒否されているとき
            [self performSelectorOnMainThread:@selector(noSettingAlert)
                                   withObject:nil
                                waitUntilDone:NO];
        } else {
            NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
            if (accountArray.count > 0) {
                
                SLRequest *request;
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                if (!image) {
                    NSURL *url = [NSURL URLWithString:@"https://api.weibo.com/2/statuses/update.json"];
                         
                    NSDictionary *params = @{@"status": text};
                    request = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo
                                                 requestMethod:SLRequestMethodPOST
                                                           URL:url
                                                    parameters:params];
                    [request setAccount:[accountArray objectAtIndex:0]];
                         
                } else {
                    NSURL *url = [NSURL URLWithString:@"https://upload.api.weibo.com/2/statuses/upload.json"];
                         
                    NSDictionary *params = @{@"status": text};
                    request = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo
                                                 requestMethod:SLRequestMethodPOST
                                                           URL:url
                                                    parameters:params];
                    [request setAccount:[accountArray objectAtIndex:0]];
                         
                    [request addMultipartData:UIImagePNGRepresentation(image)
                                     withName:@"pic"
                                         type:@"image/png" filename:nil];
                }
                     
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSLog(@"responseData=%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                    [self performSelectorOnMainThread:@selector(end:)
                                           withObject:error
                                        waitUntilDone:NO];
                }];
            }
        }
    }];
}

- (void)noSettingAlert
{
    [self alertOpenWithMessage:@" \"設定\" からこのアプリのアクセスを許可してください" buttonCount:1];
}

- (void)end:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hideLoadingView];
    
    if (!error) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"送信に成功しました"];
        [self clearText];
    } else {
        [self alertOpenWithMessage:@"送信に失敗しました" buttonCount:1];
    }
}

- (void)clearText
{
    NSNotification *n = [NSNotification notificationWithName:kClearBigTextViewText object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

#pragma mark - 別view - 

- (void)gradient:(UIView *)view
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)RGB(213, 218, 220).CGColor,
                       (id)RGB(185, 185, 185).CGColor, nil];
    [view.layer insertSublayer:gradient atIndex:0];
}

- (void)eachViewWithItem
{
    if (_processing) return;
    _processing = YES;
    
    UIView *eachView = [[UIView alloc] initWithFrame:self.bounds];
    [self gradient:eachView];
    
    // iconView
    CGFloat originX = (eachView.frame.size.width - kIconWidth) / 2;
    CGFloat originY = ((eachView.frame.size.height - 44) - kIconHeight) / 2;
    UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, kIconWidth, kIconHeight)];
    [eachView addSubview:iconView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kIconWidth, kIconWidth)];
    imageView.image = [UIImage imageNamed:_nowItem.imagePath];
    [iconView addSubview:imageView];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height, kIconWidth, kIconHeight - kIconWidth)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor darkGrayColor];
    lbl.font = [UIFont systemFontOfSize:10];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = _nowItem.title;
    [iconView addSubview:lbl];
    
    // ボタンの親View
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, eachView.bounds.size.height - 44, eachView.bounds.size.width, 44)];
    buttonView.backgroundColor = RGB(200, 200, 200);
    [eachView addSubview:buttonView];
    
    //「テキストのみ」
    UIButton *textButton = [UIButton buttonWithType:UIButtonTypeCustom];
    textButton.frame = CGRectMake(0, 0, buttonView.bounds.size.width / 2, buttonView.bounds.size.height);//左
    [textButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [textButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [[textButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
    [textButton setTitle:@"送信" forState:UIControlStateNormal];
    [textButton addTarget:self action:@selector(textSend) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:textButton];
    textButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textButton.layer.borderWidth = 1;
    
    //「写真つき」
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoButton.frame = CGRectMake(buttonView.bounds.size.width / 2, 0, buttonView.bounds.size.width / 2, buttonView.bounds.size.height);//右
    [[photoButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
    [photoButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [photoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [photoButton setTitle:@"送信 ＋ 写真" forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(photoSend) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:photoButton];
    photoButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    photoButton.layer.borderWidth = 1;
    
    [self addSubview:eachView];
    eachView.center = CGPointMake(eachView.center.x, eachView.center.y + eachView.frame.size.height);
    [UIView animateWithDuration:0.3
                     animations:^{
                         eachView.center = CGPointMake(eachView.center.x, eachView.center.y - eachView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         _processing = NO;
                     }];
    _overView = nil;
    _overView = [[UIView alloc] initWithFrame:self.bounds];
    _overView.backgroundColor = [UIColor blackColor];
    _overView.alpha = 0.6;
    [eachView addSubview:_overView];
    _overView.hidden = YES;
    
    _loadingView = nil;
    _loadingView = [[LeoLoadingView alloc] initWithFrame:CGRectMake((self.bounds.size.width-kloadingViewWidth)/2, (self.bounds.size.height-kloadingViewWidth)/2, kloadingViewWidth, kloadingViewWidth)];
    [eachView addSubview:_loadingView];
}

- (void)showLoadingView
{
    _overView.hidden = NO;
    [_loadingView showView:YES];
}

- (void)hideLoadingView
{
    _overView = nil;
    [_overView removeFromSuperview];
    [_loadingView showView:NO];
}

- (void)textSend
{
    if ([_nowItem.identifier isEqualToString:kIdentifierWeixiTimeline]) {
        [self clearText];
        [Weixin sendText:_bigTextViewString toWXScene:WXSceneTimeline];
    } else if ([_nowItem.identifier isEqualToString:kIdentifierSinaWeibo]) {
        [self sendWeiboText:_bigTextViewString image:nil];
    }
}

- (void)photoSend
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [_viewController presentViewController:ipc animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo{
    
    [_viewController dismissViewControllerAnimated:YES completion:^{
        
        if ([_nowItem.identifier isEqualToString:kIdentifierWeixiTimeline]) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setValue:_bigTextViewString forPasteboardType:@"public.text"];
            [self clearText];
            [Weixin sendImage:image toWXScene:WXSceneTimeline];
        } else if ([_nowItem.identifier isEqualToString:kIdentifierSinaWeibo]) {
            [self sendWeiboText:_bigTextViewString image:image];
        }
        
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [_viewController dismissViewControllerAnimated:YES completion:nil];
}


@end


