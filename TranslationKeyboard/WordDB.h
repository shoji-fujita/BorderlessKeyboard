//
//  WordDB.h
//  SDatabase
//
//  Created by SunJiangting on 12-10-20.
//  Copyright (c) 2012年 sun. All rights reserved.
//

#import "SDBManager.h"

@class Word;

@interface WordDB : NSObject {
    FMDatabase * _db;
}

- (NSMutableArray *) getAllWords;                   // 全データ取得
- (void) setAllWords:(NSMutableArray *)array;
- (NSString *) getNewUidAndAddWord:(Word *) word;   // 追加
- (void) deleteWordWithId:(NSString *) uid;         // 削除
- (void) mergeWithWord:(Word *) word;               // 編集

- (NSMutableArray *) getAllIcons;                   // アイコンの全データ取得
- (NSMutableArray *) getAllUrls;                    // Urlの全データ取得

/*
 ・全データ取得
 初回起動時
 
 ・追加
 辞書編集画面
 webから返ってきたときのアラートOK
 辞書ボードからのアラートOK
 
 ・編集
 辞書編集画面
 第二の言語バーがタップされたときに使用回数を増やす
 
 ・削除
 辞書編集画面（横スライド、編集アラートでアウトプット欄を空のとき）

 */

@end

