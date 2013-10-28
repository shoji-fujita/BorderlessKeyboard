//  ACEAutocompleteInputView.m
//
// Copyright (c) 2013 Stefano Acerbetti
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "ACEAutocompleteBar.h"
#import <QuartzCore/QuartzCore.h>
#import "TKAlertCenter.h"

#define kDefaultHeight      35.0f
#define kDefaultMargin      7.0f

#define kTagRotatedView     101
#define kTagLabelView       102

@interface ACEAutocompleteInputView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *suggestionList;
@property (nonatomic, strong) UITableView *suggestionListView;
@end

#pragma mark -

@implementation ACEAutocompleteInputView

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
- (void)addNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(suggestionListReload:) name:kSuggestionListReload object:nil];
}

- (id)init
{
    [self addNotification];
    
    return [self initWithHeight:kDefaultHeight];
}

- (id)initWithHeight:(CGFloat)height
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320 - 45, height)];
    if (self) {
        // create the table view with the suggestions
        _suggestionListView	= [[UITableView alloc] initWithFrame:CGRectMake((self.bounds.size.width - self.bounds.size.height) / 2,
                                                                            (self.bounds.size.height - self.bounds.size.width) / 2,
                                                                            self.bounds.size.height, self.bounds.size.width)];
        
        // init the bar the hidden state
        self.hidden = YES;
        
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
        _font = [UIFont boldSystemFontOfSize:18.0f];
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

#pragma makr - Helpers

- (NSString *)stringForObjectAtIndex:(NSUInteger)index
{
    id object = [self.suggestionList objectAtIndex:index];
    if ([object conformsToProtocol:@protocol(ACEAutocompleteItem)]) {
        return [object autocompleteString];
        
    } else if ([object isKindOfClass:[NSString class]]) {
        return object;
    
    } else {
        return nil;
    }
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(inputView:widthForObject:)]) {
        return [self.dataSource inputView:self widthForObject:[self.suggestionList objectAtIndex:indexPath.row]];
        
    } else {
        NSString * string = [self stringForObjectAtIndex:indexPath.row];
        CGFloat width = [string sizeWithFont:self.font constrainedToSize:self.frame.size].width;
        if (width == 0) {
            // bigger than the screen
            return self.frame.size.width;
        }
        
        // add some margins
        return width + (kDefaultMargin * 2) + 1.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate textView:self.textView didSelectObject:[self.suggestionList objectAtIndex:indexPath.row] inInputView:self];
    
    // hide the bar
    [self show:NO withAnimation:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger suggestions = self.suggestionList.count;
    [self show:suggestions > 0 withAnimation:YES];
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
    
    // customize the cell view if the data source support it, just use the text otherwise
    if ([self.dataSource respondsToSelector:@selector(inputView:setObject:forView:)]) {
        [self.dataSource inputView:self setObject:[self.suggestionList objectAtIndex:indexPath.row] forView:rotatedView];
        
    } else {
        UILabel * textLabel = (UILabel *)[rotatedView viewWithTag:kTagLabelView];
        
        // set the default properties
        textLabel.font = self.font;
        textLabel.textColor = self.textColor;
        textLabel.text = [self stringForObjectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)customizeView:(UIView *)rotatedView
{
    // customization
    if ([self.dataSource respondsToSelector:@selector(inputView:customizeView:)]) {
        [self.dataSource inputView:self customizeView:rotatedView];
        
    } else {
        // create the label
        UILabel * textLabel = [[UILabel alloc] initWithFrame:rotatedView.bounds];
        textLabel.tag = kTagLabelView;
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textLabel.backgroundColor = [UIColor clearColor];
        [rotatedView addSubview:textLabel];
    }
}

#pragma mark - 通知を飛ばす -

- (void)notificationTextView:(UITextView *)textView name:(NSString *)name
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:textView forKey:@"textView"];
    NSNotification *n = [NSNotification notificationWithName:name object:self userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

#pragma mark - textViewDelegate -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self notificationTextView:textView name:kTextViewShouldBeginEditing];
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self notificationTextView:textView name:kTextViewDidBeginEditing];
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self notificationTextView:textView name:kTextViewShouldEndEditing];
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self notificationTextView:textView name:kTextViewDidEndEditing];
}
- (void)textViewDidChange:(UITextView *)textView
{
    [self notificationTextView:textView name:kTextViewDidChange];
}
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [self notificationTextView:textView name:kTextViewDidChangeSelection];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // range.length > 2 なら確定のEnterが押されてる。 // ここで第二の言語バーが表示されてるなら一番左を選択状態に、表示されてないなら矢印キーを選択状態に。
    // range.length = 1なら「×」or「一文字の確定」

    // textViewDidChangeじゃダメなの？
    
    NSLog(@"%d, %d, %@", range.location, range.length, text);
    
    NSString * query = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSLog(@"query = %@", query);
    
    if ([query hasSuffix:@"☻"]) {
        query = [self changeQuery:query];
    }
    
    if (query.length >= [self.dataSource minimumCharactersToTrigger:self]) {
        [self.dataSource inputView:self itemsFor:query result:^(NSArray *items) {
            self.suggestionList = items;
            [self.suggestionListView reloadData];
        }];
        
    } else {
        self.suggestionList = nil;
        [self.suggestionListView reloadData];
    }
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         textView, @"textView",
                         [NSValue valueWithRange:range], @"range",
                         text, @"text", nil];
    
    NSNotification *n = [NSNotification notificationWithName:kTextViewShouldChangeTextInRange object:self userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:n];
    
    if ([text isEqualToString:@"\n"]) {
        
        return NO;
    } else if (range.location == 0) {
        
        NSString *outputString = nil;
        if ([text isEqualToString:@"、"]) {
            outputString = @"，";
        } else if ([text isEqualToString:@"。"]) {
            outputString = @"。";
        } else if ([text isEqualToString:@"？"]) {
            outputString = @"？";
        } else if ([text isEqualToString:@"！"]) {
            outputString = @"！";
        } else if ([text isEqualToString:@" "]) {
            outputString = @" ";
        }
        
        if (!outputString)  return YES;
        
        NSDictionary *dic = [NSDictionary dictionaryWithObject:outputString forKey:@"text"];
        NSNotification *n = [NSNotification notificationWithName:kWriteText
                                                          object:self
                                                        userInfo:dic];
        [[NSNotificationCenter defaultCenter] postNotification:n];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:outputString duration:0.3];
        
        return NO;
    } else {
        return YES;
    }
}

