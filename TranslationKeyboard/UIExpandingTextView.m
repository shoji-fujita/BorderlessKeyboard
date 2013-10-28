/*
 *  UIExpandingTextView.m
 *  
 *  Created by Brandon Hamilton on 2011/05/03.
 *  Copyright 2011 Brandon Hamilton.
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

/* 
 *  This class is based on growingTextView by Hans Pickaers 
 *  http://www.hanspinckaers.com/multi-line-uitextview-similar-to-sms
 */

#import "UIExpandingTextView.h"
#import <QuartzCore/QuartzCore.h>
#define kTextInsetX 4
#define kTextInsetBottom 0

@implementation UIExpandingTextView

@synthesize internalTextView;
@synthesize delegate;

@synthesize text;
@synthesize font;
@synthesize textColor;
@synthesize textAlignment; 
@synthesize selectedRange;
@synthesize editable;
@synthesize dataDetectorTypes; 
@synthesize animateHeightChange;
@synthesize returnKeyType;
@synthesize textViewBackgroundImage;
@synthesize placeholder;
@synthesize placeholderLabel;

- (void)setPlaceholder:(NSString *)placeholders
{
    placeholder = placeholders;
    placeholderLabel.text = placeholders;
}

- (int)minimumNumberOfLines
{
    return minimumNumberOfLines;
}

- (int)maximumNumberOfLines
{
    return maximumNumberOfLines;
}

-(void)dealloc{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:kTextViewDidChange                 object:nil];
    [nc removeObserver:self name:kTextViewShouldBeginEditing        object:nil];
    [nc removeObserver:self name:kTextViewShouldEndEditing          object:nil];
    [nc removeObserver:self name:kTextViewDidBeginEditing           object:nil];
    [nc removeObserver:self name:kTextViewDidEndEditing             object:nil];
    [nc removeObserver:self name:kTextViewShouldChangeTextInRange   object:nil];
    [nc removeObserver:self name:kTextViewDidChangeSelection        object:nil];
    [nc removeObserver:self name:kSuggestionListReload              object:nil];
}
- (void)addNotification {
    // 通知を受け取ることで、高さ調整＆プレースホルダ消しができる。
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(textViewDidChange2:)            name:kTextViewDidChange                 object:nil];
    [nc addObserver:self selector:@selector(textViewShouldBeginEditing:)    name:kTextViewShouldBeginEditing        object:nil];
    [nc addObserver:self selector:@selector(textViewShouldEndEditing:)      name:kTextViewShouldEndEditing          object:nil];
    [nc addObserver:self selector:@selector(textViewDidBeginEditing:)       name:kTextViewDidBeginEditing           object:nil];
    [nc addObserver:self selector:@selector(textViewDidEndEditing:)         name:kTextViewDidEndEditing             object:nil];
    [nc addObserver:self selector:@selector(shouldChangeTextInRange:)       name:kTextViewShouldChangeTextInRange   object:nil];
    [nc addObserver:self selector:@selector(textViewDidChangeSelection:)    name:kTextViewDidChangeSelection        object:nil];
    [nc addObserver:self selector:@selector(textViewDidChange2:)    name:kSuggestionListReload              object:nil];
}

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        [self addNotification];
        
        forceSizeUpdate = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		CGRect backgroundFrame = frame;
        backgroundFrame.origin.y = 0;
		backgroundFrame.origin.x = 0;
        
        CGRect textViewFrame = CGRectInset(backgroundFrame, kTextInsetX, kTextInsetX);

        /* Internal Text View component */
		internalTextView = [[UIExpandingTextViewInternal alloc] initWithFrame:textViewFrame];
		internalTextView.font            = [UIFont systemFontOfSize:17.0];
		internalTextView.contentInset    = UIEdgeInsetsMake(-4,0,-4,0);
        internalTextView.text            = @"-";
		internalTextView.scrollEnabled   = NO;
        internalTextView.opaque          = NO;
        internalTextView.backgroundColor = [UIColor clearColor];
        internalTextView.showsHorizontalScrollIndicator = NO;
        [internalTextView sizeToFit];
//        internalTextView.layer.borderColor = RGBACOLOR(78, 51, 34, 0.8)  .CGColor;
//        internalTextView.layer.borderWidth =1.0;
        internalTextView.layer.cornerRadius =5.0;
        internalTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        /* set placeholder */
        placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(8,2,self.bounds.size.width - 16,self.bounds.size.height)];
        placeholderLabel.text = placeholder;
        placeholderLabel.font = internalTextView.font;
        placeholderLabel.backgroundColor = [UIColor clearColor];
        placeholderLabel.textColor = [UIColor grayColor];
        [internalTextView addSubview:placeholderLabel];
        
        /* Custom Background image */
        textViewBackgroundImage = [[UIImageView alloc] initWithFrame:backgroundFrame];
        textViewBackgroundImage.image          = [UIImage imageNamed:@"InputBack"];
        textViewBackgroundImage.contentMode    = UIViewContentModeScaleToFill;
