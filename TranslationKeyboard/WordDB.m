//
//  WordDB.m
//  SDatabase
//
//  Created by SunJiangting on 12-10-20.
//  Copyright (c) 2012年 sun. All rights reserved.
//

#import "WordDB.h"
#import "Word.h"
#import "IconItem.h"
#import "UrlItem.h"

#define kWordTableName @"words"

@implementation WordDB

- (id) init {
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立message的数据库，如果未建立，则建立数据库=========
        _db = [SDBManager defaultDBManager].dataBase;
    }
    return self;
}

- (NSMutableArray *) getAllWords
{
    NSString * query = @"SELECT uid,output,input,yomi,usedCount FROM words";
    FMResultSet* rs = [_db executeQuery:query];
    NSMutableArray *array = [NSMutableArray new];
    while( [rs next] ) {
        Word * word = [Word new];
        word.uid            = [rs stringForColumn:@"uid"];
        word.outputString   = [rs stringForColumn:@"output"];
        word.inputString    = [rs stringForColumn:@"input"];
        word.yomiString     = [rs stringForColumn:@"yomi"];
        word.usedCount      = [rs intForColumn:@"usedCount"];
        [array addObject:word];
    }
    [rs close];
    
    NSLog(@"%@", array);
    
    return array;
}

- (void) setAllWords:(NSMutableArray *)array {
    
    for (Word *word in array) {
    
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO words"];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:5];
    if (word.outputString) {
        [keys appendString:@"output,"];
        [values appendString:@"?,"];
        [arguments addObject:word.outputString];
    }
    if (word.inputString) {
        [keys appendString:@"input,"];
        [values appendString:@"?,"];
        [arguments addObject:word.inputString];
    }
    if (word.yomiString) {
        [keys appendString:@"yomi,"];
        [values appendString:@"?,"];
        [arguments addObject:word.yomiString];
    }
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    NSLog(@"%@",query);
    [_db executeUpdate:query withArgumentsInArray:arguments];
    
    
    }
}


//・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・

- (NSMutableArray *) getAllIcons
{
    NSString * query = @"SELECT uid,title,imagePath,identifier,row FROM icons limit 5";
    FMResultSet* rs = [_db executeQuery:query];
    NSMutableArray *array = [NSMutableArray new];
    while( [rs next] ) {
        IconItem * icon = [IconItem new];
        // icon.uid は現時点ではいらない。
        icon.title      = [rs stringForColumn:@"title"];
        icon.imagePath  = [rs stringForColumn:@"imagePath"];
        icon.identifier = [rs stringForColumn:@"identifier"];
        icon.row        = [rs intForColumn:@"row"];
        [array addObject:icon];
    }
    [rs close];
    
    NSLog(@"%@", array);
    return array;
}

- (NSMutableArray *) getAllUrls
{
    NSString * query = @"SELECT uid,title,imagePath,url,row FROM urls ORDER BY row limit 5";
    FMResultSet* rs = [_db executeQuery:query];
    NSMutableArray *array = [NSMutableArray new];
    while( [rs next] ) {
        UrlItem * url = [UrlItem new];
        // url.uid は現時点ではいらない。
        url.title      = [rs stringForColumn:@"title"];
        url.imagePath  = [rs stringForColumn:@"imagePath"];
        url.url        = [rs stringForColumn:@"url"];
        url.row        = [rs intForColumn:@"row"];
        [array addObject:url];
    }
    [rs close];
    
    NSLog(@"%@", array);
    return array;
}

- (NSString *) getNewUidAndAddWord:(Word *) word {
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO words"];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:5];
    if (word.outputString) {
        [keys appendString:@"output,"];
        [values appendString:@"?,"];
        [arguments addObject:word.outputString];
    }
    if (word.inputString) {
        [keys appendString:@"input,"];
        [values appendString:@"?,"];
        [arguments addObject:word.inputString];
    }
    if (word.yomiString) {
        [keys appendString:@"yomi,"];
        [values appendString:@"?,"];
        [arguments addObject:word.yomiString];
    }
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    NSLog(@"%@",query);
    [_db executeUpdate:query withArgumentsInArray:arguments];
    
    // 単語追加で自動設定されたidをデータベースから取得して返す
    NSString * query2 = @"SELECT uid FROM words ORDER BY uid DESC limit 1";
    FMResultSet * rs = [_db executeQuery:query2];
    
    NSString *uidString;
    while ([rs next]) {
        uidString = [rs stringForColumn:@"uid"];
        break;
    }
    return uidString;
}

- (void) deleteWordWithId:(NSString *) uid {
    NSString * query = [NSString stringWithFormat:@"DELETE FROM words WHERE uid = '%@'",uid];
    [_db executeUpdate:query];
}

- (void) mergeWithWord:(Word *) word {
    if (!word.uid) {
        return;
    }
    NSString * query = @"UPDATE words SET";
    NSMutableString * temp = [NSMutableString stringWithCapacity:20];
    // xxx = xxx;
    if (word.outputString) {
        [temp appendFormat:@" output = '%@',",word.outputString];
    }
    if (word.inputString) {
        [temp appendFormat:@" input = '%@',",word.inputString];
    }
    if (word.yomiString) {
        [temp appendFormat:@" yomi = '%@',",word.yomiString];
    }
    if (word.yomiString) {
        [temp appendFormat:@" usedCount = '%d',",word.usedCount];
    }
    [temp appendString:@")"];
    query = [query stringByAppendingFormat:@"%@ WHERE uid = '%@'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],word.uid];
    NSLog(@"%@",query);
    
    [_db executeUpdate:query];
}


@end

