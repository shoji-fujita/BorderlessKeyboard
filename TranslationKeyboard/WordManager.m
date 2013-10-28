//
//  WordManager.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/20.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "WordManager.h"
#import "Word.h"
#import "ReadText.h"
#import "WordDB.h"

@implementation WordManager


static WordManager*  _sharedInstance = nil;

+ (WordManager*)sharedManager
{
    if (!_sharedInstance) {
        _sharedInstance = [[WordManager alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    //self.items = [ReadText readTranslationWordsFromFileName:@"words.txt"];
    //[[WordDB new] setAllWords:self.items];
    self.items = [[WordDB new] getAllWords];
    
    return self;
}


@end
















