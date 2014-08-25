//
//  AutoLayoutDemoViewController.m
//  MHTextViewDemo
//
//  Created by Marc Haisenko on 10.08.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "AutoLayoutDemoViewController.h"

#import <MHTextView/MHTextView.h>
#import <MHTextView/MHDefaultTextViewLayout.h>


@implementation AutoLayoutDemoViewController
{
    IBOutlet MHTextView *_textView;
    IBOutlet UISegmentedControl *_languageControl;
    IBOutlet UISlider *_widthSlider;
    IBOutlet NSLayoutConstraint *_widthConstraint;
    
    NSString *_demoTextGerman;
    NSString *_demoTextEnglish;
    NSString *_demoTextLoremIpsum;
}

- (void)viewDidLoad
{
    CGFloat width;
    
    [super viewDidLoad];

    _demoTextEnglish = [self loadStringFile:@"FillerTextEnglishShort"];
    _demoTextGerman = [self loadStringFile:@"FillerTextGermanShort"];
    _demoTextLoremIpsum = [self loadStringFile:@"FillerTextLoremIpsumShort"];
    
    width = self.view.bounds.size.width - 40;
    _widthSlider.maximumValue = width;
    _widthSlider.value = width;
    _widthConstraint.constant = width;
    
    [self private_updateText];
}

- (void)viewDidLayoutSubviews
{
    CGFloat width;
    
    [super viewDidLayoutSubviews];
    
    width = self.view.bounds.size.width - 40;
    _widthSlider.maximumValue = width;
    
    _widthConstraint.constant = _widthSlider.value;
    // Invalidate the content size in next runloop iteration. Fixes a problem
    // when rotating the screen.
    dispatch_async(dispatch_get_main_queue(), ^{
        [_textView invalidateIntrinsicContentSize];
    });
}


#pragma mark -
#pragma mark Actions

- (IBAction)widthDidChange:(id)sender
{
    // Prevent making the width too narrow.
    if (_widthSlider.value < 100) {
        _widthSlider.value = 100;
    }
    
    _widthConstraint.constant = _widthSlider.value;
    [_textView invalidateIntrinsicContentSize];
}

- (IBAction)languageDidChange:(id)sender
{
    [self private_updateText];
}


#pragma mark -
#pragma mark Private utility methods

- (void)private_updateText
{
    NSString *text;
    NSTextAlignment alignment;
    NSMutableAttributedString *attributed;
    NSMutableParagraphStyle *paragraph;
    NSDictionary *attributes;
    UIFont *font;

    switch (_languageControl.selectedSegmentIndex) {
        case 0:
            text = _demoTextEnglish;
            break;
            
        case 1:
            text = _demoTextGerman;
            break;
            
        default:
            text = _demoTextLoremIpsum;
            break;
    }
    
    alignment = NSTextAlignmentJustified;
    
    font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    paragraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraph.alignment = alignment;
    paragraph.paragraphSpacing = font.lineHeight;
    
    attributes = @{
        NSFontAttributeName : font,
        NSParagraphStyleAttributeName : paragraph,
    };
    
    attributed = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    _textView.attributedText = attributed;
    [_textView invalidateIntrinsicContentSize];
}

@end
