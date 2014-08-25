//
//  MHTextViewLayout.h
//  MHTextView
//
//  Created by Marc Haisenko on 20.07.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHTextView;


/** Layout specifications for an MHTextView.
 */
@protocol MHTextViewLayout <NSObject>

/** Returns the frames for the given MHTextView bounds.
 
 Returns an array of @c MHTextViewFrame @c instances.
 */
- (NSArray *)framesWithTextViewBounds:(CGRect)bounds;

@optional

/** Returns the required size of the text view.

 The text view calls this method when it was asked for its @c intrinsicContentSize @c.
 Depending on the layout's capabilities and properties, it should either return
 an appropriate size or the text view's @c bounds @c.
 */
- (CGSize)intrinsicTextViewSize:(MHTextView *)textView;

@end
