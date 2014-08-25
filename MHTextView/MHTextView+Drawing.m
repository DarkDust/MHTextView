//
//  MHTextView+Drawing.m
//  MHTextView
//
//  Created by Marc Haisenko on 23.07.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "MHTextView.h"

#import <CoreText/CoreText.h>


@implementation MHTextView (Drawing)

- (void)private_drawTextFrames:(NSArray *)textFrames guideFrames:(NSArray *)guideFrames
{
    CGContextRef context;

    NSAssert([textFrames count] == [guideFrames count], @"Frame number mismatch!");
    
    context = UIGraphicsGetCurrentContext();

    // Flip the coordinate system (Core Text is using OS X style coordinates).
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    for (NSUInteger index = 0; index < [textFrames count]; ++index) {
        CTFrameRef frame;
        CTFrameRef guide;
        BOOL isLastFrame;
        
        frame = (__bridge CTFrameRef)textFrames[index];
        guide = (__bridge CTFrameRef)guideFrames[index];
        isLastFrame = (index == [textFrames count] - 1);

        if (!self.useCustomJustify && (!self.ellipsisOnLastVisibleLine || !isLastFrame)) {
            // That's the easy way: let Core Text do all the
            // work.
            CGAffineTransform savedMatrix;
            CGPoint savedPoint;
            
            // Save context properties that CTLineDraw is modifying but
            // not restoring.
            savedMatrix = CGContextGetTextMatrix(context);
            savedPoint = CGContextGetTextPosition(context);
            
            CTFrameDraw(frame, context);
            
            // Restore the saved properties.
            CGContextSetTextMatrix(context, savedMatrix);
            CGContextSetTextPosition(context, savedPoint.x, savedPoint.y);
            
        } else {
            // That's the hard way: do the drawing manually.
            [self private_drawFrame:frame
                              guide:guide
                          inContext:context
                        isLastFrame:isLastFrame];
        }
    }
}

- (void)private_drawFrame:(CTFrameRef)frame guide:(CTFrameRef)guide inContext:(CGContextRef)context isLastFrame:(BOOL)lastFrame
{
    CFArrayRef lines;
    CFArrayRef guideLines;
    CFIndex count;
    CGRect frameBounds;
    
    // Get the lines that make up the frame.
    lines = CTFrameGetLines(frame);
    guideLines = CTFrameGetLines(guide);
    count = CFArrayGetCount(lines);
    
    NSAssert(count == CFArrayGetCount(guideLines), @"Line numbers mismatch!");

    // Get the points where each line starts.
    CGPoint origins[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, count), origins);

    // Get the bounds of the frame.
    frameBounds = CGPathGetPathBoundingBox(CTFrameGetPath(frame));
    
    // Translate to the frame origin.
    CGContextTranslateCTM(context, frameBounds.origin.x, frameBounds.origin.y);
    
    for (CFIndex index = 0; index < count; ++index) {
        CTLineRef line;
        CTLineRef guideLine;
        CGPoint origin;
        CGFloat lineWidth;
        BOOL isTruncated = NO;
        
        line = CFArrayGetValueAtIndex(lines, index);
        guideLine = CFArrayGetValueAtIndex(guideLines, index);
        lineWidth = CTLineGetTypographicBounds(guideLine, NULL, NULL, NULL);
        
        // We might need to replace it with a new line that needs to be released.
        // To match that, retain the line.
        CFRetain(line);
        
        if (self.ellipsisOnLastVisibleLine && lastFrame && index == count - 1) {
            // Last line of last frame. Check whether it needs ellipsis.
            CFRange stringRange;
            
            stringRange = CTLineGetStringRange(line);
            if (stringRange.location + stringRange.length < [self.attributedText length]) {
                // We're not at the end of the text! Need to truncate.
                CTLineRef tempLine;
                
                tempLine = [self private_createTruncatedLine:line width:lineWidth stringRange:stringRange];
                
                CFRelease(line);
                line = tempLine;
                
                isTruncated = YES;
            }
        }
        
        origin = origins[index];

        // Translate to the origin of the line.
        CGContextTranslateCTM(context, origin.x, origin.y);
        {
            CFArrayRef runs;
            BOOL isCustomJustified = NO;
            
            // Query whether the line is justified. We simply ask the first
            // glyph run.
            runs = CTLineGetGlyphRuns(line);
            if (CFArrayGetCount(runs) > 0) {
                CFDictionaryRef attributes;
                
                attributes = CTRunGetAttributes(CFArrayGetValueAtIndex(runs, 0));
                
                if (CFDictionaryGetValue(attributes, (__bridge const void *)(MHTextViewJustifiedAttributeName)) != NULL) {
                    // We've detected a line that should be manually justified.
                    isCustomJustified = YES;
                }
            }
            
            if (isCustomJustified) {
                // Do our custom justification.
                [self private_drawLineWithCustomJustification:line
                                                    withWidth:lineWidth
                                                  isTruncated:isTruncated
                                                    inContext:context];
            } else {
                CGAffineTransform savedMatrix;
                CGPoint savedPoint;
                
                // Save context properties that CTLineDraw is modifying but
                // not restoring.
                savedMatrix = CGContextGetTextMatrix(context);
                savedPoint = CGContextGetTextPosition(context);
                
                // Draw the line.
                CTLineDraw(line, context);

                // Restore the saved properties.
                CGContextSetTextMatrix(context, savedMatrix);
                CGContextSetTextPosition(context, savedPoint.x, savedPoint.y);
            }
        }
        
        CFRelease(line);
        
        // Reverse the translation to the origin of the line.
        CGContextTranslateCTM(context, -origin.x, -origin.y);
    }
    
    // Reverse the translation to the frame origin.
    CGContextTranslateCTM(context, -frameBounds.origin.x, -frameBounds.origin.y);
}