//        UIEdgeInsets insets = UIEdgeInsetsMake(0.5, 0.5, 0, 0);
//        [textViewBackgroundImage setImage:[[UIImage imageNamed:@"keyBoardBack"] resizableImageWithCapInsets:insets]];
        //textViewBackgroundImage.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
        [self addSubview:textViewBackgroundImage];
        [self addSubview:internalTextView];

        /* Calculate the text view height */
		UIView *internal = (UIView*)[[internalTextView subviews] objectAtIndex:0];
		minimumHeight = internal.frame.size.height;
		[self setMinimumNumberOfLines:1];
		animateHeightChange = YES;
		internalTextView.text = @"";
		[self setMaximumNumberOfLines:13];
        
        [self sizeToFit];
    }
    return self;
}

-(void)sizeToFit
{
    CGRect r = self.frame;
    if ([self.text length] > 0)
    {
        /* No need to resize is text is not empty */
        return;
    }
    r.size.height = minimumHeight + kTextInsetBottom;
    self.frame = r;
}

-(void)setFrame:(CGRect)aframe
{
    CGRect backgroundFrame   = aframe;
    backgroundFrame.origin.y = 0;
    backgroundFrame.origin.x = 0;
    CGRect textViewFrame = CGRectInset(backgroundFrame, kTextInsetX, kTextInsetX);
	internalTextView.frame   = textViewFrame;
//    backgroundFrame.size.height  -= 8;
    textViewBackgroundImage.frame = backgroundFrame;
    forceSizeUpdate = YES;
	[super setFrame:aframe];
}

-(void)clearText
{
    self.text = @"";
    [self textViewDidChange:self.internalTextView];
}
     
-(void)setMaximumNumberOfLines:(int)n
{
    BOOL didChange            = NO;
    NSString *saveText        = internalTextView.text;
    NSString *newText         = @"-";
    internalTextView.hidden   = YES;
    for (int i = 2; i < n; ++i)
    {
        newText = [newText stringByAppendingString:@"\n|W|"];
    }
    internalTextView.text     = newText;
    didChange = (maximumHeight != internalTextView.contentSize.height);
    maximumHeight             = internalTextView.contentSize.height;
    maximumNumberOfLines      = n;
    internalTextView.text     = saveText;
    internalTextView.hidden   = NO;
    if (didChange) {
        forceSizeUpdate = YES;
        [self textViewDidChange:self.internalTextView];
    }
}

-(void)setMinimumNumberOfLines:(int)m
{
    NSString *saveText        = internalTextView.text;
    NSString *newText         = @"-";
    internalTextView.hidden   = YES;
    for (int i = 2; i < m; ++i)
    {
        newText = [newText stringByAppendingString:@"\n|W|"];
    }
    internalTextView.text     = newText;
    minimumHeight             = internalTextView.contentSize.height;
    internalTextView.text     = saveText;
    internalTextView.hidden   = NO;
    [self sizeToFit];
    minimumNumberOfLines = m;
}


- (void)textViewDidChange:(UITextView *)textView
{
    if(textView.text.length == 0)
        placeholderLabel.alpha = 1;
    else
        placeholderLabel.alpha = 0;
    
	NSInteger newHeight = internalTextView.contentSize.height;
    if (newHeight == 43)
        newHeight = 37; // とりあえず一行目だけ対応 // TODO: あとでクラスの拡張性を考慮した造りに変える
    
	if(newHeight < minimumHeight || !internalTextView.hasText)
    {
        newHeight = minimumHeight;
    }
    
    // ここで高さ調整してる
	if (internalTextView.frame.size.height != newHeight || forceSizeUpdate)
	{
        forceSizeUpdate = NO;
        if (newHeight > maximumHeight && internalTextView.frame.size.height <= maximumHeight)
        {
            newHeight = maximumHeight;
        }
		if (newHeight <= maximumHeight)
		{
			if(animateHeightChange)
            {
				[UIView beginAnimations:@"" context:nil];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(growDidStop)];
				[UIView setAnimationBeginsFromCurrentState:YES];
			}
			// 高さに応じて位置を調整
			if ([delegate respondsToSelector:@selector(expandingTextView:willChangeHeight:)])
            {
				[delegate expandingTextView:self willChangeHeight:(newHeight+ kTextInsetBottom)];
			}
			
			/* Resize the frame */
			CGRect r = self.frame;
			r.size.height = newHeight + kTextInsetBottom;
			self.frame = r;
			r.origin.y = 0;
			r.origin.x = 0;
            internalTextView.frame = CGRectInset(r, kTextInsetX, kTextInsetX);
//            r.size.height -= 8;
            textViewBackgroundImage.frame = r;
			if(animateHeightChange)
            {
				[UIView commitAnimations];
			}
            else if ([delegate respondsToSelector:@selector(expandingTextView:didChangeHeight:)]) 
            {
                [delegate expandingTextView:self didChangeHeight:(newHeight+ kTextInsetBottom)];
            }
		}
		
		if (newHeight >= maximumHeight)
		{
            /* Enable vertical scrolling */
			if(!internalTextView.scrollEnabled)
            {
				internalTextView.scrollEnabled = YES;
				[internalTextView flashScrollIndicators];
			}
		} 
        else 
        {
            /* Disable vertical scrolling */
			internalTextView.scrollEnabled = NO;
		}
	}
	
	if ([delegate respondsToSelector:@selector(expandingTextViewDidChange:)]) 
    {
		[delegate expandingTextViewDidChange:self];
	}

	
}

