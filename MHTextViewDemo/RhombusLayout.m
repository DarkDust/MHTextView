//
//  RhombusLayout.m
//  MHTextViewDemo
//
//  Created by Marc Haisenko on 19.08.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "RhombusLayout.h"

@implementation RhombusLayout

- (NSArray *)framesWithTextViewBounds:(CGRect)bounds
{
    static const CGFloat kDistance = 20;
    CGFloat columnWidth;
    CGFloat x1, x2, x3, x4, x5, x6;
    CGFloat y1, y2;
    MHTextViewFrame *left, *right;
    UIBezierPath *path;
    
    columnWidth = (CGRectGetWidth(bounds) - 2*kDistance) / 3;
    
    x1 = CGRectGetMinX(bounds);
    x2 = x1 + columnWidth;
    x3 = x2 + kDistance;
    x4 = x3 + columnWidth;
    x5 = x4 + kDistance;
    x6 = x5 + columnWidth;
    
    y1 = CGRectGetMinY(bounds);
    y2 = CGRectGetMaxY(bounds);
    
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(x1, y1)];
    [path addLineToPoint:CGPointMake(x3, y2)];
    [path addLineToPoint:CGPointMake(x4, y2)];
    [path addLineToPoint:CGPointMake(x2, y1)];
    [path closePath];
    left = [[MHTextViewFrame alloc] initWithPath:path numberOfLines:0];
    
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(x3, y1)];
    [path addLineToPoint:CGPointMake(x5, y2)];
    [path addLineToPoint:CGPointMake(x6, y2)];
    [path addLineToPoint:CGPointMake(x4, y1)];
    [path closePath];
    right = [[MHTextViewFrame alloc] initWithPath:path numberOfLines:0];
    
    return @[ left, right ];
}

@end
