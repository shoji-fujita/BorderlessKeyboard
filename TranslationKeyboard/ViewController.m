//
//  ViewController.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/20.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "ACEAutocompleteBar.h"
#import "Word.h"
#import "WordManager.h"
#import "TranslationToolBar.h"
#import "UIViewController+MJPopupViewController.h"
#import "WebViewController.h"
#import "URBAlertView.h"
#import "WordDB.h"

@interface ViewController ()<ACEAutocompleteDataSource, ACEAutocompleteDelegate> {
    WebViewController*  webViewController;
    TranslationToolBar* bar;
    NSRange             range;
    NSMutableArray*     barItemArray;
    BOOL                keyboardOpen;
}
@property (nonatomic, strong) ACEAutocompleteInputView* autocompleteInputView;
@end

@implementation ViewController

@synthesize range=range;

#pragma mark - lifecycle

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:kWriteText              object:nil];
    [nc removeObserver:self name:kWebOpen               object:nil];
    [nc removeObserver:self name:kPasteBoardChange      object:nil];
    [nc removeObserver:self name:kWordAddOpen           object:nil];
    [nc removeObserver:self name:kClearBigTextViewText  object:nil];
    [nc removeObserver:self name:kDidBecomeActive       object:nil];
}

- (void)addNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(writeText:) name:kWriteText object:nil];
    [nc addObserver:self selector:@selector(openWeb) name:kWebOpen object:nil];
    [nc addObserver:self selector:@selector(openWordAddFromWeb:) name:kPasteBoardChange object:nil];
    [nc addObserver:self selector:@selector(openWordAddFromBoard) name:kWordAddOpen object:nil];
    [nc addObserver:self selector:@selector(clearBigTextViewText) name:kClearBigTextViewText object:nil];
    [nc addObserver:self selector:@selector(didBecomeActive)      name:kDidBecomeActive      object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.bigTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-toolBarHeight)];
    self.bigTextView.font = [UIFont systemFontOfSize:14];
    self.bigTextView.delegate = self;
    [self.view addSubview:self.bigTextView];
    
    keyboardOpen = YES;
    [self addNotification];
    
    // itemsの読み込みも兼ねる
    [[WordManager sharedManager].items sortUsingComparator:^(id obj1, id obj2) {
        Word* item1 = (Word*)obj1;
        Word* item2 = (Word*)obj2;
        
        return (item2.usedCount - item1.usedCount); // 降順
    }];
    
    barItemArray = [[NSMutableArray alloc] init];
    
    bar = [[TranslationToolBar alloc] initWithFrame:CGRectZero viewController:self];
    [self.view addSubview:bar];

    self.autocompleteInputView = [bar.textView.internalTextView setAutocompleteWithDataSource:self
                                                                 delegate:self
                                                                customize:^(ACEAutocompleteInputView *inputView) {
                                                                    
                                                                    // customize the view (optional)
                                                                    inputView.font = [UIFont systemFontOfSize:20];
                                                                    inputView.textColor = kOutputTextColor;
                                                                    inputView.backgroundColor = [UIColor clearColor];
                                                                }];
    [bar.languageBar addSubview:self.autocompleteInputView];

    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchOut)];
    [self.bigTextView addGestureRecognizer:pinchGesture];
    
    [self addAAttribute];
}

