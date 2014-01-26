//
//  YAPhotoBrowser.m
//  YAPhotoBroswerDemo
//
//  Created by liuyan on 13-12-23.
//  Copyright (c) 2013年 liuyan. All rights reserved.
//

#import "YAPhotoBrowser.h"
#import "YAPhotoZoomingScrollView.h"
#import "FFCircularProgressView.h"
#import "SDImageCache.h"

@interface YAPhotoBrowser ()<UIScrollViewDelegate, YAPhotoZoomingScrollViewDelegate>
{
  UIView *_senderViewForAnimation;
  CGFloat _animationDuration;
  CGRect _resizableImageViewFrame;
  BOOL _autoHide;
  UIImage *_scaleImage;
  BOOL _useWhiteBackgroundColor;
  CGFloat _backgroundScaleFactor;
}

@property (nonatomic, strong, readwrite) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableSet *visiblePagesSet, *recycledPagesSet;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, weak) UIScrollView *pageScrollView;
@property (nonatomic, weak) UILabel *pagesLabel;

@property (nonatomic, assign) NSUInteger currentPageIndex;

@end

@implementation YAPhotoBrowser {
  UIStatusBarStyle _originalStatusBarStyle;
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
      [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    _initialPageIndex = 0;
    _currentPageIndex = 0;
    _showPagesTip = YES;
    _animationDuration = 0.28;
    _autoHide = YES;
    _senderViewForAnimation = nil;
    _scaleImage = nil;
    _useWhiteBackgroundColor = NO;
    _backgroundScaleFactor = 1.0;
  }
  return self;
}

- (instancetype)initWithPhotoArray:(NSArray *)photoArray
{
  if (!photoArray || photoArray.count == 0) return nil;

  self = [self initWithNibName:nil bundle:nil];
  if (self) {
    _photos = [NSMutableArray arrayWithArray:photoArray];
    _totalPages = _photos.count;
  }
  return self;
}

- (instancetype)initWithPhotoArray:(NSArray *)photoArray animatedFromView:(UIView *)view
{
  id currentSelf = [self initWithPhotoArray:photoArray];
  _senderViewForAnimation = view;
  
  return currentSelf;
}

- (instancetype)initWithPhotoURLArray:(NSArray *)photoURLArray
{
  return [self initWithPhotoArray:photoURLArray];
}

- (instancetype)initWithPhotoURLArray:(NSArray *)photoURLArray animatedFromView:(UIView *)view
{
  id currentSelf = [self initWithPhotoURLArray:photoURLArray];
  _senderViewForAnimation = view;
  
  return currentSelf;
}

#pragma mark - action

- (void)_dismiss
{
  if (_senderViewForAnimation && _currentPageIndex == _initialPageIndex)
  {
    YAPhotoZoomingScrollView *scrollView = [self _displayedPageAtIndex:_currentPageIndex];
    [self _performCloseAnimationWithScrollView:scrollView];
  }
  else
  {
    _senderViewForAnimation.hidden = NO;
    [self _prepareForClosePhotoBrowser];
    [self _dismissPhotoBrowserAnimated:YES];
  }
}

