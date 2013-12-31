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

@property (nonatomic, assign) NSUInteger totalPages;

@property (nonatomic, weak) id<YAPhotoBrowserDelegate> delegate;

- (instancetype)initWithPhotoArray:(NSArray *)photoArray;
- (instancetype)initWithPhotoURLArray:(NSArray *)photoURLArray;

- (void)setInitialPageIndex:(NSUInteger)pageIndex;
- (void)setProgressTintColor:(UIColor *)tintColor;

- (UIImage *)photoImageAtIndex:(NSUInteger)index;

- (void)reloadCurrentPhotoPage;

@end
