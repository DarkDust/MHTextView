//
//  NarrowMiddleColumnLayout.m
//  MHTextViewDemo
//
//  Created by Marc Haisenko on 17.08.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "NarrowMiddleColumnLayout.h"

static const CGFloat kColumnGap = 16;

@implementation NarrowMiddleColumnLayout

- (NSArray *)framesWithTextViewBounds:(CGRect)bounds
{
    CGFloat baseWidth;
    CGRect left, middle, right;
    MHTextViewFrame *leftFrame, *middleFrame, *rightFrame;
    
    // The column widths are distributed 2-1-2.
    
    baseWidth = floor((bounds.size.width - 2*kColumnGap) / 5);
    
    left.origin = bounds.origin;
    left.size.width = baseWidth * 2;
    left.size.height = bounds.size.height;

    right.origin.x = CGRectGetMaxX(bounds) - (baseWidth * 2);
    right.origin.y = CGRectGetMinY(bounds);
    right.size.width = baseWidth * 2;
    right.size.height = bounds.size.height;

    middle.origin.x = CGRectGetMaxX(left) + kColumnGap;
    middle.origin.y = CGRectGetMinY(bounds);
    middle.size.width = (CGRectGetMinX(right) - kColumnGap) - middle.origin.x;
    middle.size.height = bounds.size.height;
    
    leftFrame = [[MHTextViewFrame alloc] initWithFrame:left numberOfLines:0];
    middleFrame = [[MHTextViewFrame alloc] initWithFrame:middle numberOfLines:0];
    rightFrame = [[MHTextViewFrame alloc] initWithFrame:right numberOfLines:0];
    
    return @[ leftFrame, middleFrame, rightFrame ];
}

@end
