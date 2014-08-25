//
//  MHTextViewColumn.h
//  MHTextView
//
//  Created by Marc Haisenko on 20.07.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHTextViewFrame : NSObject

/** The frame path.
 */
@property(readonly) UIBezierPath *path;

/** How many lines to display in this column.
 
 Specifies how many lines of text should be printed in
 this column at most.
 
 The value 0 represents no limit.
 */
@property(readonly) NSUInteger numberOfLines;


/** Designated initializer.
 */
- (instancetype)initWithPath:(UIBezierPath *)path
               numberOfLines:(NSUInteger)numberOfLines;

/** Convenience initializer.
 */
- (instancetype)initWithFrame:(CGRect)frame
                numberOfLines:(NSUInteger)numberOfLines;

@end
