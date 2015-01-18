//
//  ViewController.h
//  Blustrick
//

//  Copyright (c) 2014 Zois Avgerinos. All rights reserved.
//

@import AVFoundation;
#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <StoreKit/StoreKit.h>
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "SKProduct+priceAsString.h"
#import "MenuScene.h"
#import <RevMobAds/RevMobAds.h>


@interface ViewController : UIViewController <SKProductsRequestDelegate,SKPaymentTransactionObserver,sceneDelegate,RevMobAdsDelegate>

@property (nonatomic) SKProduct *validProduct;
@property (nonatomic) MBProgressHUD *inapp;
@property (nonatomic) UIAlertView* askToPurchase;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (nonatomic) NSUserDefaults *MUSIC_ON;
@property (nonatomic) NSUserDefaults *SOUNDS_ON;
@property (nonatomic) NSUserDefaults *DIFFICULTY;
@property (nonatomic) NSUserDefaults *CURRENT;
@property (nonatomic) NSUserDefaults *CREATED;
@property (nonatomic) NSUserDefaults *MAX_LEVEL;
@property (nonatomic) NSUserDefaults *CLEARED_LEVELS;

@property (nonatomic,strong)RevMobFullscreen *fullscreen;

- (BOOL)connected;
- (void)restorePurchases;
- (void)unlock:(NSString *)item;
- (void)playMusic:(NSString *)file type:(NSString *)type;
- (void)stopMusic;

@end