- (void)_prepareForClosePhotoBrowser
{
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
  [[[[UIApplication sharedApplication] delegate] window] removeGestureRecognizer:_panGesture];
  _autoHide = NO;
  [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
}

- (void)_performCloseAnimationWithScrollView:(YAPhotoZoomingScrollView *)scrollView
{
  float fadeAlpha = 1 - abs(scrollView.frame.origin.y)/scrollView.frame.size.height;
  UIImage *imageFromView = scrollView.photoImage;
  CGRect screenBound = [[UIScreen mainScreen] bounds];
  CGFloat screenWidth = screenBound.size.width;
  CGFloat screenHeight = screenBound.size.height;
  float scaleFactor = imageFromView.size.width / screenWidth;
  UIView *fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
  fadeView.backgroundColor = [UIColor blackColor];
  fadeView.alpha = fadeAlpha;
  [[[UIApplication sharedApplication].delegate window] addSubview:fadeView];
  UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
  resizableImageView.frame = (imageFromView) ? CGRectMake(0, (screenHeight/2)-((imageFromView.size.height / scaleFactor)/2)+scrollView.frame.origin.y, screenWidth, imageFromView.size.height / scaleFactor) : CGRectZero;
  resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
  resizableImageView.backgroundColor = [UIColor clearColor];
  resizableImageView.clipsToBounds = YES;
  [[[UIApplication sharedApplication].delegate window] addSubview:resizableImageView];
  self.view.hidden = YES;
  
  [UIView animateWithDuration:_animationDuration animations:^{
    [[[[UIApplication sharedApplication].delegate window] rootViewController].view setTransform:CGAffineTransformIdentity];
    resizableImageView.layer.frame = _resizableImageViewFrame;
    fadeView.alpha = 0;
    self.view.backgroundColor = [UIColor clearColor];
  } completion:^(BOOL finished) {
    _senderViewForAnimation.hidden = NO;
    _senderViewForAnimation = nil;
    _scaleImage = nil;
    [fadeView removeFromSuperview];
    [resizableImageView removeFromSuperview];
    [self _prepareForClosePhotoBrowser];
    [self _dismissPhotoBrowserAnimated:YES];
  }];
}

- (void)_dismissPhotoBrowserAnimated:(BOOL)animated
{
  [self dismissViewControllerAnimated:animated completion:^{
    if ([_delegate respondsToSelector:@selector(photoBrowser:didDismissAtPageIndex:)])
      [_delegate photoBrowser:self didDismissAtPageIndex:_currentPageIndex];
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    rootViewController.modalPresentationStyle = 0;
  }];
}

#pragma mark - view lifeCycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  if (_showPagesTip) {
    [self _setupPagesTip];
  }

  self.pageScrollView.contentOffset = [self _contentOffsetForPageAtIndex:_initialPageIndex];
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self _displayPages];

  [[UIApplication sharedApplication] setStatusBarHidden:YES
                                          withAnimation:(animated
                                                         ? UIStatusBarAnimationFade
                                                         : UIStatusBarAnimationNone)];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:NO
                                          withAnimation:(animated
                                                         ? UIStatusBarAnimationFade
                                                         : UIStatusBarAnimationNone)];
}

- (void)viewWillLayoutSubviews
{
  [self.pageScrollView setFrame:[self _frameForPageScrollView]];
  [self.pageScrollView setContentSize:[self _contentSizeForPageScrollView]];
}

#pragma mark - getter

static CGFloat const kPagesLabelHeight = 26.0f;
- (UILabel *)pagesLabel
{
  if (!_pagesLabel
      && self.totalPages > 1) {
    CGRect frame = self.view.bounds;
    frame.origin.y = frame.size.height - kPagesLabelHeight;
    frame.size.height = kPagesLabelHeight;

    UILabel *pagesLabel = [[UILabel alloc] initWithFrame:frame];
    [pagesLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin)];
    [pagesLabel setTextAlignment:NSTextAlignmentCenter];
    [pagesLabel setTextColor:[UIColor whiteColor]];
    [pagesLabel setFont:[UIFont fontWithName:@"Helvetica" size:17.0f]];
    [pagesLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:pagesLabel];

    _pagesLabel = pagesLabel;

    [_pagesLabel setHidden:!_showPagesTip];
  }
  return _pagesLabel;
}

static CGFloat const kScrollPagePadding = 10.0f;
- (UIScrollView *)pageScrollView
{
  if (!_pageScrollView) {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[self _frameForPageScrollView]];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor blackColor];

    scrollView.contentSize = [self _contentSizeForPageScrollView];

    [self.view insertSubview:scrollView atIndex:0];
    _pageScrollView = scrollView;
  }
  return _pageScrollView;
}

- (NSMutableSet *)visiblePagesSet
{
  if (!_visiblePagesSet) {
    _visiblePagesSet = [NSMutableSet set];
  }
  return _visiblePagesSet;
}

- (NSMutableSet *)recycledPagesSet
{
  if (!_recycledPagesSet) {
    _recycledPagesSet = [NSMutableSet set];
  }
  return _recycledPagesSet;
}

- (id)_photoAtIndex:(NSUInteger)index
{
  return index < self.photos.count ? self.photos[index] : nil;
}

- (YAPhotoZoomingScrollView *)_displayedPageAtIndex:(NSUInteger)index
{
  for (YAPhotoZoomingScrollView *page in self.visiblePagesSet) {
    if (page.tag == index) return page;
  }
  return nil;
}

