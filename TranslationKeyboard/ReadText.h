//
//  ReadText.h
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/23.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadText : NSObject

+ (NSMutableArray*)readCustomWordsFromFileName:(NSString*)filePath;
+ (NSMutableArray*)readTranslationWordsFromFileName:(NSString*)filePath;
+ (void)writeTextFile:(NSMutableArray*)array;

@end
