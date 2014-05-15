//
//  YAPhoto.m
//  YAPhotoBroswerDemo
//
//  Created by liuyan on 14-5-15.
//  Copyright (c) 2014年 Douban Inc. All rights reserved.
//

#import "YAPhoto.h"

@implementation YAPhoto

#pragma mark - init

- (instancetype)initWithPhoto:(UIImage *)photo
{
  self = [super init];
  if (self) {
    _displayPhoto = photo;
  }
  return self;
}

- (instancetype)initWithURL:(NSURL *)url placeholder:(UIImage *)placeholder
{
  self = [super init];
  if (self) {
    _photoURL = url;
    _placeholderPhoto = placeholder;
  }
  return self;
}

@end