- (UIImage *)photoImageAtIndex:(NSUInteger)index
{
  id photo = [self _photoAtIndex:index];
  if ([photo isKindOfClass:[UIImage class]]) {
    return photo;
  } else if ([photo isKindOfClass:[NSURL class]]) {
    YAPhotoZoomingScrollView *zoomingScrollView = [self _displayedPageAtIndex:index];
    if (zoomingScrollView) {
      return zoomingScrollView.photoImage;
    } else {
      return [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[photo absoluteString]];
    }
  } else {
    return nil;
  }
}

#pragma mark - setter

- (void)setInitialPageIndex:(NSUInteger)pageIndex
{
  if (pageIndex >= self.totalPages) pageIndex = self.totalPages - 1;

  _initialPageIndex = pageIndex;
  _currentPageIndex = pageIndex;

  if (self.totalPages > 1
      && [self isViewLoaded]) {
    [self _setupPagesTip];
    [self.pageScrollView setContentOffset:[self _contentOffsetForPageAtIndex:pageIndex]
                                 animated:YES];
  }
}

- (void)setTotalPages:(NSUInteger)totalPages
{
  _totalPages = totalPages;
  if ([self isViewLoaded]) {
    [self _setupPagesTip];
    [self setInitialPageIndex:self.currentPageIndex];
    [self viewWillLayoutSubviews];
  }
}

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex
{
  _currentPageIndex = currentPageIndex;
  [self _setupPagesTip];
  [self.pageScrollView setContentOffset:[self _contentOffsetForPageAtIndex:currentPageIndex]];
}

- (void)setShowPagesTip:(BOOL)showPagesTip animated:(BOOL)flag
{
  _showPagesTip = showPagesTip;

  if ([self isViewLoaded]) {
    NSTimeInterval duration = flag ? .2f : 0.0f;
    [self.pagesLabel setAlpha:showPagesTip ? 0.0f : 1.0f];
    [UIView animateWithDuration:duration animations:^{
      [self.pagesLabel setAlpha:showPagesTip ? 1.0f : 0.0f];
    } completion:^(BOOL finished) {
      [self.pagesLabel setHidden:!showPagesTip];
      if (showPagesTip) [self _setupPagesTip];
    }];
  }
}

- (void)setShowPagesTip:(BOOL)showPagesTip
{
  [self setShowPagesTip:showPagesTip animated:NO];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  [self _displayPages];

  // Calculate current page
  CGRect visibleBounds = self.pageScrollView.bounds;
  NSInteger index = (NSInteger) (floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
  index = MAX(index, 0);
  index = MIN(index, self.totalPages - 1);

  _currentPageIndex = index;
  [self _setupPagesTip];
}

#pragma mark - Display

- (void)reloadCurrentPhotoPage
{
  YAPhotoZoomingScrollView *scrollView = [self _displayedPageAtIndex:self.currentPageIndex];
  [scrollView prepareForReuse];
  [self _layoutPage:scrollView atIndex:self.currentPageIndex];
}

- (void)_displayPages
{
  CGRect visibleBounds = self.pageScrollView.bounds;

  NSInteger iFirstIndex = floorf((CGRectGetMinX(visibleBounds) + kScrollPagePadding * 2) / CGRectGetWidth(visibleBounds));
	NSInteger iLastIndex = floorf((CGRectGetMaxX(visibleBounds) - kScrollPagePadding * 2 - 1) / CGRectGetWidth(visibleBounds));

  iFirstIndex = MAX(iFirstIndex, 0);
  iFirstIndex = MIN(iFirstIndex, self.totalPages - 1);

  iLastIndex = MAX(iLastIndex, 0);
  iLastIndex = MIN(iLastIndex, self.totalPages - 1);

  // Recycle no longer needed pages
  NSInteger pageIndex;
  for (YAPhotoZoomingScrollView *page in self.visiblePagesSet) {
    pageIndex = page.tag;
    if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
      [self.recycledPagesSet addObject:page];
      [page prepareForReuse];
      [page removeFromSuperview];
    }
  }
  [self.visiblePagesSet minusSet:self.recycledPagesSet];
  while (self.recycledPagesSet.count > 2) { // Only keep 2 recycled pages
    [self.recycledPagesSet removeObject:[self.recycledPagesSet anyObject]];
  }

  // Add missing pages
  for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
    if (![self _isDisplayingPageForIndex:index]) {

      if ([self.delegate respondsToSelector:@selector(photoBrowser:willDisplayPhotoAtPageIndex:)]) {
        [self.delegate photoBrowser:self willDisplayPhotoAtPageIndex:index];
      }

      // Add new page
      YAPhotoZoomingScrollView *page = [[YAPhotoZoomingScrollView alloc] init];
      if (_progressTintColor) [page.progressView setTintColor:_progressTintColor];
      page.photoZoomingDelegate = self;
      page.backgroundColor = [UIColor clearColor];
      page.opaque = YES;

      [self _layoutPage:page atIndex:index];
      [self.visiblePagesSet addObject:page];
      [self.pageScrollView addSubview:page];
    }
  }
}

