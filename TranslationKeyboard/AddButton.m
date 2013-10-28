//
//  AddButton.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/09/08.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "AddButton.h"


@implementation AddButton

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		static UIImage *normalButtonImage;
		static dispatch_once_t once;
		dispatch_once(&once, ^{
			normalButtonImage = [self normalButtonImage];
		});
		[self setBackgroundImage:normalButtonImage forState:UIControlStateNormal];
	}
	return self;
}

- (UIImage *)normalButtonImage {
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// colors
	UIColor *buttonBgGradientColorTop = [UIColor lightGrayColor];//[UIColor colorWithRed: 0.146 green: 0.146 blue: 0.146 alpha: 1];
	UIColor *buttonBgGradientColorBottom = [UIColor lightGrayColor];//[UIColor colorWithRed: 0.069 green: 0.069 blue: 0.069 alpha: 1];
	UIColor *buttonOuterGradientColor = [UIColor lightGrayColor];//[UIColor colorWithRed: 0.259 green: 0.259 blue: 0.259 alpha: 1];
	UIColor *buttonOuterGradientColor2 = [UIColor lightGrayColor];//[UIColor colorWithRed: 0.172 green: 0.172 blue: 0.172 alpha: 1];
	UIColor *buttonInnerGradientColor = [UIColor lightGrayColor];//[UIColor colorWithRed: 0.326 green: 0.326 blue: 0.326 alpha: 1];
	UIColor *buttonInnerGradientColor2 = [UIColor lightGrayColor];//[UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 1];
	
	// gradients
	NSArray *buttonBgGradientColors = @[(id)buttonBgGradientColorTop.CGColor, (id)buttonBgGradientColorBottom.CGColor];
	CGFloat buttonBgGradientLocations[] = {0, 1};
	CGGradientRef buttonBgGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)buttonBgGradientColors, buttonBgGradientLocations);
	NSArray *buttonOuterGradientColors = @[(id)buttonOuterGradientColor.CGColor, (id)buttonOuterGradientColor2.CGColor];
	CGFloat buttonOuterGradientLocations[] = {0, 1};
	CGGradientRef buttonOuterGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)buttonOuterGradientColors, buttonOuterGradientLocations);
	NSArray *buttonInnerGradientColors = @[(id)buttonInnerGradientColor.CGColor, (id)buttonInnerGradientColor2.CGColor];
	CGFloat buttonInnerGradientLocations[] = {0, 1};
	CGGradientRef buttonInnerGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)buttonInnerGradientColors, buttonInnerGradientLocations);
	
	// shadows
	UIColor *buttonShadow = [UIColor blackColor];
	CGSize buttonShadowOffset = CGSizeMake(0.1, -0.1);
	CGFloat buttonShadowBlurRadius = 2;
    
	CGRect frame = self.bounds;
	
	// base drawing
	CGRect buttonBgRect = frame;
	UIBezierPath *buttonBgPath = [UIBezierPath bezierPathWithRoundedRect:buttonBgRect cornerRadius:9];
	CGContextSaveGState(context);
	[buttonBgPath addClip];
	CGContextDrawLinearGradient(context, buttonBgGradient,
								CGPointMake(CGRectGetMidX(buttonBgRect), CGRectGetMinY(buttonBgRect)),
								CGPointMake(CGRectGetMidX(buttonBgRect), CGRectGetMaxY(buttonBgRect)),
								0);
	CGContextRestoreGState(context);
	
	
	// outer drawing
	CGRect buttonOuterRect = CGRectInset(frame, 4.0, 4.0);
	UIBezierPath *buttonOuterPath = [UIBezierPath bezierPathWithRoundedRect:buttonOuterRect cornerRadius:6];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, buttonShadowOffset, buttonShadowBlurRadius, buttonShadow.CGColor);
	CGContextBeginTransparencyLayer(context, NULL);
	[buttonOuterPath addClip];
	CGContextDrawLinearGradient(context, buttonOuterGradient,
								CGPointMake(CGRectGetMidX(buttonOuterRect), CGRectGetMinY(buttonOuterRect)),
								CGPointMake(CGRectGetMidX(buttonOuterRect), CGRectGetMaxY(buttonOuterRect)),
								0);
	CGContextEndTransparencyLayer(context);
	CGContextRestoreGState(context);
	
	
	
	// inner drawing
	CGRect buttonInnerRect = CGRectInset(frame, 6.0, 6.0);
	UIBezierPath *buttonInnerPath = [UIBezierPath bezierPathWithRoundedRect:buttonInnerRect cornerRadius:4];
	CGContextSaveGState(context);
	[buttonInnerPath addClip];
	CGContextDrawLinearGradient(context, buttonInnerGradient,
								CGPointMake(CGRectGetMidX(buttonInnerRect), CGRectGetMinY(buttonInnerRect)),
								CGPointMake(CGRectGetMidX(buttonInnerRect), CGRectGetMaxY(buttonInnerRect)),
								0);
	CGContextRestoreGState(context);
	
	// cleanup
	CGGradientRelease(buttonBgGradient);
	CGGradientRelease(buttonOuterGradient);
	CGGradientRelease(buttonInnerGradient);
	CGColorSpaceRelease(colorSpace);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)];
}

@end