-(void)growDidStop
{
	if ([delegate respondsToSelector:@selector(expandingTextView:didChangeHeight:)]) 
    {
		[delegate expandingTextView:self didChangeHeight:self.frame.size.height];
	}
}
-(BOOL)becomeFirstResponder{
    [super becomeFirstResponder];
    return [internalTextView becomeFirstResponder];
}
-(BOOL)resignFirstResponder
{
	[super resignFirstResponder];
	return [internalTextView resignFirstResponder];
}


#pragma mark UITextView properties

-(void)setText:(NSString *)atext
{
	internalTextView.text = atext;
    [self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
}

-(NSString*)text
{
	return internalTextView.text;
}

-(void)setFont:(UIFont *)afont
{
	internalTextView.font= afont;
	[self setMaximumNumberOfLines:maximumNumberOfLines];
	[self setMinimumNumberOfLines:minimumNumberOfLines];
}

-(UIFont *)font
{
	return internalTextView.font;
}	

-(void)setTextColor:(UIColor *)color
{
	internalTextView.textColor = color;
}

-(UIColor*)textColor
{
	return internalTextView.textColor;
}

-(void)setTextAlignment:(UITextAlignment)aligment
{
	internalTextView.textAlignment = aligment;
}

-(UITextAlignment)textAlignment
{
	return internalTextView.textAlignment;
}

-(void)setSelectedRange:(NSRange)range
{
	internalTextView.selectedRange = range;
}

-(NSRange)selectedRange
{
	return internalTextView.selectedRange;
}

-(void)setEditable:(BOOL)beditable
{
	internalTextView.editable = beditable;
}

-(BOOL)isEditable
{
	return internalTextView.editable;
}

-(void)setReturnKeyType:(UIReturnKeyType)keyType
{
	internalTextView.returnKeyType = keyType;
}

-(UIReturnKeyType)returnKeyType
{
	return internalTextView.returnKeyType;
}

-(void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector
{
	internalTextView.dataDetectorTypes = datadetector;
}

-(UIDataDetectorTypes)dataDetectorTypes
{
	return internalTextView.dataDetectorTypes;
}

- (BOOL)hasText
{
	return [internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range
{
	[internalTextView scrollRangeToVisible:range];
}

#pragma mark -
#pragma mark UIExpandingTextViewDelegate

- (void)textViewDidChange2:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    UITextView *textView = userInfo[@"textView"];
    
    [self textViewDidChange:textView];
}

- (void)textViewShouldBeginEditing:(NSNotification *)notification
{
	if ([delegate respondsToSelector:@selector(expandingTextViewShouldBeginEditing:)])
    {
        [delegate expandingTextViewShouldBeginEditing:self];
	}
}

- (void)textViewShouldEndEditing:(NSNotification *)notification
{
	if ([delegate respondsToSelector:@selector(expandingTextViewShouldEndEditing:)]) 
    {
		[delegate expandingTextViewShouldEndEditing:self];
	}
}

- (void)textViewDidBeginEditing:(NSNotification *)notification
{
	if ([delegate respondsToSelector:@selector(expandingTextViewDidBeginEditing:)]) 
    {
		[delegate expandingTextViewDidBeginEditing:self];
	}
}

- (void)textViewDidEndEditing:(NSNotification *)notification
{		
	if ([delegate respondsToSelector:@selector(expandingTextViewDidEndEditing:)]) 
    {
		[delegate expandingTextViewDidEndEditing:self];
	}
}

- (void)shouldChangeTextInRange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    //UITextView *textView = userInfo[@"textView"];
    NSRange range = [userInfo[@"range"] rangeValue];
    NSString *aText = userInfo[@"text"];
    
    if ([delegate respondsToSelector:@selector(expandingTextView:shouldChangeTextInRange:replacementText:)])
    {
		[delegate expandingTextView:self shouldChangeTextInRange:range replacementText:aText];
	}
}

- (void)textViewDidChangeSelection:(NSNotification *)notification
{
	if ([delegate respondsToSelector:@selector(expandingTextViewDidChangeSelection:)]) 
    {
		[delegate expandingTextViewDidChangeSelection:self];
	}
}

@end
