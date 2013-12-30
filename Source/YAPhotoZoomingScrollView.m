//
//  YAPhotoZoomingScrollView.m
//  YAPhotoBroswerDemo
//
//  Created by liuyan on 13-12-23.
//  Copyright (c) 2013年 liuyan. All rights reserved.
//

#import "YAPhotoZoomingScrollView.h"
#import "FFCircularProgressView.h"
#import "SDWebImageManager.h"

@implementation YAPhotoZoomingScrollView

@synthesize photoImageView = _photoImageView;
@synthesize progressView = _progressView;
@synthesize webImageManager = _webImageManager;

#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.delegate = self;

    self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UITapGestureRecognizer *singleGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(_handleSingleTapGR:)];
    [self addGestureRecognizer:singleGR];

    UITapGestureRecognizer *twiceGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(_handleDoubleTapGR:)];
    [twiceGR setNumberOfTapsRequired:2];
    [twiceGR setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:twiceGR];

    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(_handleLongPressGR:)];
    [self addGestureRecognizer:longPressGR];

    [singleGR requireGestureRecognizerToFail:twiceGR];
  }
  return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
	// Update tap view frame
//	_tapView.frame = self.bounds;

	// Super
	[super layoutSubviews];

  // Center the image as it becomes smaller than the size of the screen
  CGSize boundsSize = self.bounds.size;
  CGRect frameToCenter = self.photoImageView.frame;

  // Horizontally
  if (frameToCenter.size.width < boundsSize.width) {
    frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
    frameToCenter.origin.x = 0;
	}

  // Vertically
  if (frameToCenter.size.height < boundsSize.height) {
    frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
    frameToCenter.origin.y = 0;
	}

	// Center
	if (!CGRectEqualToRect(self.photoImageView.frame, frameToCenter))
		self.photoImageView.frame = frameToCenter;
}

#pragma mark - getter

- (UIImageView *)photoImageView
{
  if (!_photoImageView) {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:imageView];
    _photoImageView = imageView;
  }
  return _photoImageView;
}

static CGFloat const kProgressViewSize = 50.0f;
- (FFCircularProgressView *)progressView
{
  if (!_progressView) {
    FFCircularProgressView *cProgressView = [[FFCircularProgressView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                                     kProgressViewSize,
                                                                                                     kProgressViewSize)];
    [cProgressView setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
    [cProgressView setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin
                                        | UIViewAutoresizingFlexibleBottomMargin
                                        | UIViewAutoresizingFlexibleLeftMargin
                                        | UIViewAutoresizingFlexibleRightMargin)];
    [self addSubview:cProgressView];
    _progressView = cProgressView;
  }
  return _progressView;
}

- (SDWebImageManager *)webImageManager
{
  if (!_webImageManager) {
    _webImageManager = [[SDWebImageManager alloc] init];
  }
  return _webImageManager;
}

#pragma mark - setter

- (void)setPhotoImage:(UIImage *)photoImage
{
  _photoImage = photoImage;
  [self _displayImage];
}

- (void)setPhotoURL:(NSURL *)photoURL
{
  _photoURL = photoURL;

  if ([self.webImageManager diskImageExistsForURL:photoURL]) {
    UIImage *image = [self.webImageManager.imageCache imageFromDiskCacheForKey:photoURL.absoluteString];
    self.photoImage = image;
  } else {
    [self.progressView setHidden:NO];
    [self.progressView setProgress:0.2];

    if ([self.photoZoomingDelegate respondsToSelector:@selector(photoZoomingScrollView:willDownloadImage:downloadURL:)]) {
      [self.photoZoomingDelegate photoZoomingScrollView:self
                                      willDownloadImage:self.webImageManager
                                            downloadURL:photoURL];
    }
    __weak typeof(self) weakSelf = self;
    [self.webImageManager downloadWithURL:photoURL
                                  options:SDWebImageProgressiveDownload | SDWebImageRetryFailed
                                 progress:^(NSUInteger receivedSize, long long expectedSize)
     {
       if (expectedSize > 0) {
         CGFloat progress = ((CGFloat)receivedSize / (CGFloat)expectedSize);
         [weakSelf.progressView setProgress:progress];
       }
     } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
       if (finished) {
         weakSelf.photoImage = image;
         [weakSelf.progressView setHidden:YES];
       }
     }];
  }
}

#pragma mark - reuse

- (void)prepareForReuse
{
  [self.webImageManager cancelAll];
  self.photoImageView.image = nil;
  self.photoURL = nil;
  self.photoImage = nil;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.photoImageView;
}

#pragma mark - display

- (void)_displayImage
{
  if (self.photoImage && self.photoImageView.image == nil) {
    self.maximumZoomScale = 1.0f;
    self.minimumZoomScale = 1.0f;
    self.zoomScale = 1.0f;

    self.contentSize = CGSizeZero;

    self.photoImageView.image = self.photoImage;
    self.photoImageView.hidden = NO;

    // Setup photo frame
    CGRect photoImageViewFrame;
    photoImageViewFrame.origin = CGPointZero;
    photoImageViewFrame.size = self.photoImage.size;

    self.photoImageView.frame = photoImageViewFrame;
    self.contentSize = photoImageViewFrame.size;

    // Set zoom to minimum zoom
    [self _setMaxMinZoomScalesForCurrentBounds];
  } else {
    self.photoImageView.hidden = YES;
  }
  [self setNeedsLayout];
}

#pragma mark - Setup

- (void)_setMaxMinZoomScalesForCurrentBounds
{
	// Reset
	self.maximumZoomScale = 1;
	self.minimumZoomScale = 1;
	self.zoomScale = 1;

	// Bail
	if (self.photoImageView.image == nil) return;

	// Sizes
  CGSize boundsSize = self.bounds.size;
  CGSize imageSize = _photoImageView.frame.size;

  // Calculate Min
  CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
  CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
  CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible

	// If image is smaller than the screen then ensure we show it at
	// min scale of 1
	if (xScale > 1 && yScale > 1) {
		//minScale = 1.0;
	}

	// Calculate Max
	CGFloat maxScale = 4.0; // Allow double scale
  // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
  // maximum zoom scale to 0.5.
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}

	// Set
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
  self.zoomScale = minScale;

	// Reset position
  self.photoImageView.frame = CGRectMake(0, 0,
                                         self.photoImageView.frame.size.width,
                                         self.photoImageView.frame.size.height);
	[self setNeedsLayout];
}

#pragma mark Handel GR

- (void)_handleSingleTapGR:(UITapGestureRecognizer *)tapGR
{
  if ([self.photoZoomingDelegate respondsToSelector:@selector(photoZoomingScrollView:singleTapDetected:)]) {
    [self.photoZoomingDelegate photoZoomingScrollView:self singleTapDetected:tapGR];
  }
}

- (void)_handleLongPressGR:(UILongPressGestureRecognizer *)longPressGR
{
  if (self.photoImage
      && [self.photoZoomingDelegate respondsToSelector:@selector(photoZoomingScrollView:longPressDetected:)]
      && longPressGR.state == UIGestureRecognizerStateBegan) {
    [self.photoZoomingDelegate photoZoomingScrollView:self
                                    longPressDetected:longPressGR];
  }
}

- (void)_handleDoubleTapGR:(UITapGestureRecognizer *)tapGR
{
  if (self.photoImage) {
    // Zoom
    if (self.zoomScale == self.maximumZoomScale) {
      // Zoom out
      [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
      // Zoom in
      CGPoint touchPoint = [tapGR locationInView:self.photoImageView];
      [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
  }
}

@end
