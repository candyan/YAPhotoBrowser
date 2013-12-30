//
//  YAPhotoZoomingScrollView.h
//  YAPhotoBroswerDemo
//
//  Created by liuyan on 13-12-23.
//  Copyright (c) 2013年 liuyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFCircularProgressView;
@class SDWebImageManager;
@class YAPhotoZoomingScrollView;

@protocol YAPhotoZoomingScrollViewDelegate <NSObject>

@optional
- (void)photoZoomingScrollView:(YAPhotoZoomingScrollView *)scrollView
             singleTapDetected:(UITapGestureRecognizer *)tapGR;
- (void)photoZoomingScrollView:(YAPhotoZoomingScrollView *)scrollView
             longPressDetected:(UILongPressGestureRecognizer *)longPressGR;

- (void)photoZoomingScrollView:(YAPhotoZoomingScrollView *)scrollView
             willDownloadImage:(SDWebImageManager *)webImageManager
                   downloadURL:(NSURL *)URL;

@end

@interface YAPhotoZoomingScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, weak, readonly) UIImageView *photoImageView;
@property (nonatomic, weak, readonly) FFCircularProgressView *progressView;

@property (nonatomic, strong, readonly) SDWebImageManager *webImageManager;

@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) UIImage *photoImage;

@property (nonatomic, weak) id<YAPhotoZoomingScrollViewDelegate> photoZoomingDelegate;

- (void)prepareForReuse;

@end

