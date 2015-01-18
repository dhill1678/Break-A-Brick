//
//  CreateLevel.h
//  Break-A-Brick
//
//  Created by DAVID HILL on 1/4/15.
//  Copyright (c) 2015 Zois Avgerinos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <RevMobAds/RevMobAds.h>

@interface CreateLevel : UIViewController<UIAccessibilityIdentification,RevMobAdsDelegate> {
    AVAudioPlayer *_audioPlayer;
}

- (IBAction)createString:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)back:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *roundedButton;
@property (strong, nonatomic) IBOutlet UILabel *SavedButton;

@property (nonatomic,strong)RevMobFullscreen *fullscreen;

@property(nonatomic, copy) NSString *accessibilityIdentifier NS_AVAILABLE_IOS(5_0);
@end