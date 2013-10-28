//
//  CustomBoardView.m
//  TranslationKeyboard
//
//  Created by SHOJI FUJITA on 2013/07/23.
//  Copyright (c) 2013年 藤田 勝司. All rights reserved.
//

#import "CustomBoardView.h"
#import "CollectionCell.h"
#import "CustomManager.h"
#import <QuartzCore/QuartzCore.h>
//#import "HeaderView.h"
#import "FooterView.h"
#import "CustomItem.h"

#import "CustomEditViewController.h"

@interface CustomBoardView () {
    UICollectionView *_collectionView;
    UIViewController *_viewController;
}
@end

@implementation CustomBoardView

#pragma mark - 通知 -

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:kCustomBoardReload object:nil];
}
- (void)addNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(reload) name:kCustomBoardReload object:nil];
}
- (void)reload {
    [_collectionView reloadData];
    [_collectionView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}

#pragma mark - init -

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController *)viewController
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addNotification];
        _viewController = viewController;
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back.png"]]; // 高さ一定なので、タイル状にならない
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0.0f; // 左右のスペース
        layout.minimumLineSpacing = 5.0f; // 上下のスペース
        layout.sectionInset = UIEdgeInsetsMake(10, 5, 5, 5);
        
//        layout.headerReferenceSize = CGSizeMake(self.frame.size.width, 44);
        layout.footerReferenceSize = CGSizeMake(self.frame.size.width, 44);
        
        _collectionView=[[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        _collectionView.backgroundColor = [UIColor clearColor];
        
        _collectionView.allowsSelection = NO;
        _collectionView.bounces = NO;
        _collectionView.indicatorStyle = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [self addSubview:_collectionView];
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 8)];
        imageView.image = [UIImage imageNamed:@"back2.png"];
        [self addSubview:imageView];
        
//        [_collectionView registerClass:[HeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerIdentifier"];
        [_collectionView registerClass:[FooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerIdentifier"];
    }
    return self;
}

#pragma mark -
#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[CustomManager sharedManager].items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    CustomItem *item = [[CustomManager sharedManager].items objectAtIndex:indexPath.item];
    [cell.button setTitle:item.text
                 forState:UIControlStateNormal];
    [cell.button setTitleColor:[CustomManager getColor:item.colorInteger] forState:UIControlStateNormal];
    [cell.button addTarget:self action:@selector(writeText:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)writeText:(UIButton*)button
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:button.titleLabel.text forKey:@"text"];
    NSNotification *n = [NSNotification notificationWithName:kWriteText
                                                      object:self
                                                    userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    // kindで分ける
//    if (kind == UICollectionElementKindSectionHeader)
//    {
//        HeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerIdentifier" forIndexPath:indexPath];
//        return headerView;
//    } else {
        FooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerIdentifier" forIndexPath:indexPath];
        [footerView.button addTarget:self action:@selector(openCustomEdit:) forControlEvents:UIControlEventTouchUpInside];
        
        return footerView;
//    }
}

- (void)openCustomEdit:(UIButton *)button
{
    CustomEditViewController *viewController = [[CustomEditViewController alloc] init];
    [_viewController presentViewController:viewController animated:YES completion:nil];
}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

// セルのサイズをアイテムごとに可変とするためのdelegateメソッド

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSValue *value = [[CustomManager sharedManager].cellSizeArray objectAtIndex:indexPath.item];
    CGSize size = [value CGSizeValue];
    size.height = 44;
    
    return size;
}

@end
