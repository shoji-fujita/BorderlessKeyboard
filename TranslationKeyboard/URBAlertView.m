//
//  URBAlertView.m
//  URBFlipModalViewControllerDemo
//
//  Created by Nicholas Shipes on 12/21/12.
//  Copyright (c) 2012 Urban10 Interactive. All rights reserved.
//

#import "URBAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "SVSegmentedControl.h"

@interface UIDevice (OSVersion)
- (BOOL)iOSVersionIsAtLeast:(NSString *)version;
@end

@interface UIView (Screenshot)
- (UIImage*)screenshot;
@end

@interface UIImage (Blur)
-(UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end

@interface URBAlertView ()
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIImageView   *overlay;
@property (nonatomic, assign) URBAlertAnimation animationType;
@property (nonatomic, strong) URBAlertViewBlock block;
@property (nonatomic, strong) UIView *blurredBackgroundView;
@property (nonatomic, strong) UIImageView *alertView;
@property (nonatomic, strong) UIImageView *titleView;
@property (nonatomic, assign) enum kAlertWordorCustom wordorCustom;
@property (nonatomic, strong) UIWindow *window;
- (void)animateWithType:(URBAlertAnimation)animation show:(BOOL)show completionBlock:(void(^)())completion;
- (void)showOverlay:(BOOL)show;
- (void)buttonTapped:(id)button;
- (UIView *)blurredBackground;
- (void)cleanup;
@end

#define kURBAlertBackgroundRadius 10.0
#define kURBAlertFrameInset 7.0
#define kURBAlertPadding 10.0
#define kURBAlertButtonPadding 6.0
#define kURBAlertButtonHeight 44.0
#define kURBAlertButtonOffset 66.5

#define kAlertTextFieldHeight 30.0

@implementation URBAlertView {
@private
	struct {
		CGRect titleRect;
		CGRect buttonRect;
	} layout;
}

#pragma mark - 初期化 -

static URBAlertView*  _sharedInstance = nil;

+ (URBAlertView*)sharedInstance
{
    if (!_sharedInstance) {
        _sharedInstance = [[URBAlertView alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
	self = [super init];
	if (self) {
        
		self.animationType = URBAlertAnimationDefault;
		
		self.opaque = NO;
		self.alpha = 1.0;
		self.darkenBackground = YES;
		self.blurBackground = NO;
	}
	return self;
}

- (void)wordorCustom:(enum kAlertWordorCustom)wordmode addorEdit:(enum kAlertAddorEdit)addmode
{
    self.wordorCustom = wordmode;
    
    if (!self.alertView) {

        CGRect appFrame =  [[UIScreen mainScreen] applicationFrame];
        CGFloat alertY = ((appFrame.size.height - (216+35)) - 214) / 2 + 20;
        
        // alert
        self.alertView = [[UIImageView alloc] initWithFrame:CGRectMake(20, alertY, 280, 214)];
        self.alertView.image = [UIImage imageNamed:@"alertView.png"];
        self.alertView.userInteractionEnabled = YES;
        
        // title
        self.titleView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 22, 246, 18)];
        self.titleView.backgroundColor = [UIColor clearColor];
        [self.alertView addSubview:self.titleView];
        
        // textField
        CGFloat width = self.alertView.bounds.size.width - 40;
        
        self.textField1 = [self baseTextField];
        self.textField1.frame = CGRectMake(20, 50, width, kAlertTextFieldHeight);
        self.textField1.backgroundColor = kOutputBackgroundColor;
        self.textField1.textColor = kOutputTextColor;
        self.textField1.placeholder = @"中国語";
        [self.alertView addSubview:self.textField1];
        
        self.textField2 = [self baseTextField];
        self.textField2.frame = CGRectOffset(self.textField1.frame, 0, kAlertTextFieldHeight);
        self.textField2.backgroundColor = [UIColor whiteColor];
        self.textField2.textColor = [UIColor blackColor];
        self.textField2.placeholder = @"日本語";
        
        self.textField3 = [self baseTextField];
        self.textField3.frame = CGRectOffset(self.textField2.frame, 0, kAlertTextFieldHeight);
        self.textField3.backgroundColor = [UIColor whiteColor];
        self.textField3.textColor = [UIColor blackColor];
        self.textField3.placeholder = @"ひらがな";
        
        // seg
        self.seg = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"文頭", @"文中", @"文末", @"其他", nil]];
        self.seg.font = [UIFont systemFontOfSize:17];
        self.seg.selectedIndex = 3;
        self.seg.changeHandler = ^(NSUInteger newIndex) {
            NSLog(@"segmentedControl did select index %i (via block handler)", newIndex);
        };
        self.seg.center = CGPointMake(140, 115);
        
        // ok_button
        self.titleFont = [UIFont boldSystemFontOfSize:16.0];
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 153, 120, 45)];
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"alertBtn.png"] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"alertBtnH.png"] forState:UIControlStateHighlighted];
        [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont fontWithName:self.titleFont.fontName size:16.0];
        [cancelBtn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.tag = kAlertCancel;
        [self.alertView addSubview:cancelBtn];
        
        // cancel_button
        UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(143, 153, 120, 45)];
        [okBtn setBackgroundImage:[UIImage imageNamed:@"alertBtn.png"] forState:UIControlStateNormal];
        [okBtn setBackgroundImage:[UIImage imageNamed:@"alertBtnH.png"] forState:UIControlStateHighlighted];
        [okBtn setTitle:@"OK" forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        okBtn.titleLabel.font = [UIFont fontWithName:self.titleFont.fontName size:16.0];
        okBtn.tag = kAlertOK;
        [self.alertView addSubview:okBtn];
    }
    
    if (wordmode == kAlertWord) { // textField3つなら
        // segを外して、textField２つを加える
        self.textField1.returnKeyType = UIReturnKeyNext;
        [self.seg removeFromSuperview];
        [self.alertView addSubview:self.textField2];
        [self.alertView addSubview:self.textField3];
        
    } else {
        // textField２つを外して、segを加える
        self.textField1.returnKeyType = UIReturnKeyDone;
        [self.textField2 removeFromSuperview];
        [self.textField3 removeFromSuperview];
        [self.alertView addSubview:self.seg];
    }
    
    if (addmode == kAlertAdd) { // add
        self.titleView.image = [UIImage imageNamed:@"titleNew.png"];
    } else {
        self.titleView.image = [UIImage imageNamed:@"titleEdit.png"];
    }
}