- (void)_layoutPage:(YAPhotoZoomingScrollView *)page atIndex:(NSUInteger)index
{
  page.frame = [self _frameForPageAtIndex:index];
  page.tag = index;

  id photo = [self _photoAtIndex:index];
  if (photo
      && [photo isKindOfClass:[NSURL class]]) {
    page.photoURL = photo;
  } else {
    page.photoImage = photo;
  }
}

#pragma mark - setup

- (void)_setupPagesTip
{
  [self.pagesLabel setText:[NSString stringWithFormat:@"%d / %d", self.currentPageIndex + 1, self.totalPages]];
}

#pragma mark - opinion

- (BOOL)_isDisplayingPageForIndex:(NSUInteger)index
{
  for (YAPhotoZoomingScrollView *page in self.visiblePagesSet) {
    if (page.tag == index) return YES;
  }
  return NO;
}

#pragma mark - Size

- (CGRect)_frameForPageScrollView
{
  CGRect frame = self.view.bounds;
  frame.origin.x -= kScrollPagePadding;
  frame.size.width += (2 * kScrollPagePadding);
  return frame;
}

- (CGSize)_contentSizeForPageScrollView
{
  CGRect pageScrollViewFrame = [self _frameForPageScrollView];
  CGSize scrollContentSize = CGSizeMake(pageScrollViewFrame.size.width * self.totalPages,
                                        pageScrollViewFrame.size.height);
  return scrollContentSize;
}

- (CGPoint)_contentOffsetForPageAtIndex:(NSUInteger)index
{
  CGFloat pageWidth = self.pageScrollView.bounds.size.width;
  CGFloat newOffset = index * pageWidth;
  return CGPointMake(newOffset, 0);
}

- (CGRect)_frameForPageAtIndex:(NSUInteger)index
{
  CGRect bounds = self.pageScrollView.bounds;
  CGRect pageFrame = bounds;
  pageFrame.size.width -= (2 * kScrollPagePadding);
  pageFrame.origin.x = (bounds.size.width * index) + kScrollPagePadding;
  return pageFrame;
}

#pragma mark YAPhotoZoomingScrollView Delegate

- (void)photoZoomingScrollView:(YAPhotoZoomingScrollView *)scrollView
             singleTapDetected:(UITapGestureRecognizer *)tapGR
{
  if ([self.delegate respondsToSelector:@selector(photoBrowser:willDismissAtPageIndex:)]) {
    [self.delegate photoBrowser:self willDismissAtPageIndex:self.currentPageIndex];
  }
  [self _dismiss];
}

- (void)photoZoomingScrollView:(YAPhotoZoomingScrollView *)scrollView
             longPressDetected:(UILongPressGestureRecognizer *)longPressGR
{
  if ([self.delegate respondsToSelector:@selector(photoBrowser:longPressActionAtIndex:)]) {
    [self.delegate photoBrowser:self longPressActionAtIndex:self.currentPageIndex];
  }
}

- (void)photoZoomingScrollView:(YAPhotoZoomingScrollView *)scrollView
             willDownloadImage:(SDWebImageManager *)webImageManager
                   downloadURL:(NSURL *)URL
{
  if ([self.delegate respondsToSelector:@selector(photoBrowser:willDownloadImage:downloadURL:)]) {
    [self.delegate photoBrowser:self willDownloadImage:webImageManager downloadURL:URL];
  }
}

@end
