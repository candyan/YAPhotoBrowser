//
//  YAPhotoBrowser.h
//  YAPhotoBroswerDemo
//
//  Created by liuyan on 13-12-23.
//  Copyright (c) 2013年 liuyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YAPhotoBrowser;
@class SDWebImageManager;

@protocol YAPhotoBrowserDelegate <NSObject>

@optional
- (void)photoBrowser:(YAPhotoBrowser *)photoBrowser willDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(YAPhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(YAPhotoBrowser *)photoBrowser longPressActionAtIndex:(NSUInteger)index;
- (void)photoBrowser:(YAPhotoBrowser *)photoBrowser
   willDownloadImage:(SDWebImageManager *)webImageManager
         downloadURL:(NSURL *)URL;
- (void)photoBrowser:(YAPhotoBrowser *)photoBrowser willDisplayPhotoAtPageIndex:(NSUInteger)index;

@end

@interface YAPhotoBrowser : UIViewController

@property (nonatomic, assign) NSUInteger initialPageIndex;
@property (nonatomic, assign) NSUInteger totalPages;

@property (nonatomic, assign) BOOL showPagesTip;

@property (nonatomic, strong) UIColor *progressTintColor;

@property (nonatomic, strong, readonly) NSMutableArray *photos;

@property (nonatomic, weak) id<YAPhotoBrowserDelegate> delegate;

- (instancetype)initWithPhotoArray:(NSArray *)photoArray;
- (instancetype)initWithPhotoURLArray:(NSArray *)photoURLArray;

- (void)setShowPagesTip:(BOOL)show animated:(BOOL)flag;

- (UIImage *)photoImageAtIndex:(NSUInteger)index;

- (void)reloadCurrentPhotoPage;

@end
