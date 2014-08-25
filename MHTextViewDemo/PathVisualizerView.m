//
//  PathVisualizerView.m
//  MHTextViewDemo
//
//  Created by Marc Haisenko on 18.08.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "PathVisualizerView.h"

@implementation PathVisualizerView

- (void)setPaths:(NSArray *)paths
{
    _paths = [paths copy];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIColor *baseColor;
    
    baseColor = [UIColor greenColor];
    
    [[baseColor colorWithAlphaComponent:0.5] setFill];
    [baseColor setStroke];
    
    for (UIBezierPath *path in self.paths) {
        [path fill];
        [path stroke];
    }
}

@end