- (void)setHandlerBlock:(URBAlertViewBlock)block {
	self.block = block;
}

#pragma mark - textFields

- (UITextField *)baseTextField
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.borderStyle = UITextBorderStyleBezel;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.font = [UIFont systemFontOfSize:17];
    textField.minimumFontSize = 8;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.returnKeyType = UIReturnKeyNext;
    textField.text = @"";
    textField.delegate = self;
    
    return textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField // リターンが押されたとき
{
    switch (self.wordorCustom) {
        case kAlertWord:
            
            if (textField == self.textField1) {
                [self.textField2 becomeFirstResponder];
            } else if (textField == self.textField2) {
                [self.textField3 becomeFirstResponder];
            } else {
                [self.textField1 becomeFirstResponder];
            }
            break;
            
        case kAlertCustom:
            
            [textField resignFirstResponder];
            [self buttonTappedOK]; // OKを押したことにする
            break;
    }
    return NO;
}

- (void)buttonTappedOK
{
    if ([self.textField1.text length] == 0) { // 中身が空のとき
        [self shake]; // 左右にシェイクでOKさせない
        return;
    } else {
        if (self.block)
            self.block(kAlertOK, self);
    }
}

#pragma mark - Animations

- (void)show {
	[self animateWithType:self.animationType show:YES completionBlock:nil];
}

- (void)showWithCompletionBlock:(void (^)())completion {
	[self animateWithType:self.animationType show:YES completionBlock:completion];
}

- (void)showWithAnimation:(URBAlertAnimation)animation {
	self.animationType = animation;
	[self animateWithType:self.animationType show:YES completionBlock:nil];
}

