//
//  YERecordProcessView.m
//  YERecordingVideoDemo
//
//  Created by yongen on 17/3/17.
//  Copyright © 2017年 yongen. All rights reserved.
//

#import "YERecordProcessView.h"

@interface YERecordProcessView ()

@property (nonatomic, assign) CGPoint circleCenter;
@property (nonatomic, assign) CGFloat circleRadius;

@end

@implementation YERecordProcessView

- (instancetype)initWithCenter:(CGPoint)center radius:(CGFloat)radius{
    if (self = [super init]) {
        self.circleCenter = center;
        self.circleRadius = radius;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint center = self.circleCenter;
    CGFloat radius = self.circleRadius;
    CGFloat startA = -M_PI_2;//圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * self.progress;//圆终点位置
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    CGContextSetLineWidth(context, lineWith * 0.5);
    [[UIColor purpleColor] setStroke];
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
    
}


@end