- (void)suggestionListReload:(NSNotification *)notification
{
    NSString *text = [[notification userInfo] objectForKey:@"text"];
    [self textView:self.textView shouldChangeTextInRange:NSMakeRange(0, text.length) replacementText:text];
}
//
//- (NSString *)hoge:(NSString *)text
//{
//    // @"ああ", @"いあ", @"うあ"… 
//    
//    NSArray *array = @[@[@"あ", @"い", @"う", @"え", @"お", @"ぁ", @"ぃ", @"ぅ", @"ぇ", @"ぉ"],
//                       @[@"か", @"き", @"く", @"け", @"こ"],
//                       @[@"さ", @"し", @"す", @"せ", @"そ"],
//                       @[@"た", @"ち", @"つ", @"て", @"と", @"っ"],
//                       @[@"な", @"に", @"ぬ", @"ね", @"の"],
//                       @[@"は", @"ひ", @"ふ", @"へ", @"ほ"],
//                       @[@"ま", @"み", @"む", @"め", @"も"],
//                       @[@"や", @"ゆ", @"よ", @"ゃ", @"ゅ", @"ょ"],
//                       @[@"わ", @"を", @"ん", @"ー"]];
//    
//}

- (NSString *)changeQuery:(NSString *)text
{
    if ([text length] == 1)
        return text; // ●だけなら●を返す
    
    // ２文字以上（ ● 込みで）
    NSString *headText = [text substringToIndex:[text length] - 2];
    NSString *tailText = [text substringFromIndex:[text length] - 2]; // ×●の２文字
    NSString *character = [tailText substringToIndex:1]; // ×の1文字
    NSString *changeText = nil;
    
    NSArray *characterArray = @[@[@"あ", @"ぁ"], @[@"い", @"ぃ"], @[@"う", @"ぅ"], @[@"え", @"ぇ"], @[@"お", @"ぉ"]
                       , @[@"か", @"が"], @[@"き", @"ぎ"], @[@"く", @"ぐ"], @[@"け", @"げ"], @[@"こ", @"ご"]
                       , @[@"さ", @"ざ"], @[@"し", @"じ"], @[@"す", @"ず"], @[@"せ", @"ぜ"], @[@"そ", @"ぞ"]
                       , @[@"た", @"だ"], @[@"ち", @"ぢ"], @[@"つ", @"っ", @"づ"], @[@"て", @"で"], @[@"と", @"ど"]
                       , @[@"は", @"ば", @"ぱ"], @[@"ひ", @"び", @"ぴ"], @[@"ふ", @"ぶ", @"ぷ"], @[@"へ", @"べ", @"ぺ"], @[@"ほ", @"ぼ", @"ぽ"]
                       , @[@"や", @"ゃ"], @[@"ゆ", @"ゅ"], @[@"よ", @"ょ"], @[@"わ", @"ゎ"]];
    for (NSArray *array in characterArray) {
        if ([array containsObject:character]) {

            NSUInteger index = [array indexOfObject:character];
            NSString *string = [array objectAtIndex:((++index)%[array count])]; // 置き換える文字

            changeText = [NSString stringWithFormat:@"%@%@", headText, string];
            return changeText;
        }
    }
    changeText = [NSString stringWithFormat:@"%@%@", headText, character];
    return changeText;
}

@end