- (void)showWithAnimation:(URBAlertAnimation)animation completionBlock:(void (^)())completion {
	self.animationType = animation;
	[self animateWithType:animation show:YES completionBlock:completion];
}

- (void)hide {
	[self animateWithType:self.animationType show:NO completionBlock:nil];
}

- (void)hideWithCompletionBlock:(void (^)())completion {
	[self animateWithType:self.animationType show:NO completionBlock:completion];
}

- (void)hideWithAnimation:(URBAlertAnimation)animation {
	self.animationType = animation;
	[self animateWithType:self.animationType show:NO completionBlock:nil];
}

- (void)hideWithAnimation:(URBAlertAnimation)animation completionBlock:(void (^)())completion {
	self.animationType = animation;
	[self animateWithType:animation show:NO completionBlock:completion];
}

- (void)shake
{
    URBAlertAnimation animation = URBAlertAnimationFlipHorizontal;
    
    CGFloat xAxis = (animation == URBAlertAnimationFlipVertical) ? 1.0 : 0.0;
    CGFloat yAxis = (animation == URBAlertAnimationFlipHorizontal) ? 1.0 : 0.0;
    
    self.alertView.layer.zPosition = 100;
    
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    perspectiveTransform.m34 = 1.0 / -500;
    
    // initial starting rotation
    self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(30.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
    
    [UIView animateWithDuration:0.10 animations:^{ // flip remaining + bounce
        self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(-20.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.13 animations:^{
            self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(12.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(-8.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(0.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
                } completion:^(BOOL finished) {
                }];
            }];
        }];
    }];
}

- (void)buttonTapped:(id)button {

    enum kAlertCancelorOK cancelorOK = ((UIButton *)button).tag;
    
    switch (cancelorOK) {
        case kAlertCancel:
            
            break;
            
        case kAlertOK:
            
            if (self.wordorCustom == kAlertWord) {
                
                if ([self.textField1.text length] == 0 || [self.textField2.text length] == 0) {
                    [self shake];
                    return;
                }
                if ([self.textField2.text isEqualToString:self.textField3.text]) {
                    self.textField3.text = @""; // 日本語とよみが同じなら消す
                }
            } else {
                if ([self.textField1.text length] == 0) {
                    [self shake];
                    return;
                }
            }
            
            break;
    }

	if (self.block)
		self.block(cancelorOK, self);
}

- (UIView *)blurredBackground {
	UIView *backgroundView = [[UIApplication sharedApplication] keyWindow];
	UIImageView *blurredView = [[UIImageView alloc] initWithFrame:backgroundView.bounds];
	blurredView.image = [[backgroundView screenshot] boxblurImageWithBlur:0.08];
	
	return blurredView;
}

