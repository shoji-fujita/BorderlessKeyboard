//
//  DictionaryCell.h
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/08/13.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DictionaryCell : UITableViewCell

@property (nonatomic, weak) UILabel *outputLabel;
@property (nonatomic, weak) UILabel *inputLabel;
@property (nonatomic, weak) UILabel *countLabel;

@end
