//
//  ViewController.h
//  BlustrickLevels
//
//  Created by Zois Avgerinos on 7/19/14.
//  Copyright (c) 2014 Zois Avgerinos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIAccessibilityIdentification>
- (IBAction)createString:(id)sender;
- (IBAction)reset:(id)sender;
@property(nonatomic, copy) NSString *accessibilityIdentifier NS_AVAILABLE_IOS(5_0);
@end
