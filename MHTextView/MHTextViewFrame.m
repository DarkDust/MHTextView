//
//  MHTextViewColumn.m
//  MHTextView
//
//  Created by Marc Haisenko on 20.07.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "MHTextViewFrame.h"


@implementation MHTextViewFrame

- (instancetype)initWithPath:(UIBezierPath *)path
               numberOfLines:(NSUInteger)numberOfLines
{
    self = [super init];
    if (!self) return nil;

    _path = [path copy];
    _numberOfLines = numberOfLines;
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                numberOfLines:(NSUInteger)numberOfLines
{
    return [self initWithPath:[UIBezierPath bezierPathWithRect:frame]
                numberOfLines:numberOfLines];
}

@end