- (void)animateWithType:(URBAlertAnimation)animation show:(BOOL)show completionBlock:(void (^)())completion {
	// make sure everything is laid out before we try animation, otherwise we get some sketchy things happening
	// especially with the buttons
	if (show) {
		[self setNeedsLayout];
		[self layoutIfNeeded];
	}
	
	// fade animation
	if (animation == URBAlertAnimationFade) {
		if (show) {
			[self showOverlay:YES];
			
			self.alertView.transform = CGAffineTransformMakeScale(0.97, 0.97);
			[UIView animateWithDuration:0.25 animations:^{
				self.alertView.transform = CGAffineTransformIdentity;
				self.alertView.alpha = 1.0f;
			} completion:^(BOOL finished) {
				if (completion)
					completion();
			}];
		}
		else {
			[self showOverlay:NO];
			
			[UIView animateWithDuration:0.25 animations:^{
				self.alertView.transform = CGAffineTransformMakeScale(0.97, 0.97);
				self.alertView.alpha = 0.0f;
			} completion:^(BOOL finished) {
				[self cleanup];
				if (completion)
					completion();
			}];
		}
	}
	
	// horizontal flip animation
	else if (animation == URBAlertAnimationFlipHorizontal || animation == URBAlertAnimationFlipVertical) {
		
		CGFloat xAxis = (animation == URBAlertAnimationFlipVertical) ? 1.0 : 0.0;
		CGFloat yAxis = (animation == URBAlertAnimationFlipHorizontal) ? 1.0 : 0.0;
		
		if (show) {
			self.alertView.layer.zPosition = 100;
			
			CATransform3D perspectiveTransform = CATransform3DIdentity;
			perspectiveTransform.m34 = 1.0 / -500;
			
			// initial starting rotation
			self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(70.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
			self.alertView.alpha = 0.0f;
			
			[self showOverlay:YES];
			
			[UIView animateWithDuration:0.2 animations:^{ // flip remaining + bounce
				self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(-25.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
				self.alertView.alpha = 1.0f;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.13 animations:^{
				 self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(12.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.1 animations:^{
						self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(-8.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
					} completion:^(BOOL finished) {
					   [UIView animateWithDuration:0.1 animations:^{
						   self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(0.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
					   } completion:^(BOOL finished) {
						   if (completion)
							   completion();
					   }];
					}];
				}];
			}];
		}
		else {
			[self showOverlay:NO];
			
			self.alertView.layer.zPosition = 100;
			self.alertView.alpha = 1.0f;
			
			CATransform3D perspectiveTransform = CATransform3DIdentity;
			perspectiveTransform.m34 = 1.0 / -500;
			
			[UIView animateWithDuration:0.08 animations:^{
				self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(-10.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.17 animations:^{
					self.alertView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(70.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
					self.alertView.alpha = 0.0f;
				} completion:^(BOOL finished) {
					[self cleanup];
					if (completion)
						completion();
				}];
			}];
		}
	}
	
	// tumble animation
	else if (animation == URBAlertAnimationTumble) {
		if (show) {
			[self showOverlay:YES];
			
			CATransform3D rotate = CATransform3DMakeRotation(70.0 * M_PI / 180.0, 0.0, 0.0, 1.0);
			CATransform3D translate = CATransform3DMakeTranslation(20.0, -500.0, 0.0);
			self.alertView.layer.transform = CATransform3DConcat(rotate, translate);
			
			[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				self.alertView.layer.transform = CATransform3DIdentity;
			} completion:^(BOOL finished) {
				if (completion)
					completion();
			}];
		}
		else {
			[self showOverlay:NO];
			
			[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				CATransform3D rotate = CATransform3DMakeRotation(-70.0 * M_PI / 180.0, 0.0, 0.0, 1.0);
				CATransform3D translate = CATransform3DMakeTranslation(-20.0, 500.0, 0.0);
				self.alertView.layer.transform = CATransform3DConcat(rotate, translate);
			} completion:^(BOOL finished) {
				[self cleanup];
				if (completion)
					completion();
			}];
		}
	}
	
	// slide animation
	else if (animation == URBAlertAnimationSlideLeft || animation == URBAlertAnimationSlideRight) {		
		if (show) {
			[self showOverlay:YES];
			
			CGFloat startX = (animation == URBAlertAnimationSlideLeft) ? 200.0 : -200.0;
			CGFloat shiftX = 5.0;
			if (animation == URBAlertAnimationSlideLeft)
				shiftX *= -1.0;
			
			self.alertView.layer.transform = CATransform3DMakeTranslation(startX, 0.0, 0.0);
			[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				self.alertView.layer.transform = CATransform3DMakeTranslation(shiftX, 0.0, 0.0);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.1 animations:^{
					self.alertView.layer.transform = CATransform3DIdentity;
				} completion:^(BOOL finished) {
					if (completion)
						completion();
				}];
			}];
		}
		else {
			[self showOverlay:NO];
			
			CGFloat finalX = (animation == URBAlertAnimationSlideLeft) ? -400.0 : 400.0;
			CGFloat shiftX = 5.0;
			if (animation == URBAlertAnimationSlideRight)
				shiftX *= 1.0;
			
			[UIView animateWithDuration:0.1 animations:^{
				self.alertView.layer.transform = CATransform3DMakeTranslation(shiftX, 0.0, 0.0);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
					self.alertView.layer.transform = CATransform3DMakeTranslation(finalX, 0.0, 0.0);
				} completion:^(BOOL finished) {
					[self cleanup];
					if (completion)
						completion();
				}];
			}];
		}
	}
	
	// default "pop" animation like UIAlertView
	else {
		if (show) {
			[self showOverlay:YES];
			
			self.alpha = 0.0f;			
			[UIView animateWithDuration:0.17 animations:^{
				self.alertView.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.0);
				self.alertView.alpha = 1.0f;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.12 animations:^{
					self.alertView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.1 animations:^{
						self.alertView.layer.transform = CATransform3DIdentity;
					} completion:^(BOOL finished) {
						if (completion)
							completion();
					}];
				}];
			}];
		}
		else {
			[self showOverlay:NO];
			
			[UIView animateWithDuration:0.1 animations:^{
				self.alertView.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.0);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.15 animations:^{
					self.alertView.layer.transform = CATransform3DIdentity;
					self.alertView.alpha = 0.0f;
				} completion:^(BOOL finished) {
					[self cleanup];
					if (completion)
						completion();
				}];
			}];
		}
	}
}

