//
//  MHTextView.m
//  MHTextView
//
//  Created by Marc Haisenko on 20.07.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "MHTextView.h"
#import "MHTextView+Drawing.h"

#import "MHDefaultTextViewLayout.h"
#import "MHTextViewFrame.h"

#import <CoreText/CoreText.h>


NSString * const MHTextViewJustifiedAttributeName = @"MHTextViewJustifiedAttribute";


@implementation MHTextView
{
    /** The frames to render in, as returned by the layout.
     
     Instances of MHTextViewFrame.
     */
    NSArray *_layoutFrames;
    
    /** The frames to render, as returned by the framesetter.
     
     Instances of CTFrame
     */
    NSArray *_textFrames;
    
    /** Text frames for measurements.
     
     We need those to get the needed line widths in a frame when using exclusion
     views when using custom justification.
     
     When not using custom justification, let this point to the object as _textFrames.
     
     Instances of CTFrame
     */
    NSArray *_guideTextFrames;
    
    /** Path where we are not allowed to draw into.
     */
    UIBezierPath *_exclusionPath;
}


#pragma mark -
#pragma mark Object lifecycle

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    
    [self private_init];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self private_init];
    
    return self;
}

- (void)private_init
{
    _layout = [[MHDefaultTextViewLayout alloc] init];
    _ellipsisOnLastVisibleLine = YES;
    _useCustomJustify = YES;
}

- (void)dealloc
{
    for (UIView *oldView in _exclusionViews) {
        [oldView removeObserver:self forKeyPath:@"center"];
        [oldView removeObserver:self forKeyPath:@"bounds"];
    }
}


#pragma mark -
#pragma mark Public methods

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if ([_attributedText isEqual:attributedText]) {
        return;
    }
    
    _attributedText = [attributedText copy];
    
    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

- (void)setLayout:(id<MHTextViewLayout>)layout
{
    NSAssert(layout != nil, @"Layout must not be nil!");
    
    _layout = layout;
    
    [self setNeedsLayout];
}

- (void)setEllipsisOnLastVisibleLine:(BOOL)ellipsisOnLastColumn
{
    if (_ellipsisOnLastVisibleLine == ellipsisOnLastColumn) {
        return;
    }
    
    _ellipsisOnLastVisibleLine = ellipsisOnLastColumn;
    
    [self setNeedsDisplay];
}

- (void)setUseCustomJustify:(BOOL)useCustomJustify
{
    if (_useCustomJustify == useCustomJustify) {
        return;
    }
    
    _useCustomJustify = useCustomJustify;
    
    [self setNeedsLayout];
}

- (void)setTextDistribution:(MHTextViewTextDistribution)textDistribution
{
    if (_textDistribution == textDistribution) {
        return;
    }
    
    _textDistribution = textDistribution;
    
    [self setNeedsLayout];
}

