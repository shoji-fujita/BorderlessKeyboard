//
//  ViewController.m
//  JTGestureBasedTableViewDemo
//
//  Created by James Tang on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomEditViewController.h"
#import "TransformableTableViewCell.h"
#import "JTTableViewGestureRecognizer.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"
#import "CustomManager.h"
#import "URBAlertView.h"
#import "CustomItem.h"
#import "SVSegmentedControl.h"

// Configure your viewController to conform to JTTableViewGestureEditingRowDelegate
// and/or JTTableViewGestureAddingRowDelegate depends on your needs
@interface CustomEditViewController () <JTTableViewGestureEditingRowDelegate, JTTableViewGestureAddingRowDelegate, JTTableViewGestureMoveRowDelegate>
{
    NSIndexPath *selectedIndexPath;
    NSString    *textField1string;
}
@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@property (nonatomic, strong) id grabbedObject;
@end

@implementation CustomEditViewController
@synthesize tableViewRecognizer;
@synthesize grabbedObject;

#define ADDING_CELL @" 　  　"
#define COMMITING_CREATE_CELL_HEIGHT 44
#define NORMAL_CELL_FINISHING_HEIGHT 44

#define kPullContinue                @"単語を...";
#define kPullRelease                 @"単語を追加しますか？";
#define kReturnList                  @"元の画面へ";

#define kPinchoutContinue            @"単語を...";
#define kPinchoutRelease             @"単語を追加しますか？";
#define kAdd                         @"（新しい単語）";

#pragma mark - View lifecycle

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
    self.tableViewRecognizer = [self.tableView enableGestureTableViewWithDelegate:self];
    selectedIndexPath = [[NSIndexPath alloc] init];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor  = [UIColor lightGrayColor];
    self.tableView.rowHeight       = NORMAL_CELL_FINISHING_HEIGHT;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self performSelector:@selector(writeAllCustom) withObject:nil afterDelay:0.5]; // アニメーション後
}

- (void)writeAllCustom
{
    [[CustomManager sharedManager] writeAllCustom];
}

#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[CustomManager sharedManager].items count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSObject *object = [[CustomManager sharedManager].items objectAtIndex:indexPath.row];
    if ([object isEqual:ADDING_CELL]) {
        NSString *cellIdentifier = nil;
        TransformableTableViewCell *cell = nil;

        // セル最上部での追加
        if (indexPath.row == 0) {
            cellIdentifier = @"PullDownTableViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [TransformableTableViewCell transformableTableViewCellWithStyle:TransformableTableViewCellStylePullDown
                                                                       reuseIdentifier:cellIdentifier];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textColor = [UIColor orangeColor];
                cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            }
            
            cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
            if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2) {
                cell.imageView.image = [UIImage imageNamed:@"reload.png"];
                cell.tintColor = [UIColor blackColor];
                cell.textLabel.text = kReturnList;
            } else if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
                cell.imageView.image = nil;
                // Setup tint color
                cell.tintColor = kInputBackgroundColor;
                cell.textLabel.text = kPullRelease;
            } else {
                cell.imageView.image = nil;
                // Setup tint color
                cell.tintColor = kInputBackgroundColor;
                cell.textLabel.text = kPullContinue;
            }
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.text = @" ";
            return cell;

        } else { // ピンチアウトでの追加
            // Otherwise is the case we wanted to pick the pullDown style
            cellIdentifier = @"UnfoldingTableViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

            if (cell == nil) {
                cell = [TransformableTableViewCell transformableTableViewCellWithStyle:TransformableTableViewCellStyleUnfolding
                                                                       reuseIdentifier:cellIdentifier];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textColor = [UIColor orangeColor];
                cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            }
            cell.tintColor = kInputBackgroundColor;
            
            cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
            if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2) {
                cell.textLabel.text = kReturnList;
                cell.tintColor = [UIColor blackColor];
            } else if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
                cell.textLabel.text = kPinchoutRelease;
            } else {
                cell.textLabel.text = kPinchoutContinue;
            }
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.text = @" ";
            return cell;
        }
    
    } else { // 普通のセル

        static NSString *cellIdentifier = @"MyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            UIView *backgroundView = [[UIView alloc] init];
            backgroundView.backgroundColor = [UIColor lightGrayColor];
            cell.selectedBackgroundView = backgroundView;
        }
        
        CustomItem *item = (CustomItem *)object;
        cell.textLabel.text = [NSString stringWithFormat:@"%@", item.text];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [CustomManager getColorName:item.colorInteger]];
        cell.detailTextLabel.textColor = [CustomManager getColor:item.colorInteger];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.contentView.backgroundColor = kInputBackgroundColor;
        
        return cell;
    }

}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NORMAL_CELL_FINISHING_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndexPath = indexPath;
    [self editWord:[[CustomManager sharedManager].items objectAtIndex:indexPath.row]]; // アラート表示
}

