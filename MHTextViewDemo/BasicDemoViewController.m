//
//  ViewController.m
//  MHTextViewDemo
//
//  Created by Marc Haisenko on 02.08.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "BasicDemoViewController.h"

#import "PathVisualizerView.h"

#import <MHTextView/MHTextView.h>
#import <MHTextView/MHDefaultTextViewLayout.h>

@implementation BasicDemoViewController
{
    IBOutlet MHTextView *_textView;
    IBOutlet UISegmentedControl *_alignmentControl;
    IBOutlet UISwitch *_useCustomJustification;
    IBOutlet UISegmentedControl *_languageControl;
    IBOutlet UISwitch *_ellipsisOnLastLine;
    IBOutlet UISlider *_columnsSlider;
    IBOutlet UISlider *_gapSlider;
    IBOutlet UISlider *_exclusionViewsSlider;
    IBOutlet UISlider *_exclusionPathsSlider;
    IBOutlet UISwitch *_useLongText;
    IBOutlet UISwitch *_topToBottom;
    IBOutlet PathVisualizerView *_pathVisualizer;
    
    NSString *_demoTextLongGerman;
    NSString *_demoTextLongEnglish;
    NSString *_demoTextLongLoremIpsum;
    NSString *_demoTextShortGerman;
    NSString *_demoTextShortEnglish;
    NSString *_demoTextShortLoremIpsum;
    
    NSArray *_exclusionPaths;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Required to avoid having the library stripped: we're not actually using
    // the class in code _directly_, only via the storyboard (where it's only
    // referencedas a string). So the linker thinks the library isn't used at all
    // and strips it out, causing a runtime error as it can't find the class any
    // more. This line avoids that.
    [MHTextView class];
    
    _demoTextShortEnglish = [self loadStringFile:@"FillerTextEnglishShort"];
    _demoTextLongEnglish = [self loadStringFile:@"FillerTextEnglish"];
    _demoTextLongEnglish = [_demoTextLongEnglish stringByAppendingString:_demoTextLongEnglish];
    
    _demoTextShortGerman = [self loadStringFile:@"FillerTextGermanShort"];
    _demoTextLongGerman = [self loadStringFile:@"FillerTextGerman"];
    _demoTextLongGerman = [_demoTextLongGerman stringByAppendingString:_demoTextLongGerman];
    
    _demoTextShortLoremIpsum = [self loadStringFile:@"FillerTextLoremIpsumShort"];
    _demoTextLongLoremIpsum = [self loadStringFile:@"FillerTextLoremIpsum"];
    _demoTextLongLoremIpsum = [_demoTextLongLoremIpsum stringByAppendingString:_demoTextLongLoremIpsum];
    
    [self private_updateProperties];
    [self private_updateLayout];
    [self private_updateText];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Force updating the exclusion paths.
    _exclusionPaths = nil;
    [self private_updateExclusionPaths];
}

#pragma mark -
#pragma mark Actions

- (IBAction)customJustificationDidChange:(id)sender
{
    [self private_updateProperties];
}

- (IBAction)ellipsisDidChange:(id)sender
{
    [self private_updateProperties];
}

- (IBAction)alignmentDidChange:(id)sender
{
    [self private_updateText];
}

- (IBAction)languageDidChange:(id)sender
{
    [self private_updateText];
}

- (IBAction)columnsDidChange:(id)sender
{
    [self private_updateLayout];
}

- (IBAction)gapDidChange:(id)sender
{
    [self private_updateLayout];
}

- (IBAction)exclusionViewsDidChange:(id)sender
{
    [self private_updateExclusionViews];
}

- (IBAction)exclusionPathsDidChange:(id)sender
{
    [self private_updateExclusionPaths];
}

- (IBAction)longTextDidChange:(id)sender
{
    [self private_updateText];
}

- (IBAction)topToButtomDidChange:(id)sender
{
    [self private_updateProperties];
}

- (IBAction)redistribute:(id)sender
{
    [self private_redistributeExclusionViewsAndPaths];
}


#pragma mark -
#pragma mark MHTextViewDelegate

- (NSArray *)exclusionPathsForMHTextView:(MHTextView *)textView
{
    return _exclusionPaths;
}


#pragma mark -
#pragma mark Private methods

- (void)private_updateLayout
{
    MHDefaultTextViewLayout *layout;
    
    layout = _textView.layout;
    
    layout.numberOfColumns = _columnsSlider.value;
    layout.columnGap = _gapSlider.value;
    
    [_textView setNeedsLayout];
}

