//
//  ReadText.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/23.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "ReadText.h"
#import "Word.h"

@implementation ReadText

// 行ごとに一つの単語のテキストのみ有効
+ (NSMutableArray*)readCustomWordsFromFileName:(NSString*)fileName
{
    NSArray *fileNameArray = [fileName componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileNameArray[0]
                                               ofType:fileNameArray[1]];
    
    // ファイルを読み込む
    NSString *fileData = [NSString stringWithContentsOfFile:filePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
    if (!fileData) {
        return nil; // 読み込み失敗
    }
    
    // 改行文字で分割する
    NSArray *lineArray = [fileData componentsSeparatedByString:@"\n"];
    if (!lineArray || [lineArray count] == 0)
        return nil; // ファイルの内容が正しくない
    
    // ファイルの内容を解析する
    NSMutableArray *newItemsArray = [[NSMutableArray alloc] init];
    
    for (NSString *line in lineArray)
    {
        if ([line length] == 0) {
            break;
        }
        
        [newItemsArray addObject:line];
    }
    
    NSLog(@"%@", newItemsArray);
    
    return newItemsArray;
}

// 行ごとに複数の単語を「，」で区切ったテキストのみ有効
+ (NSMutableArray*)readTranslationWordsFromFileName:(NSString*)fileName
{
    NSArray *fileNameArray = [fileName componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileNameArray[0]
                                                         ofType:fileNameArray[1]];
    
    // ファイルを読み込む
    NSString *fileData = [NSString stringWithContentsOfFile:filePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSLog(@"fileData = %@", fileData);
    if (!fileData) {
        return nil; // 読み込み失敗
    }
    
    // 改行文字で分割する
    NSArray *lineArray = [fileData componentsSeparatedByString:@"\n"];
    if (!lineArray || [lineArray count] == 0)
        return nil; // ファイルの内容が正しくない
    
    // ファイルの内容を解析する
    NSMutableArray *newItemsArray = [NSMutableArray array];
    Word *curItem = nil;
    
    for (NSString *line in lineArray)
    {
        if ([line length] == 0) {
            break;
        }
        
        NSString *yomiString = nil;
        
        NSArray *wordPair = [line componentsSeparatedByString:@"，"];
        if ([wordPair count] == 3) { // 読み、あり
            yomiString = wordPair[2];
        }
        
        curItem = [[Word alloc] init];
        curItem.inputString     = wordPair[0];
        curItem.outputString    = wordPair[1];
        curItem.yomiString      = yomiString;
        curItem.usedCount       = 0;

        [newItemsArray addObject:curItem];
    }
    
    return newItemsArray;
}

+ (void)writeTextFile:(NSMutableArray *)array
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"sample.txt"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 注意．
    // ファイルに書き込もうとしたときに該当のファイルが存在しないとエラーになるため
    // ファイルが存在しない場合は空のファイルを作成する
    
    // ファイルが存在しないか?
    if (![fileManager fileExistsAtPath:filePath]) { // yes
        // 空のファイルを作成する
        BOOL result = [fileManager createFileAtPath:filePath
                                           contents:[NSData data] attributes:nil];
        if (!result) {
            NSLog(@"ファイルの作成に失敗");
            return;
        }
    }
    
    NSMutableString *ms = [NSMutableString string];
    
    for (Word *word in array)
    {
        NSString *str;
        str = [NSString stringWithFormat:@"%@%@%@%@",
               word.inputString,
               @",",
               word.outputString,
               @"\n"];
        
        [ms appendString:str];
    }
    
    //ファイルへの書き込み
    [ms writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    NSLog(@"ファイルの書き込みが完了しました．");
}


@end
