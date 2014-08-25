//
//  CustomLayoutDemoViewController.m
//  MHTextViewDemo
//
//  Created by Marc Haisenko on 17.08.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "CustomLayoutDemoViewController.h"

#import "NarrowMiddleColumnLayout.h"
#import "RhombusLayout.h"

@implementation CustomLayoutDemoViewController
{
    IBOutlet MHTextView *_narrowMiddleTextView;
    IBOutlet MHTextView *_rhombusTextView;
    IBOutlet UISegmentedControl *_languageControl;
    
    NSString *_demoTextGerman;
    NSString *_demoTextEnglish;
    NSString *_demoTextLoremIpsum;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _demoTextEnglish = [self loadStringFile:@"FillerTextEnglish"];
    _demoTextGerman = [self loadStringFile:@"FillerTextGerman"];
    _demoTextLoremIpsum = [self loadStringFile:@"FillerTextLoremIpsum"];
    
    _narrowMiddleTextView.layout = [[NarrowMiddleColumnLayout alloc] init];
    _rhombusTextView.layout = [[RhombusLayout alloc] init];
    
    [self private_updateText];
}

- (IBAction)languageDidChange:(id)sender
{
    [self private_updateText];
}

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
    
    _narrowMiddleTextView.attributedText = attributed;
    _rhombusTextView.attributedText = attributed;
}

@end
