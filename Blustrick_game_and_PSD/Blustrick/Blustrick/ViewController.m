//
//  ViewController.m
//  Blustrick
//
//  Created by Zois Avgerinos on 6/30/14.
//  Copyright (c) 2014 Zois Avgerinos. All rights reserved.
//
@import AVFoundation;
#import "ViewController.h"
#import "GameScene.h"
#import "MenuScene.h"
#import <iAd/iAd.h>
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //iAd
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"BlustrickNoAds"]) {
        //iAd at bottom. we only need that line of code!!!(magic)
        self.canDisplayBannerAds = YES;
    }else{
        self.canDisplayBannerAds = NO;
    }
    
    //TEST
    //self.canDisplayBannerAds = NO;
    //[[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"BlustrickAllLevels"];
    //[[NSUserDefaults standardUserDefaults]setObject:@"9" forKey:@"max_level"];
    
    //delegate
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.controller = self;
    
    //MUSIC AND SOUNDFX INITIALISATION
    _MUSIC_ON = [NSUserDefaults standardUserDefaults];
    [_MUSIC_ON synchronize];
    //first time music is on
    if (![_MUSIC_ON objectForKey:@"music_on"]) {
        //[_MUSIC_ON setBool:YES forKey:@"music_on"];
        [_MUSIC_ON setBool:NO forKey:@"music_on"];
    }
    
    _SOUNDS_ON = [NSUserDefaults standardUserDefaults];
    [_SOUNDS_ON synchronize];
    //first time we start with sounds on
    if (![_SOUNDS_ON objectForKey:@"sounds_on"]) {
        [_SOUNDS_ON setBool:YES forKey:@"sounds_on"];
    }
    
    //hold cleared_levels
    _CLEARED_LEVELS = [NSUserDefaults standardUserDefaults];
    [_CLEARED_LEVELS synchronize];
    
    //MAX LEVEL
    _MAX_LEVEL = [NSUserDefaults standardUserDefaults];
    [_MAX_LEVEL synchronize];
    if (![_MAX_LEVEL objectForKey:@"max_level"]) {
        [_MAX_LEVEL setObject:@"1" forKey:@"max_level"];
    }
    
    //DIFFICULTY LEVEL
    _DIFFICULTY = [NSUserDefaults standardUserDefaults];
    [_DIFFICULTY synchronize];
    if (![_DIFFICULTY objectForKey:@"diff_level"]) {
        [_DIFFICULTY setObject:@"1" forKey:@"diff_level"];
    }
    
    //CURRENT LEVEL
    _CURRENT = [NSUserDefaults standardUserDefaults];
    [_CURRENT synchronize];
    if (![_CURRENT objectForKey:@"current_level"]) {
        [_CURRENT setObject:@"1" forKey:@"current_level"];
    }
    
    //CREATED LEVEL
    _CREATED = [NSUserDefaults standardUserDefaults];
    [_CREATED synchronize];
    if (![_CREATED objectForKey:@"made_level"]) {
        [_CREATED setObject:@"0,0,bold_brick,0,1,bold_brick,0,2,bold_brick,0,3,bold_brick,0,4,bold_brick,0,5,bold_brick,0,6,bold_brick,1,0,bold_brick,1,1,bold_brick,1,2,bold_brick,1,3,bold_brick,1,4,bold_brick,1,5,bold_brick,1,6,bold_brick,2,0,bold_brick,2,1,bold_brick,2,2,bold_brick,2,3,bold_brick,2,4,bold_brick,2,5,bold_brick,2,6,bold_brick,3,0,bold_brick,3,1,bold_brick,3,2,bold_brick,3,3,bold_brick,3,4,bold_brick,3,5,bold_brick,3,6,bold_brick,4,0,bold_brick,4,1,bold_brick,4,2,bold_brick,4,3,bold_brick,4,4,bold_brick,4,5,bold_brick,4,6,bold_brick,5,0,bold_brick,5,1,bold_brick,5,2,bold_brick,5,3,bold_brick,5,4,bold_brick,5,5,bold_brick,5,6,bold_brick,6,0,bold_brick,6,1,bold_brick,6,2,bold_brick,6,3,bold_brick,6,4,bold_brick,6,5,bold_brick,6,6,bold_brick" forKey:@"made_level"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDifferentView) name:@"showDifferentView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFullRev) name:@"showFullRev" object:nil];

}

/*
 Setting up your scene in viewWillLayoutSubviews ensures that the view is in the view hierarchy and hence laid out properly.
 In contrast, this does not work correctly in viewDidLayout because the size of the scene is not known at that time.
 */
-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // Configure the view.
    //use originalContentView for iAd to work, otherwise we crash
    SKView * skView = (SKView *)self.originalContentView;
    if (!skView.scene) {
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        
        // Create and configure menu scene
        SKScene * scene = [MenuScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        //scene.delegate = self;
        
        // Present the scene.
        [skView presentScene:scene];
        
    }
}