- (void)pinchOut
{
    NSNotification *n = [NSNotification notificationWithName:kPinchout object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resignFirstResponder2
{
    [self.bigTextView resignFirstResponder];
}

- (void)writeTextView:(NSString *)text
{
    // カーソル位置に文字を付け足す
    NSLog(@"%d - %d", range.location, range.length);
    NSString *str1 = [self.bigTextView.text substringToIndex:range.location];
    NSString *str2 = [self.bigTextView.text substringFromIndex:(range.location + range.length)];
    self.bigTextView.text = [NSString stringWithFormat:@"%@%@%@%@", str1, [self checkText:text], @"_", str2];

    // 選択を入力した単語の後にする
    range = NSMakeRange([self.bigTextView.text length] - [str2 length] - 1, 1);
    [self addAAttribute];
    
    bar.textView.text = @"";
    [bar.textView becomeFirstResponder];
    
    if ([self.bigTextView.text length] != 0)
        bar.socialButton.enabled = YES;
}

// カスタムキーボードから送られた文字
- (void)writeText:(NSNotification *)notification
{
    NSString *text = [[notification userInfo] objectForKey:@"text"];
    [self writeTextView:text];
}

#pragma mark - 通知

- (void)clearBigTextViewText
{
    self.bigTextView.text = @"";
    range = NSMakeRange(0, 0);
    [bar.stockBar removeFromSuperview];
    bar.socialButton.enabled = NO;
    bar.textView.text = @"";
    [bar.textView becomeFirstResponder];
}

- (void)didBecomeActive
{
    if (keyboardOpen && !webViewController.webView)
        [bar.textView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    keyboardOpen = YES;
    
    if (_keyboardOpenFromDicEdit) {
        _keyboardOpenFromDicEdit = NO;
        [bar.textView becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    keyboardOpen = NO;
}

#pragma mark - BigTextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        bar.socialButton.enabled = NO;
        [bar.stockBar removeFromSuperview];
    } else {
        bar.socialButton.enabled = YES;
    }
}

#pragma mark - Autocomplete Delegate

// 第二の言語バーから送られた文字
- (void)textView:(UITextView *)textView didSelectObject:(id)object inInputView:(ACEAutocompleteInputView *)inputView
{
    [self writeTextView:object];
    
    for (Word *item in barItemArray) {
        if ([item.outputString isEqualToString:object]) {
            item.usedCount++;
            [[WordDB new] mergeWithWord:item]; // データベースでの変更
        }
    }
}

- (NSString *)checkText:(NSString *)text
{
    if ([text hasPrefix:@"http://"]) { // urlに使われる「/」は無視する
        return text;
    }
    NSArray *array = [text componentsSeparatedByString:@"/"];
    NSString *writeText = [array objectAtIndex:0];
    
    if ([array count] > 1) { // 個数が2以上ならストックバー行き
        NSMutableArray *array2 = [array mutableCopy];
        [array2 removeObjectAtIndex:0];
        [bar createStockBar:array2]; // ストックバー作成
    }
    return writeText;
}

#pragma mark - Autocomplete Data Source

- (NSUInteger)minimumCharactersToTrigger:(ACEAutocompleteInputView *)inputView
{
    return 1;
}

- (void)inputView:(ACEAutocompleteInputView *)inputView itemsFor:(NSString *)query result:(void (^)(NSArray *items))resultBlock;
{
    if (resultBlock != nil) {
        // execute the filter on a background thread to demo the asynchronous capability
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            // execute the filter
            NSMutableArray *data = [NSMutableArray array];
            [barItemArray removeAllObjects];
            int insertIndex = 0; // 完全一致時の挿入場所
            
            for (Word* item in [WordManager sharedManager].items) {
                
                if ([item.inputString hasPrefix:query] || [item.yomiString hasPrefix:query]) {
                    
                    [barItemArray addObject:item]; // barにあるitemの配列を保持しておく。
                    
                    // outputStringがかぶっていたら、追加しない。
                    if (![data containsObject:item.outputString]) {
                        
                        if ([item.inputString isEqualToString:query])
                        {
                            // 完全一致を使用回数順に
                            [data insertObject:item.outputString atIndex:insertIndex];
                            insertIndex++;
                        }
                        else {
                            [data addObject:item.outputString];
                        }
                    }
                }
            }
            
            // return the filtered array in the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(data);
            });
        });
    }
}

#pragma mark - webへ -

- (void)openWeb
{
    // キーボードを消しつつ、辞書ボードを出しておく
    NSNotification *n = [NSNotification notificationWithName:kDictionaryBoardOpen object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];

    webViewController = nil;
    webViewController = [[WebViewController alloc] init];
//    if (!webViewController) webViewController = [[WebViewController alloc] init]; // viewcontrollerをインスタンスで保持しておかないと解放される
    webViewController.searchWord = bar.textView.text;
    [self presentPopupViewController:webViewController animationType:MJPopupViewAnimationSlideRightRight];
}

#pragma mark - 単語登録画面 -

- (void)openWordAddFromBoard
{
    // アラートビューを呼び出す
    URBAlertView *alertView = [self loadAlertView];
    [alertView wordorCustom:kAlertWord addorEdit:kAlertAdd];
    [alertView showWithAnimation:URBAlertAnimationFade];
    
    alertView.textField1.text = @"";
    alertView.textField2.text = bar.textView.text;
    alertView.textField3.text = @"";
    [alertView.textField1 becomeFirstResponder];
}

