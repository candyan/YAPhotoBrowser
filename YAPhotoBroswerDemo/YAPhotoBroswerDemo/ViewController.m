//
//  ViewController.m
//  YAPhotoBroswerDemo
//
//  Created by liuyan on 13-12-23.
//  Copyright (c) 2013年 liuyan. All rights reserved.
//

#import "ViewController.h"
#import "YAPhotoBrowser.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

@interface ViewController ()<YAPhotoBrowserDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  [[SDImageCache sharedImageCache] clearDisk];

  UIButton *presentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, 150, 150)];
  [presentButton setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin
                                      | UIViewAutoresizingFlexibleLeftMargin
                                      | UIViewAutoresizingFlexibleRightMargin)];
  [presentButton addTarget:self
                    action:@selector(handlePresentButtonTapAction:)
          forControlEvents:UIControlEventTouchUpInside];

  [presentButton setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), presentButton.center.y)];
  [presentButton setImageWithURL:[NSURL URLWithString:@"http://img3.douban.com/view/status/raw/public/b3f5110ae68a375.jpg"]
                        forState:UIControlStateNormal];

  [self.view addSubview:presentButton];

  UIButton *presentFromViewButton = [[UIButton alloc] initWithFrame:presentButton.frame];
  [presentFromViewButton setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin
                                              | UIViewAutoresizingFlexibleLeftMargin
                                              | UIViewAutoresizingFlexibleRightMargin)];

  CGRect frame = presentButton.frame;
  frame.origin.y = 250;
  [presentFromViewButton setFrame:frame];

  [presentFromViewButton setImageWithURL:[NSURL URLWithString:@"http://img3.douban.com/view/status/raw/public/b3f5110ae68a375.jpg"]
                        forState:UIControlStateNormal];
  [presentFromViewButton addTarget:self
                            action:@selector(handlePresentWithViewButtonTapAction:)
                  forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:presentFromViewButton];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handlePresentButtonTapAction:(id)sender
{
  NSArray *photoArray = @[[NSURL URLWithString:@"http://img3.douban.com/view/status/raw/public/b3f5110ae68a375.jpg"],
                          [NSURL URLWithString:@"http://img3.douban.com/view/photo/photo/public/p2167975963.jpg"],
                          [NSURL URLWithString:@"http://img3.douban.com/view/photo/photo/public/p2167975970.jpg"]];
  YAPhotoBrowser *photoBrowser = [[YAPhotoBrowser alloc] initWithPhotoArray:photoArray];
  photoBrowser.delegate = self;
  [self presentViewController:photoBrowser
                     animated:YES
                   completion:nil];
}

- (IBAction)handlePresentWithViewButtonTapAction:(id)sender
{
  NSArray *photoArray = @[[NSURL URLWithString:@"http://img3.douban.com/view/status/raw/public/b3f5110ae68a375.jpg"],
                          [NSURL URLWithString:@"http://img3.douban.com/view/photo/photo/public/p2167975963.jpg"],
                          [NSURL URLWithString:@"http://img3.douban.com/view/photo/photo/public/p2167975970.jpg"]];
  YAPhotoBrowser *photoBrowser = [[YAPhotoBrowser alloc] initWithPhotoArray:photoArray
                                                           animatedFromView:sender];
  photoBrowser.delegate = self;
  [self presentViewController:photoBrowser
                     animated:YES
                   completion:nil];
}

#pragma mark - PhotoBrowser Delegate

- (void)photoBrowser:(YAPhotoBrowser *)photoBrowser longPressActionAtIndex:(NSUInteger)index
{
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Save", nil];
  [actionSheet showInView:self.view];
}

@end