// hide status bar
-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - InApp
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _validProduct = nil;
    int count = (int)[response.products count];
    if (count>0) {
        for(SKProduct *item in response.products) {
            //NSLog(@"Product title: %@" , item.localizedTitle);
            //NSLog(@"Product description: %@" , item.localizedDescription);
            //NSLog(@"Product price: %@" , item.price);
            //NSLog(@"Product id: %@" , item.productIdentifier);
            if ([item.productIdentifier isEqualToString:@"BlustrickNoAds"] || [item.productIdentifier isEqualToString:@"BlustrickAllLevels"]) {
                _validProduct = item;
            }
        }
        _askToPurchase = [[UIAlertView alloc]
                         initWithTitle:[NSString stringWithFormat:@"Unlock App. Price %@",_validProduct.priceAsString]
                         message:@"Purchase to unlock?"
                         delegate:self
                         cancelButtonTitle:nil
                         otherButtonTitles:@"Yes",@"No", nil];
        [_askToPurchase show];
    } else {
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:@"Not Available"
                            message:@"No products to purchase"
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"Ok", nil];
        [tmp show];
    }
    
    /*
     [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
     
     NSArray *myProduct = response.products;
     NSLog(@"%@",[[myProduct objectAtIndex:0] productIdentifier]);
     
     //Since only one product, we do not need to choose from the array. Proceed directly to payment.
     
     SKPayment *newPayment = [SKPayment paymentWithProduct:[myProduct objectAtIndex:0]];
     [[SKPaymentQueue defaultQueue] addPayment:newPayment];
     */
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Completed");
    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];
    
    // You should make the update to your app based on what was purchased and inform user.
    // [self provideContent: transaction.payment.productIdentifier];
    UIAlertView *tmp = [[UIAlertView alloc]
                        initWithTitle:@"Thank You!"
                        message:@"Game is fully unlocked!"
                        delegate:self
                        cancelButtonTitle:nil
                        otherButtonTitles:@"Ok", nil];
    [tmp show];
    
    //save info as BOOL in NSUserDefaults
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"BlustrickNoAds"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"BlustrickAllLevels"];
    [[NSUserDefaults standardUserDefaults]setObject:@"50" forKey:@"max_level"];
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Restored");
    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // You should make the update to your app based on what was purchased and inform user.
    // [self provideContent: transaction.payment.productIdentifier];
    UIAlertView *tmp = [[UIAlertView alloc]
                        initWithTitle:@"Thank You!"
                        message:@"Game is fully unlocked!"
                        delegate:self
                        cancelButtonTitle:nil
                        otherButtonTitles:@"Ok", nil];
    [tmp show];
    
    //save info as BOOL in NSUserDefaults
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"BlustrickNoAds"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"BlustrickAllLevels"];
    [[NSUserDefaults standardUserDefaults]setObject:@"50" forKey:@"max_level"];
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unsuccessful"
                                                        message:@"Your purchase failed. Please try again."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (void)unlock:(NSString *)item{
    if (![self connected])
    {
        // not connected
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection Not Found" message:@"Please check your network settings!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //already purchased
    if ([[NSUserDefaults standardUserDefaults]boolForKey:item]) {
        return;
    } else {
        if ([SKPaymentQueue canMakePayments]) {
            _inapp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _inapp.mode = MBProgressHUDModeCustomView;
            _inapp.labelText = @"contacting iTunes...please wait";
            //send_hud.mode = MBProgressHUDModeCustomView;
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:item]];
            request.delegate = self;
            [request start];
        } else {
            UIAlertView *tmp = [[UIAlertView alloc]
                                initWithTitle:@"Prohibited"
                                message:@"Parental Control is enabled, cannot make a purchase!"
                                delegate:self
                                cancelButtonTitle:nil
                                otherButtonTitles:@"Ok", nil];
            [tmp show];
        }
        
    }
}

-(void)restorePurchases{
    if (![self connected])
    {
        // not connected
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection Not Found" message:@"Please check your network settings!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //already restored
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"BlustrickNoAds"] && [[NSUserDefaults standardUserDefaults]boolForKey:@"BlustrickAllLevels"]) {
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:@"Already restored"
                            message:@"You have already unlocked all content!"
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"Ok", nil];
        [tmp show];
        return;
    }
    _inapp = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _inapp.mode = MBProgressHUDModeCustomView;
    _inapp.labelText = @"contacting iTunes...please wait";
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

}

#pragma mark - Alert
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == _askToPurchase) {
        if (buttonIndex == 0) {
            SKPayment *payment = [SKPayment paymentWithProduct:_validProduct];
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            
        }
    }
}

#pragma mark

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

#pragma mark - Music
- (void)playMusic:(NSString *)file type:(NSString *)type{
    NSError *error;
    @try{
        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:file withExtension:type];
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        self.backgroundMusicPlayer.numberOfLoops = -1;
        [self.backgroundMusicPlayer setVolume:0.5];  //50%
        [self.backgroundMusicPlayer prepareToPlay];
        [self.backgroundMusicPlayer play];
    }
    @catch (NSException* e) {
        NSLog(@"error %@",e);
    }

}

- (void)stopMusic {
    [self.backgroundMusicPlayer stop];
}

-(void)showDifferentView {
    [self performSegueWithIdentifier:@"createbutton" sender:nil];
}

#pragma mark RevMob methods

-(void)showFullRev {
    // Serve RevMob ad
    [self initialiseRevMob:@"54a9fea66496aa1a67b49ec2" testMode:NO];
    [self revmobShowAd];
}

-(void)revmobAdDidFailWithError:(NSError *)error {
    if(error) {
        NSLog(@"%@",error);
    }
}

-(void)initialiseRevMob: (NSString*)appID testMode:(BOOL)testModeEnable {
    
    if(testModeEnable == YES) {
        [RevMobAds startSessionWithAppID:appID];
        [RevMobAds session].testingMode = RevMobAdsTestingModeWithAds;
    }
    else {
        [RevMobAds startSessionWithAppID:appID];
    }
}

-(void)revmobShowAd {
    [[RevMobAds session] showFullscreen];
}

@end
