//
//  MHDefaultTextViewLayout.h
//  MHTextView
//
//  Created by Marc Haisenko on 20.07.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MHTextView/MHTextViewLayout.h>

/** A simple default text view layout.
 
 This layout has limited support for calculating the @c intrinsicContentSize @c
 (via @c intrinsicTextViewSize: @c).

 It assumes a fixed width and calculates the required height, but only if
 @c numberOfColumns @c is 1 and the text view has no @c exclusionViews @c.

 If either the @c numberOfColumns @c is greater than 1 or the text view has
 @c exclusionViews @c, simply the current text view frame is returned as the
 @c intrinsicTextViewSize: @c.
 */
@interface MHDefaultTextViewLayout : NSObject <MHTextViewLayout>

/** The number of columns the text view is divided into.
 
 Defaults to 1. Must not be 0.
 */
@property(assign, nonatomic) NSUInteger numberOfColumns;

/** Insets from the text view edges.
 
 Defaults to UIEdgeInsetsZero.
 */
@property(assign) UIEdgeInsets insets;

/** Distance between two columns.
 
 Defaults to 10.
 */
@property(assign) CGFloat columnGap;

@end