- (CTLineRef)private_createTruncatedLine:(CTLineRef)line width:(CGFloat)lineWidth stringRange:(CFRange)stringRange
{
    CTLineRef tempLine;
    NSDictionary *attributes;
    CFDictionaryRef cfAttributes;
    CFAttributedStringRef truncationString;
    CTLineRef truncationToken;
    CGFloat effectiveLineWidth;
    CGFloat effectiveTokenWidth;
    NSAttributedString *subString;
    BOOL needRejustify = NO;


    cfAttributes = CTRunGetAttributes(CFArrayGetValueAtIndex(CTLineGetGlyphRuns(line), 0));
    attributes = (__bridge NSDictionary *)cfAttributes;
    subString = [self.attributedText attributedSubstringFromRange:NSMakeRange(stringRange.location, stringRange.length)];

    // Create a run just containing the truncation token (…).
    truncationString = CFAttributedStringCreate(NULL, CFSTR("\u2026"), cfAttributes);
    truncationToken = CTLineCreateWithAttributedString(truncationString);
    CFRelease(truncationString);
    
    // Retain it because we might replace the line and then need to release that
    // later.
    CFRetain(line);

    if (!self.useCustomJustify) {
        NSParagraphStyle *paragraph;
        
        paragraph = attributes[NSParagraphStyleAttributeName];
        if (paragraph.alignment == NSTextAlignmentJustified) {
            // Re-create the line, which removes the justification.
            CTTypesetterRef typesetter;
            
            typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
            tempLine = CTTypesetterCreateLine(typesetter, stringRange);
            CFRelease(typesetter);
            
            CFRelease(line);
            line = tempLine;
            
            needRejustify = YES;
        }
    }
    
    // Measure how to add the "…".
    effectiveLineWidth = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
    effectiveTokenWidth = CTLineGetTypographicBounds(truncationToken, NULL, NULL, NULL);
    if ((effectiveLineWidth + effectiveTokenWidth) < lineWidth) {
        // We can add a "…" without running out of space. So just add it.
        NSMutableAttributedString *modified;
        NSAttributedString *token;
        NSCharacterSet *whitespace;
        
        token = [[NSAttributedString alloc] initWithString:@"\u2026" attributes:attributes];
        modified = [subString mutableCopy];
        
        // Delete all whitespace at the end.
        whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        while ([whitespace characterIsMember:[[modified string] characterAtIndex:[[modified string] length] - 1]]) {
            [modified deleteCharactersInRange:NSMakeRange([[modified string] length] - 1, 1)];
        }
        
        [modified appendAttributedString:token];
        [modified setAttributes:attributes range:NSMakeRange(0, [modified length])];
        
        tempLine = CTLineCreateWithAttributedString((CFAttributedStringRef)modified);
        
    } else {
        // We don't have enough space for "…" so we really need to truncate the
        // existing line. Due to whitespace and stuff, we actually need to bit
        // more text than the line contains to reliably truncate.
        CFRange stringRange;
        NSRange stringRange2;
        CTLineRef lineToTruncate;
        
        stringRange = CTLineGetStringRange(line);
        if (self.attributedText.length - (stringRange.location + stringRange.length) > 100) {
            // Limit the additional number of characters.
            stringRange.length += 100;
        } else {
            // Take what's left.
            stringRange.length = self.attributedText.length - stringRange.location;
        }
        
        stringRange2.location = stringRange.location;
        stringRange2.length = stringRange.length;
        lineToTruncate = CTLineCreateWithAttributedString((CFAttributedStringRef)[self.attributedText attributedSubstringFromRange:stringRange2]);
        
        tempLine = CTLineCreateTruncatedLine(lineToTruncate, lineWidth, kCTLineTruncationEnd, truncationToken);
        if (!tempLine) {
            tempLine = CFRetain(line);
        }
        
        CFRelease(lineToTruncate);
    }
    
    if (needRejustify) {
        CTLineRef tempLine2;
        
        tempLine2 = CTLineCreateJustifiedLine(tempLine, 1, lineWidth);
        
        CFRelease(tempLine);
        tempLine = tempLine2;
    }
    
    CFRelease(line);
    CFRelease(truncationToken);
    
    return tempLine;
}

