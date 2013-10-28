//
//  ViewController.m
//  JTGestureBasedTableViewDemo
//
//  Created by James Tang on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DictionaryEditViewController.h"
#import "TransformableTableViewCell.h"
#import "JTTableViewGestureRecognizer.h"
#import "Word.h"
#import "WordManager.h"
#import "URBAlertView.h"
#import "DictionaryCell.h"
#import "WordDB.h"
#import "HHYoukuMenuView.h"

// Configure your viewController to conform to JTTableViewGestureEditingRowDelegate
// and/or JTTableViewGestureAddingRowDelegate depends on your needs
@interface DictionaryEditViewController () <JTTableViewGestureEditingRowDelegate>
{
    NSIndexPath*        selectedIndexPath;
    HHYoukuMenuView*    youkuMenuView;
    UILabel*            wordCountLabel;
}

@property (nonatomic)         UITableView *tableView;
@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;

@end

@implementation DictionaryEditViewController
@synthesize tableViewRecognizer;

#define COMMITING_CREATE_CELL_HEIGHT 44
#define NORMAL_CELL_FINISHING_HEIGHT 44

#pragma mark - View lifecycle

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:kTapYoukuMenu object:nil];
}
- (void)addNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(tapMenu:) name:kTapYoukuMenu object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup your tableView.delegate and tableView.datasource,
    // then enable gesture recognition in one line.
    [self addNotification];
    selectedIndexPath = [[NSIndexPath alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableViewRecognizer = [self.tableView enableGestureTableViewWithDelegate:self];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor  = [UIColor lightGrayColor];
    self.tableView.rowHeight       = NORMAL_CELL_FINISHING_HEIGHT;
    [self.view addSubview:self.tableView];
    
    // 「元の画面へ」を表示する
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -44, self.tableView.bounds.size.width, 44)];
    view.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    label.text = @"元の画面へ";
    label.textColor = [UIColor orangeColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(90, 12, 20, 20)];
    imageView.image = [UIImage imageNamed:@"reload.png"];
    [view addSubview:imageView];
    [self.tableView addSubview:view];
    
    // 辞書内の単語数を表示する
    wordCountLabel = [[UILabel alloc] init];
    [self reloadWordCountLabel]; // frameとlabel.textの設定をする
    wordCountLabel.font = [UIFont systemFontOfSize:15];
    wordCountLabel.textColor = [UIColor orangeColor];
    wordCountLabel.backgroundColor = [UIColor clearColor];
    wordCountLabel.textAlignment = NSTextAlignmentCenter;
    [self.tableView addSubview:wordCountLabel];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"hidemenu.png"];
    button.frame = CGRectMake(0, self.view.frame.size.height - 17, self.view.frame.size.width, 17);
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showMeun:) forControlEvents:UIControlEventTouchDown];
    button.tag = 111;
    [self.view addSubview:button];
    
    youkuMenuView = [[HHYoukuMenuView alloc] initWithFrame:[HHYoukuMenuView getFrame]];
    [self.view addSubview:youkuMenuView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotification *n = [NSNotification notificationWithName:kBarPositionMiddle object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)showMeun:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.hidden = YES;
    [youkuMenuView  showOrHideMenu];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![youkuMenuView  getisMenuHide]&&!scrollView.decelerating) // menuが完全に隠れている＆指が離れている＆スクロールが止まってる
    {
        [youkuMenuView  showOrHideMenu];
        [self performSelector:@selector(showMeunButton) withObject:nil afterDelay:1];
    }
    
    if (scrollView.contentOffset.y < -44*2 && !scrollView.tracking) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showMeunButton
{
    UIView *button = [self.view viewWithTag:111];
    button.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[WordManager sharedManager].items sortUsingComparator:^(id obj1, id obj2) {
        Word* item1 = (Word*)obj1;
        Word* item2 = (Word*)obj2;
        
        return (item2.usedCount - item1.usedCount); // 降順
    }];
}

-(void)tapMenu:(NSNotification *)notification {

    NSInteger tag = [[[notification userInfo] objectForKey:@"tag"] integerValue];

    switch (tag) {
        case 0:
        {
            // viewControllerを閉じる
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case 1:
        {
            // scrollをtopにする
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [self performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0.5];
        }
            break;
        case 2:
        {
            // 単語を追加する
            [self addWord];
        }
            break;
        case 3:
        {
            // scrollをbottomにする
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[[WordManager sharedManager].items count]-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [self performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0.5];
        }
            break;
    }
}

- (void)flashScrollIndicators
{
    [self.tableView flashScrollIndicators];
}

#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[WordManager sharedManager].items count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSObject *object = [[WordManager sharedManager].items objectAtIndex:indexPath.row];

    static NSString *cellIdentifier = @"MyCell";
    DictionaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DictionaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = backgroundView;
    }
    cell.inputLabel.textColor = [UIColor grayColor]; // セルを削除したあと色を戻すため
    
    Word *item = (Word *)object;
        
    cell.outputLabel.text   = [NSString stringWithFormat:@"　%@", item.outputString];
    cell.inputLabel.text    = [NSString stringWithFormat:@"  %@", item.inputString];
    cell.countLabel.text    = [NSString stringWithFormat:@"%d", item.usedCount];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.backgroundColor = kInputBackgroundColor;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NORMAL_CELL_FINISHING_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndexPath = indexPath;
    Word    *selectedWord = [[WordManager sharedManager].items objectAtIndex:indexPath.row];
    [self editWord:selectedWord]; // アラート表示 // 引数はとりあえずの仮。
}

#pragma mark JTTableViewGestureEditingRowDelegate

