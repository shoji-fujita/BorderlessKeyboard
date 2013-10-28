//
//  DictionaryCell.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/08/13.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "DictionaryCell.h"

#define kCountLabelWidth    40
#define kMargin             10

@implementation DictionaryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = kInputBackgroundColor;
        
        UILabel *outputLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - kCountLabelWidth - kMargin, self.frame.size.height / 2)];
        UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 2, self.frame.size.width - kCountLabelWidth - kMargin, self.frame.size.height / 2)];
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - kCountLabelWidth - kMargin, 0, kCountLabelWidth, self.frame.size.height)];
        
        outputLabel.backgroundColor = kOutputBackgroundColor;
        outputLabel.textColor = [UIColor orangeColor];
        outputLabel.font = [UIFont systemFontOfSize:12];
        outputLabel.textAlignment = NSTextAlignmentLeft;
        outputLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        outputLabel.adjustsFontSizeToFitWidth = YES;
        outputLabel.minimumScaleFactor = 10.0/15.0;
        outputLabel.userInteractionEnabled = YES;
        [self.contentView addSubview:outputLabel];
        self.outputLabel = outputLabel;
        
        inputLabel.backgroundColor = [UIColor clearColor];
        inputLabel.textColor = [UIColor grayColor];
        inputLabel.font = [UIFont systemFontOfSize:18];
        inputLabel.textAlignment = NSTextAlignmentLeft;
        inputLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        inputLabel.adjustsFontSizeToFitWidth = YES;
        inputLabel.minimumScaleFactor = 10.0/15.0;
        inputLabel.userInteractionEnabled = YES;
        [self.contentView addSubview:inputLabel];
        self.inputLabel = inputLabel;
        
        countLabel.backgroundColor = [UIColor clearColor];
        countLabel.textColor = [UIColor darkGrayColor];
        countLabel.textAlignment = NSTextAlignmentRight;
        countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        countLabel.adjustsFontSizeToFitWidth = YES;
        countLabel.font = [UIFont systemFontOfSize:15];
        countLabel.minimumScaleFactor = 7.0/10.0;
        countLabel.userInteractionEnabled = YES;
        [self.contentView addSubview:countLabel];
        self.countLabel = countLabel;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
