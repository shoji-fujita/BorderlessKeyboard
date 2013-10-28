//
//  StockBar.h
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/08/03.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StockBar : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *suggestionList;
@property (nonatomic, strong) UITableView *suggestionListView;
@property (nonatomic, strong) UIButton *clearButton;

@property (nonatomic, strong) UIFont * font;
@property (nonatomic, strong) UIColor * textColor;

- (id)initWithArray:(NSArray *)array;
- (void)show:(BOOL)show withAnimation:(BOOL)animated;
- (void)removeAll;

@end