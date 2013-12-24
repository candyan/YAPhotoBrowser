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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [[SDImageCache sharedImageCache] clearDisk];
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
                          [NSURL URLWithString:@"http://img3.douban.com/view/commodity_review/large/public/p26913.jpg"],
                          [NSURL URLWithString:@"http://img3.douban.com/view/commodity_review/large/public/p26915.jpg"]];
  YAPhotoBrowser *photoBrowser = [[YAPhotoBrowser alloc] initWithPhotoArray:photoArray];
  [self presentViewController:photoBrowser
                     animated:YES
                   completion:nil];
}
@end
