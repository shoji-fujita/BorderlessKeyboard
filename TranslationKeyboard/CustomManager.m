//
//  ItemManager.m
//  CollectionViewSample
//
//  Created by SHOJI FUJITA on 2013/07/25.
//  Copyright (c) 2013年 Natsuko Nishikata. All rights reserved.
//

#import "CustomManager.h"
#import "CustomItem.h"

#define kWidth      310 // 貼り付けるViewの横幅
#define kHeight     35  // テキストの最大の高さ
#define kFontSize   15  // フォントサイズ
#define kMinBlank   20  // 単語の両端につくる余白
#define kPlist      @"custom.dat"


@interface CustomManager () {
    NSString *_filePath;
}
@end


@implementation CustomManager

#pragma mark - 初期化 -

static CustomManager*  _sharedInstance = nil;

+ (CustomManager*)sharedManager
{
    if (!_sharedInstance) {
        _sharedInstance = [[CustomManager alloc] init];
    }
    
    return _sharedInstance;
}

+ (UIColor *)getColor:(NSInteger)colorIndex
{
    UIColor *color = nil;
    
    switch (colorIndex) {
        case 0:
            color = [UIColor magentaColor];
            break;
        case 1:
            color = [UIColor blueColor];
            break;
        case 2:
            color = [UIColor redColor];
            break;
        case 3:
            color = [UIColor blackColor];
            break;
    }
    return color;
}

+ (NSString *)getColorName:(NSInteger)colorIndex
{
    NSString *name = nil;
    
    switch (colorIndex) {
        case 0:
            name = @"文頭";
            break;
        case 1:
            name = @"文中";
            break;
        case 2:
            name = @"文末";
            break;
        case 3:
            name = @"其他";
            break;
        default:
            name = @"";
            break;
    }
    return name;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _filePath = [documentPath stringByAppendingPathComponent:kPlist];
    
    [self readAllCustom];
    [self reloadCellSizeArray];
    
    return self;
}

//- (void)readAllCustom2
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSError *error;
//    
//    BOOL success = [fileManager fileExistsAtPath:_filePath];
//    if(!success){
//        NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kPlist];
//        success = [fileManager copyItemAtPath:resourcePath toPath:_filePath error:&error];
//    }
//    if(!success){
//        NSLog(@"ファイルの読み込みに失敗しました");
//    }
//    
//    //NSMutableArray *array = [NSData dataWithContentsOfFile:_filePath];
//    
//    
//    NSArray *array = [NSArray arrayWithContentsOfFile:_filePath];
//    NSMutableArray *array2 = [NSMutableArray new];
//
//    for (NSDictionary *dic in array) {
//        CustomItem *item = [CustomItem new];
//        item.text         = [dic objectForKey:@"text"];
//        item.colorInteger = [[dic objectForKey:@"color"] integerValue];
//        [array2 addObject:item];
//    }
//    
//    self.items = array2;
//}

- (void)readAllCustom
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    BOOL success = [fileManager fileExistsAtPath:_filePath];
    if(!success){
        NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kPlist];
        success = [fileManager copyItemAtPath:resourcePath toPath:_filePath error:&error];
    }
    if(!success){
        NSLog(@"ファイルの読み込みに失敗しました");
    }
    
    self.items = [NSKeyedUnarchiver unarchiveObjectWithFile:_filePath];
}

- (BOOL)writeAllCustom
{
    BOOL result = [NSKeyedArchiver archiveRootObject:self.items toFile:_filePath];

    if (!result) {
        NSLog(@"ファイルの書き込みに失敗");
        return NO;
    }
    NSLog(@"ファイルの書き込みが完了しました");
    
    return YES;
}

- (void)reloadCellSizeArray
{
    self.cellSizeArray = [self cellSizes:[self textSizes]]; // 各セルのサイズを取得
}

- (NSMutableArray *)textSizes
{
    NSMutableArray *textSizeArray = [NSMutableArray array];

    for (CustomItem *item in self.items)
    {
        CGSize size = [self cgsizeWithString:item.text];
        
        // 余白を設定する
        size.width = size.width + kMinBlank;
        
        NSValue *value = [NSValue valueWithCGSize:size];
        [textSizeArray addObject:value];
    }
    
    return textSizeArray;
}

- (CGSize)cgsizeWithString:(NSString *)text
{
    CGSize bounds = CGSizeMake(kWidth, kHeight);
    UIFont *font = [UIFont systemFontOfSize:kFontSize];
    NSLineBreakMode mode = NSLineBreakByTruncatingTail;
    
    //１行だけのサイズを取得
    CGSize size = [text sizeWithFont:font forWidth:bounds.width lineBreakMode:mode];
    
    return size;
}

- (NSMutableArray *)cellSizes:(NSMutableArray *)textSizeArray
{
    CGFloat     widthSum = 0.0;
    NSInteger   count    = 0;
    NSInteger   rowStart = 0;
    NSMutableArray *cellSizeArray = [NSMutableArray array];
    
    for (int i = 0; i < [textSizeArray count]; i++)
    {
        NSValue *value = [textSizeArray objectAtIndex:i];
        CGSize size = [value CGSizeValue];
        CGFloat width = size.width;
        
        widthSum += width;
        count++;
        
        if (widthSum > kWidth) // もし横幅がオーバーしていたら
        {
            CGFloat blankWidth =  kWidth - (widthSum - width); // 行全体の余白
            CGFloat margin =  floorf(blankWidth / (count - 1)); // 一つのセルに含める余白（小数点切り捨て）
            
            for (int j = rowStart; j < rowStart + (count - 1) ; j++) {
                NSValue *value2 = [textSizeArray objectAtIndex:j];
                CGSize size2 = [value2 CGSizeValue];
                CGFloat width2 = size2.width;
                width2 += margin;
                NSValue *value3 = [NSValue valueWithCGSize:CGSizeMake(width2, size2.height)];
            
                [cellSizeArray addObject:value3];
            }
            // リセット
            rowStart += (count - 1);
            widthSum = 0;
            count = 0;
            i--;
            
        }
        else // 横幅がオーバーしていないなら
        {
            if (i == [textSizeArray count] - 1) // 最終cellに到達したら
            {
                CGFloat blankWidth =  kWidth - widthSum; // 行全体の余白
                CGFloat margin = floorf(blankWidth / count); // 一つのセルに含める余白
                
                for (int j = rowStart; j < [textSizeArray count]; j++) {
                    NSValue *value2 = [textSizeArray objectAtIndex:j];
                    CGSize size2 = [value2 CGSizeValue];
                    CGFloat width2 = size2.width;
                    width2 += margin;
                    NSValue *value3 = [NSValue valueWithCGSize:CGSizeMake(width2, size2.height)];
                    
                    [cellSizeArray addObject:value3];
                }
            }
        }
    }
    return cellSizeArray;
}


@end

