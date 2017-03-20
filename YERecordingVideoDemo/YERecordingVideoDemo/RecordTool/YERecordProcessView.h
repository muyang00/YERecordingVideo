//
//  YERecordProcessView.h
//  YERecordingVideoDemo
//
//  Created by yongen on 17/3/17.
//  Copyright © 2017年 yongen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define lineWith 5
@interface YERecordProcessView : UIView

@property (nonatomic, assign) CGFloat progress;
- (instancetype)initWithCenter:(CGPoint)center radius:(CGFloat)radius;

@end
