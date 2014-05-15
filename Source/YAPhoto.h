//
//  YAPhoto.h
//  YAPhotoBroswerDemo
//
//  Created by liuyan on 14-5-15.
//  Copyright (c) 2014年 liuyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAPhoto : NSObject

@property (nonatomic, strong) UIImage *displayPhoto;
@property (nonatomic, strong, readonly) NSURL *photoURL;
@property (nonatomic, strong, readonly) UIImage *placeholderPhoto;

- (instancetype)initWithPhoto:(UIImage *)photo;
- (instancetype)initWithURL:(NSURL *)url placeholder:(UIImage *)placeholder;

@end
