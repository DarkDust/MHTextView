//
//  FineLine.m
//  MHTextViewDemo
//
//  Created by Marc Haisenko on 17.08.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "FineLine.h"

@implementation FineLine

- (void)drawRect:(CGRect)rect
{
    CGRect bounds;
    CGPoint p[2];
    CGFloat height;
    CGContextRef context;
    
    bounds = self.bounds;
    height = 1.0/self.contentScaleFactor;
    context = UIGraphicsGetCurrentContext();
    
    p[0].x = CGRectGetMinX(bounds);
    p[0].y = CGRectGetMaxY(bounds) - height/2;
    p[1].x = CGRectGetMaxX(bounds);
    p[1].y = p[0].y;
    
    if (self.lineColor) {
        [self.lineColor set];
    } else {
        [[UIColor blackColor] set];
    }
    
    CGContextSetLineWidth(context, height);
    CGContextStrokeLineSegments(context, p, 2);
}

@end
