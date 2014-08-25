//
//  MHTextView.h
//  MHTextView
//
//  Created by Marc Haisenko on 20.07.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MHTextView/MHTextViewFrame.h>
#import <MHTextView/MHTextViewLayout.h>


@class MHTextView;


/** How text lines should be distributed in the text view's frames.
 */
typedef NS_ENUM(NSInteger, MHTextViewTextDistribution) {
    /** Default text line distribution.
     
     The view tries to fill each frame completely from top to bottom before
     proceeding to the next frame.
     */
    MHTextViewTextDistributionDefault,

    /** Top-to-bottom text line distribution across all frames.
     
     The view tries to fill all frames in an evenly manner from top to bottom,
     similar to CSS3's column fill pattern.
     
     @note This option is potentially expensive, use with care. You might want
           to avoid using this option with text views that have a large height.
     */
    MHTextViewTextDistributionTopToBottom,
};


/** Delegate protocol for the MHTextView.
 */
@protocol MHTextViewDelegate <NSObject>
@optional

/** Allows the delegate to provide an array of @c UIBezierPath @c objects into
 which the text view is not allowed to render.
 
 The paths should be in the coordinate space of the text view.
 
 @param textView The text view to return the exclusion paths for.
 @return An array of @c UIBezierPath @c objects.
 */
- (NSArray *)exclusionPathsForMHTextView:(MHTextView *)textView;

@end


/** A versatile text view.
 */
@interface MHTextView : UIView


/** Delegate for the text view.
 */
@property(assign, nonatomic) IBOutlet id<MHTextViewDelegate> delegate;

/** The attributed string to be displayed.
 */
@property(copy, nonatomic) NSAttributedString *attributedText;

/** Layout for this text view.
 
 Defaults to an instance of @c MHDefaultTextViewLayout @c.
 
 Must not be @c nil @c.
 */
@property(retain, nonatomic) id<MHTextViewLayout> layout;

/** Whether to truncate the last line of the last column with ellipsis.
 
 If YES is returned, the last line of the last column will
 truncate the text with an ellipsis (…) if the text would
 overflow.
 
 Defaults to YES.
 */
@property(assign, nonatomic) BOOL ellipsisOnLastVisibleLine;

/** Whether to use the system's justify alignment or our custom
 implementation.
 
 When set to YES, all paragraphs with an alignment of
 NSTextAlignmentJustified are set using a custom justification
 implementation.
 
 Defaults to YES.
 */
@property(assign, nonatomic) BOOL useCustomJustify;

/** How to distribute text lines in frames.
 
 Defaults to @c MHTextViewTextDistributionDefault @c.
 */
@property(assign, nonatomic) MHTextViewTextDistribution textDistribution;

/** An array of @c UIView @c objects whose frames are treated as exclusion
 paths.
 
 You can specify views that may be displayed in front of the text view. The text
 view treats the frames of these views (converted into the text view's
 coordinate system) like exclusion paths.
 
 Defaults to @c nil @c.
 */
@property(copy, nonatomic) NSArray *exclusionViews;

/** Margins that are added to the frames of exclusion views.
 
 When calculating the exclusion path for an exclusion view, the exclusion
 margin is used to enlargen (positive values) or shrink (negative values)
 those frames.
 
 Defaults to @c UIEdgeInsetsZero @c.
 
 @see exclusionViews
 */
@property(assign, nonatomic) UIEdgeInsets exclusionViewMargins;

/** The layout has changed, the view needs to relayout.
 
 A layout or other object may inform the text view that the layout has changed
 and a relayout is necessary (for example, the number of columns or insets of a
 layout have changed).
 
 You also need to call this method if the delegate wants to inform the text view
 that the exclusion paths have changed.
 */
- (void)invalidateLayout;

@end


// For internal use only!
extern NSString * const MHTextViewJustifiedAttributeName;

