//
//  DemoViewController.m
//  MHTextViewDemo
//
//  Created by Marc Haisenko on 17.08.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "DemoViewController.h"


@implementation DemoViewController


- (NSString *)loadStringFile:(NSString *)name
{
    NSURL *url;
    
    url = [[NSBundle mainBundle] URLForResource:name withExtension:@"txt"];
    
    return [NSString stringWithContentsOfURL:url
                                    encoding:NSUTF8StringEncoding
                                       error:NULL];
}


@end