- (void)showOverlay:(BOOL)show {
	if (show) {
		// create a new window to add our overlay and dialogs to
        UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window = window;
        window.windowLevel = UIWindowLevelStatusBar + 1;
        window.opaque = NO;
		
		// darkened background
		if (self.darkenBackground) {
            
            UIImageView *overlay = [UIImageView new];
            overlay.backgroundColor = [UIColor clearColor];
            
            NSString *overlayImageName = nil;
            if ([[UIScreen mainScreen] bounds].size.height <= 480) {
                overlayImageName = @"overlay4.png";
            } else {
                overlayImageName = @"overlay5.png";
            }
            overlay.image = [UIImage imageNamed:overlayImageName];
            
            self.overlay = overlay;
			overlay.opaque = NO;
			overlay.frame = self.window.bounds;
			overlay.alpha = 0.0;
		}
		
		// blurred background
		if (self.blurBackground) {
			self.blurredBackgroundView = [self blurredBackground];
			self.blurredBackgroundView.alpha = 0.0f;
			[self.window addSubview:self.blurredBackgroundView];
		}
		
		[self.window addSubview:self.overlay];
		[self.window addSubview:self.alertView];

		// window has to be un-hidden on the main thread
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.window makeKeyAndVisible];
			
			// fade in overlay
			[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
				self.blurredBackgroundView.alpha = 1.0f;
				self.overlay.alpha = 1.0f;
			} completion:^(BOOL finished) {
				// stub
			}];
		});
	}
	else {
		[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
			self.overlay.alpha = 0.0f;
			self.blurredBackground.alpha = 0.0f;
		} completion:^(BOOL finished) {
			self.blurredBackgroundView = nil;
		}];
	}
}

- (void)cleanup {
	self.alertView.layer.transform = CATransform3DIdentity;
	self.transform = CGAffineTransformIdentity;
	self.alertView.alpha = 1.0f;
	self.window = nil;
	// rekey main AppDelegate window
	[[[[UIApplication sharedApplication] delegate] window] makeKeyWindow];
}

@end

#pragma mark - UIDevice + OSVersion

@implementation UIDevice (OSVersion)

- (BOOL)iOSVersionIsAtLeast:(NSString *)version {
    NSComparisonResult result = [[self systemVersion] compare:version options:NSNumericSearch];
    return (result == NSOrderedDescending || result == NSOrderedSame);
}

@end


#pragma mark - UIView + Screenshot

@implementation UIView (Screenshot)

- (UIImage*)screenshot {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // hack, helps w/ our colors when blurring
    NSData *imageData = UIImageJPEGRepresentation(image, 1); // convert to jpeg
    image = [UIImage imageWithData:imageData];
    
    return image;
}

@end


#pragma mark - UIImage + Blur

@implementation UIImage (Blur)

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 50);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end