// スライドされると呼ばれる
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didEnterEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIColor *backgroundColor = nil;
    UIColor *textColor = nil;
    switch (state) {
        case JTTableViewCellEditingStateRight: // 削除確定ゾーン
            backgroundColor = [UIColor redColor];
            textColor = [UIColor lightTextColor];
            break;
        case JTTableViewCellEditingStateMiddle: // 削除未確定ゾーン
        case JTTableViewCellEditingStateLeft:
            backgroundColor = [UIColor yellowColor];
            textColor = [UIColor grayColor];
            break;
    }
    cell.contentView.backgroundColor = backgroundColor;
    
    if ([cell isKindOfClass:[DictionaryCell class]]) {
        ((DictionaryCell *)cell).inputLabel.textColor = textColor;
    } else {
        ((TransformableTableViewCell *)cell).detailTextLabel.textColor = textColor;
        ((TransformableTableViewCell *)cell).detailTextLabel.backgroundColor = [UIColor clearColor];
        //((TransformableTableViewCell *)cell).tintColor = backgroundColor;
    }
}

// 左にスライドできるか（削除）
- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer commitEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    [self.tableView beginUpdates];
    if (state == JTTableViewCellEditingStateRight) {
        
        Word *item = [[WordManager sharedManager].items objectAtIndex:indexPath.row];
        [[[WordDB alloc] init] deleteWordWithId:item.uid];
        
        [[WordManager sharedManager].items removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self performSelector:@selector(reloadWordCountLabel) withObject:nil afterDelay:0.5]; // ↑の削除アニメーションが終わってから実行
        
    } else if (state == JTTableViewCellEditingStateLeft) {
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.contentView.backgroundColor = kInputBackgroundColor;
    }
//    [self.tableView endUpdates];
}

#pragma mark - 単語登録画面 - --------------------------------------------------------------------------

- (void)addWord
{
    // OKなら文字の書き換え、キャンセルなら削除。空は削除。
    URBAlertView *alertView = [URBAlertView sharedInstance];
    [alertView wordorCustom:kAlertWord addorEdit:kAlertAdd];
    [alertView showWithAnimation:URBAlertAnimationFade];
    
    alertView.textField1.text = @"";
    alertView.textField2.text = @"";
    alertView.textField3.text = @"";
    [alertView.textField1 becomeFirstResponder];
    
    __weak typeof(self) weakSelf = self;
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        
        [alertView.textField1 resignFirstResponder];
        [alertView.textField2 resignFirstResponder];
        [alertView.textField3 resignFirstResponder];
		NSLog(@"button tapped: index=%i", buttonIndex);
        
        if (buttonIndex == kAlertCancel) { // キャンセルなら
            // 何もしない
        } else { // OKなら
            
            Word *item;
            item = [[Word alloc] init];
            item.outputString   = alertView.textField1.text;
            item.inputString    = alertView.textField2.text;
            item.yomiString     = alertView.textField3.text;
            item.usedCount      = 0;
            item.uid = [[WordDB new] getNewUidAndAddWord:item];
            [[WordManager sharedManager].items addObject:item]; // 最後尾に付け加える
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[WordManager sharedManager].items count]-1 inSection:0];
            [weakSelf.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            
            [weakSelf reloadWordCountLabel];
            
            // 底から10段目くらいまでにいるなら、底まで移動
            if (weakSelf.tableView.contentOffset.y+weakSelf.tableView.frame.size.height > weakSelf.tableView.contentSize.height - 44*11) {
                [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
        
        [alertView hideWithCompletionBlock:^{
			// stub
		}];
	}];
}

- (void)editWord:(Word *)item
{
    URBAlertView *alertView = [URBAlertView sharedInstance];
    [alertView wordorCustom:kAlertWord addorEdit:kAlertEdit];
    [alertView showWithAnimation:URBAlertAnimationFade];
    
    alertView.textField1.text = item.outputString; // 選択されているitemから。
    alertView.textField2.text = item.inputString;
    alertView.textField3.text = item.yomiString;
    [alertView.textField1 becomeFirstResponder];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(selectedIndexPath) weakSelectedIndexPath = selectedIndexPath;
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        
        [alertView.textField1 resignFirstResponder];
        [alertView.textField2 resignFirstResponder];
        [alertView.textField3 resignFirstResponder];
		NSLog(@"button tapped: index=%i", buttonIndex);
        
        if (buttonIndex == kAlertCancel) { // キャンセルなら
            // 何もしない
        } else { // OKなら
            
            Word *item;
            item = [[WordManager sharedManager].items objectAtIndex:weakSelectedIndexPath.row];
            item.outputString = alertView.textField1.text;
            item.inputString  = alertView.textField2.text;
            item.yomiString   = alertView.textField3.text; // uidはそのまま
            [[WordDB new] mergeWithWord:item]; // データベースでの変更
            
            // 表示の更新
            DictionaryCell *cell = (DictionaryCell *)[weakSelf.tableView cellForRowAtIndexPath:weakSelectedIndexPath];
            cell.outputLabel.text   = [NSString stringWithFormat:@"　%@", item.outputString];
            cell.inputLabel.text    = [NSString stringWithFormat:@"  %@", item.inputString];
            cell.countLabel.text    = [NSString stringWithFormat:@"%d", item.usedCount];
        }
        
        [weakSelf.tableView deselectRowAtIndexPath:weakSelectedIndexPath animated:NO];
        
        [alertView hideWithCompletionBlock:^{
			// stub
		}];
	}];
}

#pragma mark - private method - 

- (void)reloadWordCountLabel
{
    CGFloat height = [[WordManager sharedManager].items count] * self.tableView.rowHeight;
    wordCountLabel.frame = CGRectMake(0, height+3, self.tableView.bounds.size.width, 20);
    wordCountLabel.text = [NSString stringWithFormat:@"単語数 : %d", [[WordManager sharedManager].items count]];
}


@end
