//
//  YAPhotoBrowser.h
//  YAPhotoBroswerDemo
//
//  Created by liuyan on 13-12-23.
//  Copyright (c) 2013年 liuyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YAPhotoBrowser;

@protocol YAPhotoBrowserDelegate <NSObject>

@optional
- (void)photoBrowser:(YAPhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(YAPhotoBrowser *)photoBrowser longPressActionAtIndex:(NSUInteger)index;

@end

@interface YAPhotoBrowser : UIViewController

@property (nonatomic, weak) id<YAPhotoBrowserDelegate> delegate;

- (instancetype)initWithPhotoArray:(NSArray *)photoArray;
- (instancetype)initWithPhotoURLArray:(NSArray *)photoURLArray;

- (void)setInitialPageIndex:(NSUInteger)pageIndex;
- (void)setProgressTintColor:(UIColor *)tintColor;

- (UIImage *)photoImageAtIndex:(NSUInteger)index;

@end