- (void)private_drawLineWithCustomJustification:(CTLineRef)line withWidth:(CGFloat)width isTruncated:(BOOL)truncated inContext:(CGContextRef)context
{
    NSString *string;
    NSUInteger gaps = 0;
	NSUInteger glyphCount = 0;
    CGFloat totalGlyphWidth = 0;
    CGFloat whitespaceDelta;
	CGFloat glyphDelta;
    CFArrayRef runs;
    CFIndex runCount;
    NSCharacterSet *newlineSet;
    CGFloat x = 0;
    BOOL lastCharacterIsNewline = NO;
    BOOL isEndOfParagraph = NO;
    BOOL isWhitespace = NO;
    
    // TODO: Handle right-to-left text.
    
    string = [self.attributedText string];
    
    newlineSet = [NSCharacterSet newlineCharacterSet];
    runs = CTLineGetGlyphRuns(line);
    runCount = CFArrayGetCount(runs);
    
    // First iteration: gather some metrics (number of gaps, total width of the
    // non-whitespace glyphs).
    for (CFIndex runIndex = 0; runIndex < runCount; ++runIndex) {
        CTRunRef run;
        CGGlyph *glyphs;
        CGSize *advances;
        CFIndex *indices;
        CGRect *boundingBoxes;
        CFRange range;
        CFRange stringRange;
        CTFontRef runFont;
        
        run = CFArrayGetValueAtIndex(runs, runIndex);
        range = CFRangeMake(0, CTRunGetGlyphCount(run));
        runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        stringRange = CTRunGetStringRange(run);
        
        glyphs = malloc(range.length * sizeof(CGGlyph));
        advances = malloc(range.length * sizeof(CGSize));
        indices = malloc(range.length * sizeof(CFIndex));
        boundingBoxes = malloc(range.length * sizeof(CGRect));
        
        CTRunGetGlyphs(run, range, glyphs);
        CTRunGetAdvances(run, range, advances);
        CTRunGetStringIndices(run, range, indices);
        CTFontGetBoundingRectsForGlyphs(runFont, kCTFontDefaultOrientation, glyphs, boundingBoxes, range.length);
        
        for (NSUInteger glyphIndex = 0; glyphIndex < range.length; ++glyphIndex) {
            BOOL isWhitespaceGlyph;

            if (CGRectIsEmpty(boundingBoxes[glyphIndex])) {
                isWhitespace = YES;
                isWhitespaceGlyph = YES;
                
            } else {
                if (isWhitespace) {
                    isWhitespace = NO;
                    // Count the number of whitespace -> word transitions.
                    ++gaps;
                }
                
                isWhitespaceGlyph = NO;
            }
            
            if (!isWhitespaceGlyph) {
                totalGlyphWidth += advances[glyphIndex].width;
				++glyphCount;
            }
        }

        lastCharacterIsNewline = [newlineSet characterIsMember:[string characterAtIndex:stringRange.location + stringRange.length - 1]];
        
        if (stringRange.location + stringRange.length == [string length]) {
            // The run ends with the very last character of the string, so
            // it's the end of a paragraph even if it doesn't end with a newline.
            isEndOfParagraph = YES;
        }
        
        free(boundingBoxes);
        free(glyphs);
        free(advances);
        free(indices);
    }
    
    if (isEndOfParagraph || lastCharacterIsNewline) {
        // This is the end of the paragraph, don't spread it out.
        CTLineDraw(line, context);
        // Reverse the translation done by `CTLineDraw`.
        CGContextTranslateCTM(context, -CTLineGetTypographicBounds(line, NULL, NULL, NULL), 0);
        return;
    }
    
    if (gaps > 0) {
		// A "normal" line with at least one whitespace gap. Spread out the
		// whitespace only.
        whitespaceDelta = (width - totalGlyphWidth) / gaps;
		glyphDelta = 0;
    } else if (glyphCount > 0) {
		// Oh dear, we've got a single word. We'll need to spread it.
        whitespaceDelta = 0;
		if (glyphCount == 1) {
			// The whole line has just one character?
			glyphDelta = 0;
		} else {
			glyphDelta = (width - totalGlyphWidth) / (glyphCount - 1);
		}
	} else {
		// Huh? Empty line?
		return;
	}
	
    // Second iteration: draw the glyphs.
    for (CFIndex runIndex = 0; runIndex < runCount; ++runIndex) {
        CTRunRef run;
        CFDictionaryRef attributes;
        UIColor *color;
        NSUnderlineStyle underlineStyle;
        UIColor *underlineColor;
        CGGlyph *glyphs;
        CGSize *advances;
        CGPoint *positions;
        CGRect *boundingBoxes;
        CFRange range;
        CTFontRef runFont;

        run = CFArrayGetValueAtIndex(runs, runIndex);
        range = CFRangeMake(0, CTRunGetGlyphCount(run));
        attributes = CTRunGetAttributes(run);
        
        runFont = CFDictionaryGetValue(attributes, NSFontAttributeName);
        color = (UIColor *)CFDictionaryGetValue(attributes, NSForegroundColorAttributeName);
        if (!color) {
            color = [UIColor blackColor];
        }
        
        // TODO: Support more underline styles.
        // But it looks like CoreText only supports the single underline.
        // TODO: Support strike-through.
        underlineStyle = [(id)CFDictionaryGetValue(attributes, NSUnderlineStyleAttributeName) intValue];
        if (underlineStyle == NSUnderlineStyleSingle) {
            underlineColor = (UIColor *)CFDictionaryGetValue(attributes, NSUnderlineColorAttributeName);
            if (!underlineColor) {
                underlineColor = color;
            }
        }
        
        glyphs = malloc(range.length * sizeof(CGGlyph));
        advances = malloc(range.length * sizeof(CGSize));
        positions = malloc(range.length * sizeof(CGPoint));
        boundingBoxes = malloc(range.length * sizeof(CGRect));
        
        CTRunGetGlyphs(run, range, glyphs);
        CTRunGetAdvances(run, range, advances);
        CTFontGetBoundingRectsForGlyphs(runFont, kCTFontDefaultOrientation, glyphs, boundingBoxes, range.length);
        
        for (CFIndex glyphIndex = 0; glyphIndex < range.length; ++glyphIndex) {
            positions[glyphIndex].x = x;
            positions[glyphIndex].y = 0;
            
            if (CGRectIsEmpty(boundingBoxes[glyphIndex])) {
                // Whitespace.
                x += whitespaceDelta + glyphDelta;
            } else {
                // Non-whitespace.
                x += advances[glyphIndex].width + glyphDelta;
            }
        }

        if (underlineColor) {
            CGFloat scale;
            CGFloat thickness;
            CGPoint p[2];
            
            scale = [[UIScreen mainScreen] scale];
            thickness = ceil(CTFontGetUnderlineThickness(runFont) * scale) / scale;
            
            p[0].x = positions[0].x;
            p[0].y = round(CTFontGetUnderlinePosition(runFont) * scale) / scale;
            // Haisenko 140805: For small font sizes, the position is somehow off
            // by a point. Don't know why. Manually work around it, but it feels
            // wrong.
            p[0].y = MIN(p[0].y, -2 / scale);
            // Line-drawing in CoreGraphics means drawing an infinitely thin line
            // and filling the area half of the linewidth on each side of the line.
            // So to draw 1 px line we need to actually draw in the _middle_ of
            // the pixel. Account for that.
            if (fmod(thickness * scale, 2) == 1) {
                p[0].y -= 0.5 / scale;
            }
            p[1].x = positions[range.length - 1].x + advances[range.length - 1].width;
            p[1].y = p[0].y;
            CGContextSetStrokeColorWithColor(context, [underlineColor CGColor]);
            CGContextSetLineWidth(context, thickness);
            CGContextStrokeLineSegments(context, p, 2);
        }

        CGContextSetFillColorWithColor(context, [color CGColor]);

        // TODO: Understand whether and how to use CTRunGetTextMatrix
        // TODO: Handle embedded images.
        CTFontDrawGlyphs(runFont, glyphs, positions, range.length, context);
        

        free(glyphs);
        free(advances);
        free(positions);
        free(boundingBoxes);
    }
}

@end
