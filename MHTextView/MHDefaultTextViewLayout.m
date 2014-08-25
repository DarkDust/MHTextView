//
//  MHDefaultTextViewLayout.m
//  MHTextView
//
//  Created by Marc Haisenko on 20.07.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "MHDefaultTextViewLayout.h"

#import "MHTextView.h"
#import "MHTextViewFrame.h"

#import <CoreText/CoreText.h>


@implementation MHDefaultTextViewLayout

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    _numberOfColumns = 1;
    _columnGap = 10;
    
    return self;
}

- (void)setNumberOfColumns:(NSUInteger)numberOfColumns
{
    NSAssert(numberOfColumns > 0, @"Number of columns must not be 0!");
    _numberOfColumns = numberOfColumns;
}

- (NSArray *)framesWithTextViewBounds:(CGRect)bounds
{
    NSMutableArray *columns;
    CGRect columnRect;
    
    bounds.origin.x += _insets.left;
    bounds.origin.y += _insets.top;
    bounds.size.width -= _insets.left + _insets.right;
    bounds.size.height -= _insets.top + _insets.bottom;
    
    if (bounds.size.height <= 0 || bounds.size.width <= 0) {
        // Not enough size for any columns.
        return @[];
    }
    
    columnRect.origin.y = bounds.origin.y;
    columnRect.size.height = bounds.size.height;
    columnRect.size.width = (bounds.size.width - ((_numberOfColumns - 1) * _columnGap)) / _numberOfColumns;
    
    // TODO: We probably should test for sensible minimum width.
    // A column with a width of, say, 1px just doesn't make much sense.
    if (columnRect.size.width <= 0) {
        return @[];
    }
    
    columns = [NSMutableArray array];

    for (NSUInteger i = 0; i < _numberOfColumns; ++i) {
        MHTextViewFrame *frame;
        
        columnRect.origin.x = i * (columnRect.size.width + _columnGap);
        
        frame = [[MHTextViewFrame alloc] initWithFrame:columnRect numberOfLines:0];
        [columns addObject:frame];
    }
    
    return columns;
}

- (CGSize)intrinsicTextViewSize:(MHTextView *)textView
{
    CGRect bounds;
    
    bounds = textView.bounds;
    
    if (self.numberOfColumns == 1 && textView.exclusionViews.count == 0) {
        CTFramesetterRef framesetter;
        NSUInteger textLength;
        CGSize result;
        
        textLength = [textView.attributedText length];
        if (textLength == 0) {
            return CGSizeMake(bounds.size.width, 0);
        }
        
        framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)textView.attributedText);

        result = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(bounds.size.width, 0), NULL);
        
        CFRelease(framesetter);
        
        return result;
        
    } else {
        return bounds.size;
    }
}

@end
