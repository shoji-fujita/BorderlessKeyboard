//
//  StockBar.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/08/03.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "StockBar.h"
#import <QuartzCore/QuartzCore.h>

#define kDefaultHeight      35.0f
#define kDefaultMargin      7.0f
#define kClearButtonWidth   45.0f

#define kTagRotatedView     101
#define kTagLabelView       102

@implementation StockBar

#pragma mark -

- (id)initWithArray:(NSArray *)array
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320, kDefaultHeight)];
    if (self) {
        
        _suggestionList = [[NSMutableArray alloc] initWithArray:array];
        
        self.backgroundColor = kOutputBackgroundColor;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1;
        
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _clearButton.frame = CGRectMake(0, 0, kClearButtonWidth, kDefaultHeight);
        UIImage *img = [UIImage imageNamed:@"clear.png"];
        [_clearButton setBackgroundImage:img forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_clearButton];
        
        // create the table view with the suggestions
        _suggestionListView	= [[UITableView alloc] initWithFrame:CGRectMake(kClearButtonWidth + (self.bounds.size.width - self.bounds.size.height) / 2,
                                                                            (self.bounds.size.height - self.bounds.size.width) / 2,
                                                                            self.bounds.size.height, self.bounds.size.width)];
        
        _suggestionListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _suggestionListView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        
        _suggestionListView.showsVerticalScrollIndicator = NO;
        _suggestionListView.showsHorizontalScrollIndicator = NO;
        _suggestionListView.backgroundColor = [UIColor clearColor];
        _suggestionListView.separatorColor = [UIColor lightGrayColor];
        _suggestionListView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _suggestionListView.layer.borderWidth = 1;
        _suggestionListView.bounces = NO;
        _suggestionListView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        _suggestionListView.dataSource = self;
        _suggestionListView.delegate = self;
        
        // clean the rest of separators
        _suggestionListView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f)];
        
        // add the table as subview
        [self addSubview:_suggestionListView];

    }
    return self;
}

- (void)clear
{
    // 先頭の配列を消してリロード
    [self.suggestionList removeObjectAtIndex:0];
    [self.suggestionListView reloadData];
}

- (void)removeAll
{
    // removeするとき
    _clearButton = nil;
    _suggestionListView = nil;
    [self removeFromSuperview];
}

- (void)show:(BOOL)show withAnimation:(BOOL)animated
{
    if (show && self.hidden) {
        // this is to remove the frst animation when the virtual keyboard will appear
        // use the hidden property to hide the bar wihout animations
        self.hidden = NO;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self show:show withAnimation:NO];
							 self.hidden = !show;
                         } completion:nil];
        
    } else {
        self.alpha = (show) ? 1.0f : 0.0f;
		self.hidden = !show;
    }
}

#pragma mark - Properties

- (UIFont *)font
{
    if (_font == nil) {
        _font = [UIFont systemFontOfSize:20];
    }
    return _font;
}

- (UIColor *)textColor
{
    if (_textColor == nil) {
        _textColor = [UIColor darkTextColor];
    }
    return _textColor;
}

#pragma mark - Table View Delegate

// この高さは、単語ごとの横幅
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * string = [self.suggestionList objectAtIndex:indexPath.row];
    CGFloat width = [string sizeWithFont:self.font constrainedToSize:self.frame.size].width;
    if (width == 0) {
        // bigger than the screen
        return self.frame.size.width;
    }
    
    // add some margins
    return width + (kDefaultMargin * 2) + 1.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * string = [self.suggestionList objectAtIndex:indexPath.row];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:string forKey:@"text"];
    NSNotification *n = [NSNotification notificationWithName:kWriteText
                                                      object:self
                                                    userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:n];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // タッチされたところまで配列を消す
    [self.suggestionList removeObjectsInRange:NSMakeRange(0, indexPath.row + 1)];
    [self.suggestionListView reloadData];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger suggestions = self.suggestionList.count;
    [self show:suggestions > 0 withAnimation:YES]; // TODO: 個数0なら、バーごと消す
    
    if (suggestions == 0) [self removeAll];
    
    return suggestions;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString * cellId = @"cell";
    
    UIView *rotatedView = nil;
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.height, self.frame.size.height);
		cell.contentView.frame = cell.bounds;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
        CGRect frame = CGRectInset(CGRectMake(0.0f, 0.0f, cell.bounds.size.height, cell.bounds.size.width), kDefaultMargin, kDefaultMargin);
		rotatedView = [[UIView alloc] initWithFrame:frame];
        rotatedView.tag = kTagRotatedView;
		rotatedView.center = cell.contentView.center;
		rotatedView.clipsToBounds = YES;
        
        rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        rotatedView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        
		[cell.contentView addSubview:rotatedView];
		
        // customization
        [self customizeView:rotatedView];
        
    } else {
        rotatedView = [cell.contentView viewWithTag:kTagRotatedView];
    }
    
    UILabel * textLabel = (UILabel *)[rotatedView viewWithTag:kTagLabelView];
    // set the default properties
    textLabel.font = self.font;
    textLabel.textColor = self.textColor;
    textLabel.text = [self.suggestionList objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)customizeView:(UIView *)rotatedView
{
    // create the label
    UILabel * textLabel = [[UILabel alloc] initWithFrame:rotatedView.bounds];
    textLabel.tag = kTagLabelView;
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textLabel.backgroundColor = [UIColor clearColor];
    [rotatedView addSubview:textLabel];
}


@end