- (void)setExclusionViews:(NSArray *)exclusionViews
{
    for (UIView *oldView in _exclusionViews) {
        [oldView removeObserver:self forKeyPath:@"center"];
        [oldView removeObserver:self forKeyPath:@"bounds"];
    }
    
    _exclusionViews = [exclusionViews copy];

    for (UIView *newView in _exclusionViews) {
        
        [newView addObserver:self
                  forKeyPath:@"center"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
        
        [newView addObserver:self
                  forKeyPath:@"bounds"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
    }
    
    [self setNeedsLayout];
}

- (void)setExclusionViewMargins:(UIEdgeInsets)exclusionViewMargins
{
    if (UIEdgeInsetsEqualToEdgeInsets(_exclusionViewMargins, exclusionViewMargins)) {
        return;
    }
    
    _exclusionViewMargins = exclusionViewMargins;
    
    [self setNeedsLayout];
}

- (void)invalidateLayout
{
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _layoutFrames = [self.layout framesWithTextViewBounds:self.bounds];
    
    // We probably want to decouple the query-columns from the
    // calculate exclusion paths phase so we can update the
    // later without needing to re-run the former.

    [self private_createFrames];
    [self setNeedsDisplay];
}

- (CGSize)intrinsicContentSize
{
    if ([self.layout respondsToSelector:@selector(intrinsicTextViewSize:)]) {
        return [self.layout intrinsicTextViewSize:self];
    } else {
        return self.bounds.size;
    }
}

- (void)drawRect:(CGRect)rect
{
    [self private_drawTextFrames:_textFrames guideFrames:_guideTextFrames];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // A observed view has changed its frame, need to update.
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark Private methods

- (NSArray *)private_rectsFromExclusionViews
{
    NSMutableArray *rects;
    
    if ([self.exclusionViews count] == 0) {
        return nil;
    }
    
    rects = [NSMutableArray array];
    
    for (UIView *view in self.exclusionViews) {
        CGRect viewFrame;
        
        viewFrame = view.bounds;
        viewFrame = [view convertRect:viewFrame toView:nil];
        viewFrame = [self convertRect:viewFrame fromView:nil];

        [rects addObject:[NSValue valueWithCGRect:viewFrame]];
    }
    
    return rects;
}

- (void)private_createFrames
{
    if (self.useCustomJustify) {
        // Prepare the attributed string: replace NSTextAlignmentJustified with
        // NSTextAlignmentNatural and add our custom attribute instead.
        NSAttributedString *converted;
        CGFloat height = 0;
        
        converted = [self private_convertAttributedString:self.attributedText];
        
        _textFrames = [self private_framesWithAttributedString:converted
                                                    heightUsed:&height];
        
        _guideTextFrames = [self private_framesWithAttributedString:self.attributedText
                                                  constrainedHeight:height];
    } else {
        _textFrames = [self private_framesWithAttributedString:self.attributedText
                                                    heightUsed:NULL];
        _guideTextFrames = _textFrames;
    }
}

- (NSArray *)private_framesWithAttributedString:(NSAttributedString *)attributed
                                     heightUsed:(CGFloat *)heightUsed
{
    CGRect bounds;
    NSArray *result;
    
    bounds = self.bounds;
    
    switch (self.textDistribution) {
            
        case MHTextViewTextDistributionTopToBottom:
            if (_layoutFrames.count > 1) {
                result = [self private_probe:attributed
                                   maxHeight:bounds.size.height
                                  bestHeight:heightUsed];
                break;
            } else {
                // When we only have 0 or 1 frame we don't need the expensive
                // route, we can immediately fall back to the default case.
                // !!!Fall through!!!
            }

        case MHTextViewTextDistributionDefault:
            result = [self private_framesWithAttributedString:attributed
                                            constrainedHeight:bounds.size.height];
            
            if (heightUsed) {
                *heightUsed = bounds.size.height;
            }
            break;

        default:
            NSAssert(NO, @"Invalid text distribution value!");
            result = nil;
            break;
    }
    
    return result;
}

// This is the start of a binary search for the optimal height of an additional
// exclusion path that forces the view to assume a top-to-bottom layout.
//
// Usually, CoreText fills each CTFrame completely from top to bottom. But when
// we want to have the text stick to the top and not the left, we need to
// restrict the space into which CoreText can render until we've found the right
// height.
//
// This is expensive, of course. If you have an idea on how to improve this
// please also see my StackOverflow question regarding this task:
//
// http://stackoverflow.com/questions/25369548/distribute-text-top-to-bottom-instead-of-left-to-right
//
- (NSArray *)private_probe:(NSAttributedString *)attributedString
                 maxHeight:(CGFloat)maxHeight
                bestHeight:(CGFloat *)bestHeight
{
    NSArray *result;
    
    // First, check whether the text is short enough to actually need any
    // distributing. If it's too long anyway we can skip the binary search.
    result = [self private_framesWithAttributedString:attributedString constrainedHeight:maxHeight];
    if (result.count > 0) {
        CTFrameRef lastFrame;
        CFRange range;
        
        lastFrame = (__bridge CTFrameRef)result.lastObject;
        range = CTFrameGetVisibleStringRange(lastFrame);
        if (range.location + range.length < attributedString.length) {
            // Even the maximum height is not enough to display the whole text,
            // so all frames are now full. Nothing else to do.
            if (bestHeight) {
                *bestHeight = maxHeight;
            }
        } else {
            // We want to try finding a better height.
            result = [self private_probe:attributedString
                               minHeight:0
                               maxHeight:maxHeight
                              bestHeight:bestHeight];
            
        }
    } else {
        // No result? Maybe because there was no text.
        if (bestHeight) {
            *bestHeight = maxHeight;
        }
    }
    
    return result;
}

// The actual binary search for the top-to-bottom text distribution.
- (NSArray *)private_probe:(NSAttributedString *)attributedString
                 minHeight:(CGFloat)minHeight
                 maxHeight:(CGFloat)maxHeight
                bestHeight:(CGFloat *)bestHeight
{
    CGFloat middle;
    NSArray *result;
    
    if (maxHeight - minHeight == 1) {
        // Found the border.
        if (bestHeight) {
            *bestHeight = maxHeight;
        }

        return [self private_framesWithAttributedString:attributedString constrainedHeight:maxHeight];
    }
    
    middle = round((maxHeight + minHeight) / 2);
    
    result = [self private_framesWithAttributedString:attributedString constrainedHeight:middle];
    if (result.count > 0) {
        CTFrameRef lastFrame;
        CFRange range;
        
        lastFrame = (__bridge CTFrameRef)result.lastObject;
        range = CTFrameGetVisibleStringRange(lastFrame);
        if (
            (range.location + range.length) < attributedString.length
            && result.count == _layoutFrames.count
        ) {
            // Not enough space to show the text.
            return [self private_probe:attributedString
                             minHeight:middle
                             maxHeight:maxHeight
                            bestHeight:bestHeight];
        } else {
            // There's still room we can take up.
            return [self private_probe:attributedString
                             minHeight:minHeight
                             maxHeight:middle
                            bestHeight:bestHeight];
        }
    }
    
    return result;
}

- (NSArray *)private_framesWithAttributedString:(NSAttributedString *)attributed constrainedHeight:(CGFloat)height
{
    CTFramesetterRef framesetter;
    NSMutableArray *frames;
    NSUInteger textPos = 0;
    NSUInteger textLength;
    NSArray *exclusionRects;
    NSMutableArray *clippingPaths;
    NSDictionary *frameAttributes;
    CGRect bounds;
    
    textLength = [attributed length];
    if (textLength == 0 || height <= 0) {
        // No text, nothing to do.
        return nil;
    }
    
    // Gather the exclusionViews.
    clippingPaths = [NSMutableArray array];
    exclusionRects = [self private_rectsFromExclusionViews];
    for (NSValue *rectValue in exclusionRects) {
        UIBezierPath *path;
        
        path = [UIBezierPath bezierPathWithRect:[rectValue CGRectValue]];
        
        [clippingPaths addObject:@{
            (id)kCTFramePathClippingPathAttributeName : (id)[[self private_flipYInPath:path] CGPath]
        }];
    }
    
    // Gather the delegate's exclusionPaths.
    if ([self.delegate respondsToSelector:@selector(exclusionPathsForMHTextView:)]) {
        for (UIBezierPath *path in [self.delegate exclusionPathsForMHTextView:self]) {
            [clippingPaths addObject:@{
                (id)kCTFramePathClippingPathAttributeName : (id)[[self private_flipYInPath:path] CGPath]
            }];
        }
    }
    
    // Add an additional exclusion path for the constrained height. This is used
    // for the top-to-bottom text distribution.
    bounds = self.bounds;
    if (height < bounds.size.height) {
        CGRect pathRect;
        CGPathRef path;
        
        pathRect = bounds;
        pathRect.size.height -= height;
        path = CGPathCreateWithRect(pathRect, NULL);
        
        [clippingPaths addObject:@{
            (id)kCTFramePathClippingPathAttributeName : (__bridge id)path
        }];
        
        CFRelease(path);
    }

    // Attributes for CTFramesetterCreateFrame.
    frameAttributes = @{
        (id)kCTFrameClippingPathsAttributeName : clippingPaths
    };
    
    framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    frames = [NSMutableArray array];

    // Create the frames.
    for (MHTextViewFrame *layoutFrame in _layoutFrames) {
        CTFrameRef textFrame;
        UIBezierPath *path;
        
        path = [self private_flipYInPath:layoutFrame.path];
        
        textFrame = CTFramesetterCreateFrame(
            framesetter,
            CFRangeMake(textPos, textLength - textPos),
            [path CGPath],
            (CFDictionaryRef)frameAttributes
        );

        textPos += CTFrameGetVisibleStringRange(textFrame).length;
        [frames addObject:CFBridgingRelease(textFrame)];
        
        if (textPos >= textLength) {
            // We've reached the end of the text. No use trying to lay out
            // any more frames.
            break;
        }
    }
    
    CFRelease(framesetter);
    
    return frames;
}

// The coordinates used for rendering Core Text are flipped. So we need to
// flip the paths to render in as well.
- (UIBezierPath *)private_flipYInPath:(UIBezierPath *)path
{
    UIBezierPath *newPath;
    
    newPath = [path copy];
    [newPath applyTransform:CGAffineTransformMakeScale(1, -1)];
    [newPath applyTransform:CGAffineTransformMakeTranslation(0, CGRectGetMaxY(self.bounds))];
    
    return newPath;
}

// We can't simply use the font's advances because we don't get kerning that way.
// So we really want to let the CTFramesetter do the necessary hard work, but
// in a non-justified manner. We need to change all the paragraphs with
// NSTextAlignmentJustified to NSTextAlignmentNatural and mark them with our own
// attribute so we can later identify these ranges as needing to be justified.
- (NSAttributedString *)private_convertAttributedString:(NSAttributedString *)string
{
    NSMutableAttributedString *result;
    
    result = [string mutableCopy];
    
    [string
        enumerateAttributesInRange:NSMakeRange(0, [string length])
        options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
        usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            NSParagraphStyle *paragraph;
            
            paragraph = [attrs objectForKey:NSParagraphStyleAttributeName];
            if ([paragraph alignment] == NSTextAlignmentJustified) {
                NSMutableParagraphStyle *mutablePara;
                NSMutableDictionary *newAttrs;
                
                mutablePara = [paragraph mutableCopy];
                [mutablePara setAlignment:NSTextAlignmentNatural];
                
                newAttrs = [attrs mutableCopy];
                [newAttrs setObject:mutablePara forKey:NSParagraphStyleAttributeName];
                [newAttrs setObject:@(YES) forKey:MHTextViewJustifiedAttributeName];
                
                [result setAttributes:newAttrs range:range];
            }
        }
    ];
    
    return result;
}

@end
