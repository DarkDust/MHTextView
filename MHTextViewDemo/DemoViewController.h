//
//  DemoViewController.h
//  MHTextViewDemo
//
//  Created by Marc Haisenko on 17.08.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Base class providing methods that most demo view controllers need.
 */
@interface DemoViewController : UIViewController

/** Reads and returns the contents of the given text file.
 
 @param name Filename without the .txt extension.
 */
- (NSString *)loadStringFile:(NSString *)name;

@end
