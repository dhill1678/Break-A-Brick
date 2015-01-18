//
//  CreateLevel.m
//  Break-A-Brick
//
//  Created by DAVID HILL on 1/4/15.
//  Copyright (c) 2015 Zois Avgerinos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CreateLevel.h"
#import "AppDelegate.h"

@interface CreateLevel ()
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation CreateLevel
NSArray *icons;
int imageIndex;
NSMutableString *result;
UIImageView *inst_alert;
UIButton *myButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Serve RevMob ad
    [self initialiseRevMob:@"54a9fea66496aa1a67b49ec2" testMode:NO];
    [self revmobShowAd];
    
    // Do any additional setup after loading the view, typically from a nib.
    imageIndex = 0;
    [self createButtons];
    
    icons = [[NSArray alloc]initWithObjects:@"normal_brick",@"none",@"glass_brick",@"bold_brick",@"metal_brick",nil];
    result = [[NSMutableString alloc]init];
    
    //instructions alert
    inst_alert =[[UIImageView alloc] initWithFrame:CGRectMake(20,self.view.frame.size.height/2-self.view.frame.size.height/8,self.view.frame.size.width-40,self.view.frame.size.height/4)];
    //UIImageView *inst_alert =[[UIImageView alloc] initWithFrame:CGRectMake(20,20,self.view.frame.size.width-40,self.view.frame.size.height/4)];
    inst_alert.image=[UIImage imageNamed:@"instructions.png"];
    [self.view addSubview:inst_alert];
    
    myButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50,self.view.frame.size.height/2-self.view.frame.size.height/8-10,40,40)];
    UIImage *buttonImage = [UIImage imageNamed:@"cancel.png"];
    [myButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.view addSubview:myButton];
    [myButton addTarget:self action:@selector(CLOSE_INST:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *btnLayer = [_roundedButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    _SavedButton.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createString:(id)sender {
    if (inst_alert.hidden == YES) {
        [self playTap2];
        _SavedButton.hidden = NO;
        
        [result setString:@""];
        UIButton *button;
        for (int i=0; i<7; i++) {
            for (int j=0; j<7; j++) {
                if (i==0 && j==0) {
                    button = (UIButton *)[self.view viewWithTag:97];
                } else {
                    button = (UIButton *)[self.view viewWithTag:[[NSString stringWithFormat:@"%i%i",j,i]integerValue]];
                }
                
                if ([[button accessibilityIdentifier]isEqualToString:@"normal_brick"]) {
                    if(i==6 && j==6){
                        [result appendString:@"nil]"];
                    }
                    continue;
                }
                //NSLog(@"id=%i (%i %i) %@",button.tag,j,i,[button accessibilityIdentifier]);
                //[result appendString:@"@\""];
                [result appendString:[NSString stringWithFormat:@"%i",i]];
                //[result appendString:@"\","];
                [result appendString:@","];
                //[result appendString:@"@\""];
                [result appendString:[NSString stringWithFormat:@"%i",j]];
                //[result appendString:@"\","];
                [result appendString:@","];
                //[result appendString:@"@\""];
                [result appendString:[NSString stringWithFormat:@"%@",[button accessibilityIdentifier]]];
                //[result appendString:@"\","];
                [result appendString:@","];
                //if(i==6 && j==6){
                //    [result appendString:@"nil]"];
                //}
            }
            
            [_appDelegate.controller.CREATED setObject:result forKey:@"made_level"];
            [_appDelegate.controller.CREATED synchronize];
        }
        
        NSLog(@"result = %@",result); //copy paste that to Blustrick project
        //NSLog(@"result length = %@",result.length); //copy paste that to Blustrick project

    }
}

- (IBAction)reset:(id)sender {
    if (inst_alert.hidden == YES) {
        // Serve RevMob ad
        [self initialiseRevMob:@"54a9fea66496aa1a67b49ec2" testMode:NO];
        [self revmobShowAd];
        
        [self playTap];
        _SavedButton.hidden = YES;
        
        UIButton *button;
        for (int i=0; i<7; i++) {
            for (int j=0; j<7; j++) {
                if (i==0 && j==0) {
                    button = (UIButton *)[self.view viewWithTag:97];
                } else {
                    button = (UIButton *)[self.view viewWithTag:[[NSString stringWithFormat:@"%i%i",j,i]integerValue]];
                }
                
                [button removeFromSuperview];
            }
        }
        
        [self createButtons];
    }
}

- (IBAction)back:(id)sender {
    if (inst_alert.hidden == YES) {
        // Serve RevMob ad
        [self initialiseRevMob:@"54a9fea66496aa1a67b49ec2" testMode:NO];
        [self revmobShowAd];
        
        [self playTap];
        _SavedButton.hidden = YES;
        
        // perform segue from skscene
        //UIViewController *vc = self.view.window.rootViewController;
        [self performSegueWithIdentifier:@"back2main" sender:nil];
    }
}

-(void)createButtons{
    UIButton *btn;
    for (int i=0; i<7; i++) {
        for (int j=0; j<7; j++) {
            btn = [[UIButton alloc] initWithFrame:CGRectMake(20+i*(self.view.frame.size.width-40)/7, 50+j*(self.view.frame.size.width-40)/7, (self.view.frame.size.width-40)/7, (self.view.frame.size.width-40)/7)];
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                [btn setImage:[UIImage imageNamed:@"bold_brick@2x"] forState:UIControlStateNormal];
            } else {
                [btn setImage:[UIImage imageNamed:@"bold_brick"] forState:UIControlStateNormal];
            }
            [btn setAccessibilityIdentifier:@"bold_brick"];
            //NSLog(@"btnid %@",[btn accessibilityIdentifier]);
            [btn addTarget:self action:@selector(changeImage:) forControlEvents:UIControlEventTouchUpInside];
            NSString *tmpn = [NSString stringWithFormat:@"%i%i",j,i];
            btn.tag = [tmpn integerValue];
            if (i==0 && j==0) {
                btn.tag=97; //if tag=0 we have problem with accessibility identifier, is null
            }
            [self.view addSubview:btn];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    //CGPoint location = [touch locationInView: touch.view];
    if ([touch.view isKindOfClass: UIButton.class]) {
    }
}

- (void)changeImage:(UIButton *)sender{
    if (inst_alert.hidden == YES) {
        _SavedButton.hidden = YES;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            [sender setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@",[icons objectAtIndex:imageIndex],@"@2x"]] forState:UIControlStateNormal]; // could be wrong
        } else {
            [sender setImage:[UIImage imageNamed:[icons objectAtIndex:imageIndex]] forState:UIControlStateNormal];
        }
        [sender setAccessibilityIdentifier:[icons objectAtIndex:imageIndex]];
        if (imageIndex+1 < [icons count]) {
            imageIndex++;
        } else {
            imageIndex = 0;
        }
    }
}

- (void)CLOSE_INST:(UIButton *)sender{
    inst_alert.hidden = YES;
    myButton.hidden = YES;
}

- (void)playTap {
    // Construct URL to sound file
    NSString *path = [NSString stringWithFormat:@"%@/tap_labels.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    // Create audio player object and initialize with URL to sound
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [_audioPlayer play];
}

- (void)playTap2 {
    // Construct URL to sound file
    NSString *path = [NSString stringWithFormat:@"%@/tap_labels2.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    // Create audio player object and initialize with URL to sound
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [_audioPlayer play];
}

#pragma mark RevMob methods

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

