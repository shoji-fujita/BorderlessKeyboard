//
//  Weixin.h
//  test2
//
//  Created by SHOJI FUJITA on 2013/06/08.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"


@interface Weixin : NSObject

/*
 
 video - tudou
 music - QQ音乐
 
 thumbImage - 正方形に切り取られる
 
 */

// text
+ (void)sendText:(NSString *)text toWXScene:(enum WXScene)scene;

// image
+ (void)sendImageData:(NSData *)imageData thumbImage:(UIImage *)thumbImage toWXScene:(enum WXScene)scene;
+ (void)sendImage:(UIImage *)image toWXScene:(enum WXScene)scene;

// stamp (gif animation, gif, png, jpeg)
+ (void)sendStampData:(NSData *)stampData thumbImage:(UIImage *)thumbImage;

// news
+ (void)sendNewsTitle:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage
                  url:(NSString *)url toWXScene:(enum WXScene)scene;

// music
+ (void)sendMusicTitle:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage
              musicUrl:(NSString *)musicUrl musicDataUrl:(NSString *)musicDataUrl toWXScene:(enum WXScene)scene;

// video
+ (void)sendVideoTitle:(NSString *)title description:(NSString *)description thumbImage:(UIImage *)thumbImage
                   url:(NSString *)url toWXScene:(enum WXScene)scene;


@end