//
//  URBAlertView.h
//  URBFlipModalViewControllerDemo
//
//  Created by Nicholas Shipes on 12/21/12.
//  Copyright (c) 2012 Urban10 Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVSegmentedControl;

enum {
	URBAlertAnimationDefault = 0,
	URBAlertAnimationFade,
	URBAlertAnimationFlipHorizontal,
	URBAlertAnimationFlipVertical,
	URBAlertAnimationTumble,
	URBAlertAnimationSlideLeft,
	URBAlertAnimationSlideRight
};

enum kAlertCancelorOK {
    kAlertCancel = 1,
    kAlertOK = 2,
};

enum kAlertWordorCustom {
    kAlertWord = 0,
    kAlertCustom = 1,
};

enum kAlertAddorEdit {
    kAlertAdd = 0,
    kAlertEdit = 1,
};

typedef NSInteger URBAlertAnimation;

@interface URBAlertView : UIView <UITextFieldDelegate>

typedef void (^URBAlertViewBlock)(NSInteger buttonIndex, URBAlertView *alertView);

@property (nonatomic, assign) BOOL darkenBackground;
@property (nonatomic, assign) BOOL blurBackground;

@property (nonatomic, strong) UITextField       *textField1;
@property (nonatomic, strong) UITextField       *textField2;
@property (nonatomic, strong) UITextField       *textField3;
@property (nonatomic, strong) SVSegmentedControl *seg;

+ (URBAlertView*)sharedInstance;
- (void)wordorCustom:(enum kAlertWordorCustom)wordmode addorEdit:(enum kAlertAddorEdit)addmode;

- (void)setHandlerBlock:(URBAlertViewBlock)block;

- (void)show;
- (void)showWithCompletionBlock:(void(^)())completion;
- (void)showWithAnimation:(URBAlertAnimation)animation;
- (void)showWithAnimation:(URBAlertAnimation)animation completionBlock:(void(^)())completion;

- (void)hide;
- (void)hideWithCompletionBlock:(void(^)())completion;
- (void)hideWithAnimation:(URBAlertAnimation)animation;
- (void)hideWithAnimation:(URBAlertAnimation)animation completionBlock:(void(^)())completion;

@end