- (void)openWordAddFromWeb:(NSNotification *)notification
{
    NSString *string = [[notification userInfo] objectForKey:@"text"];
    if (!string) { // ペーストボードの内容が変わっていない
        [bar.textView becomeFirstResponder];
        return;
    }
    
    // ペーストボードのテキストの行末に空白があれば取り除く
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if ([string hasSuffix:@"．"] && [string length] < 4) {
        string = [string substringToIndex:([string length] - 1)]; // 単語から句点を取り除く
    }

    // アラートビューを呼び出す
    URBAlertView *alertView = [self loadAlertView];
    [alertView wordorCustom:kAlertWord addorEdit:kAlertAdd];
    [alertView showWithAnimation:URBAlertAnimationFlipHorizontal];
    
    alertView.textField1.text = string;
    alertView.textField2.text = bar.textView.text;
    alertView.textField3.text = @"";
    [alertView.textField3 becomeFirstResponder];
}

- (URBAlertView *)loadAlertView
{
    URBAlertView *alertView = [URBAlertView sharedInstance];
    
	[alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        
        [bar.textView becomeFirstResponder];
		NSLog(@"button tapped: index=%i", buttonIndex);
        
        if (buttonIndex == kAlertCancel) { // キャンセルなら
            // 何もしない
        } else { // OKなら
            
            Word *item = [[Word alloc] init];
            item.outputString = alertView.textField1.text;
            item.inputString = alertView.textField2.text;
            item.yomiString = alertView.textField3.text;
            item.usedCount = 0;
            item.uid = [[WordDB new] getNewUidAndAddWord:item];
            [[WordManager sharedManager].items addObject:item];
            
            self.autocompleteInputView.textView.text = item.inputString;

            NSDictionary *dic = [NSDictionary dictionaryWithObject:alertView.textField2.text forKey:@"text"];
            NSNotification *n = [NSNotification notificationWithName:kSuggestionListReload object:self userInfo:dic];
            [[NSNotificationCenter defaultCenter] postNotification:n];
            bar.textView.placeholderLabel.alpha = 0;
        }
        
		[alertView hideWithCompletionBlock:^{
			// stub
		}];
	}];
    
    return alertView;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self removeAttribute];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    range = textView.selectedRange; // この位置に文字を挿入する
    
    if (range.length == 0) { // 選択文字が0なら

        // カーソル位置に文字を付け足す
        NSString *str1 = [self.bigTextView.text substringToIndex:range.location];
        NSString *str2 = [self.bigTextView.text substringFromIndex:(range.location + range.length)];
        self.bigTextView.text = [NSString stringWithFormat:@"%@%@%@", str1, @"_", str2];
        
        range = NSMakeRange(range.location, 1);
    }
    
    [self addAAttribute];
}

- (void)addAAttribute // bigTextViewのファーストレスポンダが外れたときと、
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.bigTextView.text];
    
    // フォント指定
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:14]
                    range:NSMakeRange(0, [attrStr length])];
    // 文字色
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor blackColor]
                    range:NSMakeRange(0, [attrStr length])]; // 全体を普通にする
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor blueColor]
                    range:range];                            // 選択範囲だけ色を変える
    
    if (![[self.bigTextView.text substringWithRange:range] isEqualToString:@"_"]) { // 選択範囲が _ でないなら
        
        [attrStr addAttribute:NSStrikethroughStyleAttributeName
                        value:[NSNumber numberWithInt:NSUnderlineStyleNone]
                        range:NSMakeRange(0, [attrStr length])];
        
        // 打ち消し線を引く
        [attrStr addAttribute:NSStrikethroughStyleAttributeName
                        value:[NSNumber numberWithInt:3]
                        range:range];
    }
    
    self.bigTextView.attributedText = attrStr;
}

- (void)removeAttribute // bigTextViewがファーストレスポンダになったとき
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.bigTextView.text];
    
    // フォントを戻す
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:14]
                    range:NSMakeRange(0, [attrStr length])];
     // 文字色を戻す
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor blackColor]
                    range:NSMakeRange(0, [attrStr length])];
    self.bigTextView.attributedText = attrStr;
    
    if ([[self.bigTextView.text substringWithRange:range] isEqualToString:@"_"]) {
        
        // ここで「_」を取り除く
        NSString *string = [self.bigTextView.text stringByReplacingCharactersInRange:range withString:@""];
        self.bigTextView.text = string;
    }
}


@end