- (void)private_updateText
{
    NSString *text;
    NSTextAlignment alignment;
    NSMutableAttributedString *attributed;
    NSMutableParagraphStyle *paragraph;
    NSDictionary *attributes;
    UIFont *font;
    
    if (_useLongText.on) {
        switch (_languageControl.selectedSegmentIndex) {
            case 0:
                text = _demoTextLongEnglish;
                break;
                
            case 1:
                text = _demoTextLongGerman;
                break;
                
            default:
                text = _demoTextLongLoremIpsum;
                break;
        }
    } else {
        switch (_languageControl.selectedSegmentIndex) {
            case 0:
                text = _demoTextShortEnglish;
                break;
                
            case 1:
                text = _demoTextShortGerman;
                break;
                
            default:
                text = _demoTextShortLoremIpsum;
                break;
        }
    }
    
    switch (_alignmentControl.selectedSegmentIndex) {
        case 0:
            alignment = NSTextAlignmentLeft;
            break;
            
        case 1:
            alignment = NSTextAlignmentCenter;
            break;
            
        case 2:
            alignment = NSTextAlignmentRight;
            break;
            
        case 3:
            alignment = NSTextAlignmentNatural;
            break;
            
        default:
            alignment = NSTextAlignmentJustified;
            break;
    }
    
    font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    paragraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraph.alignment = alignment;
    paragraph.paragraphSpacing = font.lineHeight;
    
    attributes = @{
        NSFontAttributeName : font,
        NSParagraphStyleAttributeName : paragraph,
    };
    
    attributed = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    // Add some more fun attributes.
    
    [attributed addAttribute:NSForegroundColorAttributeName
                       value:[UIColor redColor]
                       range:NSMakeRange(50, 20)];
    
    attributes = @{
        NSUnderlineColorAttributeName : [UIColor purpleColor],
        NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
    };
    [attributed addAttributes:attributes range:NSMakeRange(10, 20)];

    [attributed addAttribute:NSBackgroundColorAttributeName
                       value:[UIColor yellowColor]
                       range:NSMakeRange(150, 20)];
    
    attributes = @{
        NSStrikethroughColorAttributeName : [UIColor redColor],
        NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
    };
    [attributed addAttributes:attributes range:NSMakeRange(200, 20)];
    
    [attributed addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"Futura-Medium" size:font.pointSize]
                       range:NSMakeRange(250, 20)];
    
    _textView.attributedText = attributed;
}

- (void)private_updateProperties
{
    _textView.useCustomJustify = _useCustomJustification.on;
    _textView.ellipsisOnLastVisibleLine = _ellipsisOnLastLine.on;
    _textView.textDistribution =
        _topToBottom.on
        ? MHTextViewTextDistributionTopToBottom
        : MHTextViewTextDistributionDefault;
}

- (void)private_updateExclusionViews
{
    NSUInteger count;
    NSMutableArray *views;
    
    count = _exclusionViewsSlider.value;
    if (count == _textView.exclusionViews.count) {
        return;
    }
    
    [_textView.exclusionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    views = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; ++i) {
        UIView *view;
        
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        [_textView addSubview:view];
        [views addObject:view];
    }
    
    _textView.exclusionViews = views;
 
    [self private_redistributeExclusionViewsAndPaths];
}

- (void)private_updateExclusionPaths
{
    NSUInteger count;
    NSMutableArray *paths;
    CGSize boundsSize;
    CGSize maxSize;
    
    count = _exclusionPathsSlider.value;
    if (count == _exclusionPaths.count) {
        return;
    }

    boundsSize = _textView.bounds.size;
    maxSize.width = boundsSize.width / 2;
    maxSize.height = boundsSize.height / 2;
    
    paths = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; ++i) {
        UIBezierPath *path;
        CGRect frame;
        
        frame.origin.x = arc4random_uniform(boundsSize.width * 0.8);
        frame.origin.y = arc4random_uniform(boundsSize.height * 0.8);
        frame.size.width = arc4random_uniform(maxSize.width);
        frame.size.height = arc4random_uniform(maxSize.height);
        
        path = [UIBezierPath bezierPathWithOvalInRect:frame];
        [paths addObject:path];
    }
    
    _exclusionPaths = paths;
    _pathVisualizer.paths = paths;
    [_textView invalidateLayout];
}

- (void)private_redistributeExclusionViewsAndPaths
{
    CGSize boundsSize;
    CGSize maxSize;
    
    boundsSize = _textView.bounds.size;
    maxSize.width = boundsSize.width / 2;
    maxSize.height = boundsSize.height / 2;
    
    for (UIView *view in _textView.exclusionViews) {
        CGRect frame;
        
        frame.origin.x = arc4random_uniform(boundsSize.width);
        frame.origin.y = arc4random_uniform(boundsSize.height);
        frame.size.width = arc4random_uniform(maxSize.width);
        frame.size.height = arc4random_uniform(maxSize.height);
        
        view.frame = frame;
    }
    
    // Force recreating the paths.
    _exclusionPaths = nil;
    [self private_updateExclusionPaths];
}

@end