#pragma mark -
#pragma mark JTTableViewGestureAddingRowDelegate

// 上で新しいセルをつくるとき、閉じるとき、ピンチアウトのとき
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath {
    [[CustomManager sharedManager].items insertObject:ADDING_CELL atIndex:indexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath {
    [[CustomManager sharedManager].items replaceObjectAtIndex:indexPath.row withObject:@"Added!"];
    TransformableTableViewCell *cell = (id)[gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2) { // 元の画面へ戻る
        [[CustomManager sharedManager].items removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [[CustomManager sharedManager] reloadCellSizeArray];
        NSNotification *n = [NSNotification notificationWithName:kCustomBoardReload object:self];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
    else { // 追加
        cell.finishedHeight = NORMAL_CELL_FINISHING_HEIGHT;
        cell.imageView.image = nil;
        cell.textLabel.text = kAdd;
        
        selectedIndexPath = indexPath;
        
        [self performSelector:@selector(addWord) withObject:nil afterDelay:0.0]; // 遅延実行
    }
}

// ピンチアウトや上スクロールで作ろうとしたけど、ピンチアウトしきれなくてセルが作れなかったとき
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsDiscardRowAtIndexPath:(NSIndexPath *)indexPath {
    [[CustomManager sharedManager].items removeObjectAtIndex:indexPath.row];
}

#pragma mark JTTableViewGestureEditingRowDelegate

// スライドされると呼ばれる
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didEnterEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    UIColor *backgroundColor = nil;
    switch (state) {
        case JTTableViewCellEditingStateRight: // 削除確定ゾーン
            backgroundColor = [UIColor redColor];
            break;
        case JTTableViewCellEditingStateMiddle: // 削除未確定ゾーン
        case JTTableViewCellEditingStateLeft:
            backgroundColor = [UIColor yellowColor];
            break;
    }
    cell.contentView.backgroundColor = backgroundColor;
    if ([cell isKindOfClass:[TransformableTableViewCell class]]) {
        ((TransformableTableViewCell *)cell).backgroundColor = [UIColor clearColor];
        ((TransformableTableViewCell *)cell).tintColor = backgroundColor;
    }
}

// 左にスライドできるか（削除）
- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer commitEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView beginUpdates]; // 高さ変更
    if (state == JTTableViewCellEditingStateRight) {

        [[CustomManager sharedManager].items removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
    } else if (state == JTTableViewCellEditingStateLeft) {
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.contentView.backgroundColor = kInputBackgroundColor;
    }
    [self.tableView endUpdates]; // 高さ変更おわり
}

#pragma mark JTTableViewGestureMoveRowDelegate
// 並び替えのとき上のメソッドから順番に呼ばれる

// 並び替えの許可
- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.grabbedObject = [[CustomManager sharedManager].items objectAtIndex:indexPath.row];
    
    CustomItem *dummyItem = [CustomItem new];
    dummyItem.text = @"";
    dummyItem.colorInteger = 1000;
    [[CustomManager sharedManager].items replaceObjectAtIndex:indexPath.row withObject:dummyItem];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id object = [[CustomManager sharedManager].items objectAtIndex:sourceIndexPath.row];
    [[CustomManager sharedManager].items removeObjectAtIndex:sourceIndexPath.row];
    [[CustomManager sharedManager].items insertObject:object atIndex:destinationIndexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {

    [[CustomManager sharedManager].items replaceObjectAtIndex:indexPath.row withObject:self.grabbedObject];
    self.grabbedObject = nil;
}

#pragma mark - 単語登録画面 - --------------------------------------------------------------------------

- (void)addWord
{
    // OKなら文字の書き換え、キャンセルなら削除。空は削除。
    URBAlertView *alertView = [URBAlertView sharedInstance];
    [alertView wordorCustom:kAlertCustom addorEdit:kAlertAdd];
    [alertView showWithAnimation:URBAlertAnimationFade];
    
    alertView.textField1.text = @"";
    [alertView.seg moveThumbToIndex:3 animate:NO];
    [alertView.textField1 becomeFirstResponder];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(selectedIndexPath) weakSelectedIndexPath = selectedIndexPath;
	[alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        
        [alertView.textField1 resignFirstResponder];
		NSLog(@"button tapped: index=%i", buttonIndex);
        
        if (buttonIndex == kAlertCancel) { // キャンセルなら
            
            // 削除
            //[weakSelf.tableView beginUpdates];
            [[CustomManager sharedManager].items removeObjectAtIndex:weakSelectedIndexPath.row];
            [weakSelf.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:weakSelectedIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            //[weakSelf.tableView endUpdates];
            
        } else { // OKなら
            
            // 変更する
            CustomItem * item = [CustomItem new];
            item.text = alertView.textField1.text;
            item.colorInteger = alertView.seg.selectedIndex;
            
            [[CustomManager sharedManager].items replaceObjectAtIndex:weakSelectedIndexPath.row withObject:item];
            UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:weakSelectedIndexPath];
            cell.textLabel.text = item.text;
            cell.detailTextLabel.text = [CustomManager getColorName:item.colorInteger];
            cell.detailTextLabel.textColor = [CustomManager getColor:item.colorInteger];
        }
        
        [weakSelf.tableView deselectRowAtIndexPath:weakSelectedIndexPath animated:NO];
        
		[alertView hideWithCompletionBlock:^{
			// stub
		}];
	}];
}

- (void)editWord:(CustomItem *)item
{
    // OKなら文字の書き換え、キャンセルなら何もしない。空は削除。
    URBAlertView *alertView = [URBAlertView sharedInstance];
    [alertView wordorCustom:kAlertCustom addorEdit:kAlertEdit];
    [alertView showWithAnimation:URBAlertAnimationFade];
    
    alertView.textField1.text = item.text;
    [alertView.seg moveThumbToIndex:item.colorInteger animate:NO];
    [alertView.textField1 becomeFirstResponder];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(selectedIndexPath) weakSelectedIndexPath = selectedIndexPath;
	[alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        
        [alertView.textField1 resignFirstResponder];
		NSLog(@"button tapped: index=%i", buttonIndex);
        
        if (buttonIndex == kAlertCancel) { // キャンセルなら
            // 何もしない
        } else { // OKなら
            
            // 変更する
            CustomItem *item = [CustomItem new];
            item.text = alertView.textField1.text;
            item.colorInteger = alertView.seg.selectedIndex;
            [[CustomManager sharedManager].items replaceObjectAtIndex:weakSelectedIndexPath.row withObject:item];
            UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:weakSelectedIndexPath];
            cell.textLabel.text = item.text;
            cell.detailTextLabel.text = [CustomManager getColorName:item.colorInteger];
            cell.detailTextLabel.textColor = [CustomManager getColor:item.colorInteger];
        }
        
        [weakSelf.tableView deselectRowAtIndexPath:weakSelectedIndexPath animated:NO];
        
		[alertView hideWithCompletionBlock:^{
			// stub
		}];
	}];
}

@end
