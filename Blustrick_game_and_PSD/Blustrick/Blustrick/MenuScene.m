//
//  MenuScene.m
//  Blustrick
//
//  Created by Zois Avgerinos on 7/6/14.
//  Copyright (c) 2014 Zois Avgerinos. All rights reserved.
//

#import "MenuScene.h"
#import "GameScene.h"
#import "AppDelegate.h"
//#import "ViewController.h"
//#import "CreateLevel.h"

@interface MenuScene ()
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic) SKLabelNode* loading;
@property (nonatomic) SKSpriteNode *info;
@property (nonatomic) SKSpriteNode *level_select;
@property (nonatomic) SKSpriteNode *create_level;
@property (nonatomic) SKSpriteNode *settings;
@property (nonatomic) SKSpriteNode *newgame;
@property (nonatomic) SKSpriteNode *music_btn;
@property (nonatomic) SKSpriteNode *sounds_btn;
@property (nonatomic) SKSpriteNode *difficulty_btn;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) id <sceneDelegate> delegate;

@end

@implementation MenuScene

SKSpriteNode *menu_btn;
SKSpriteNode *settings_btn;
SKSpriteNode *buy_btn;
SKSpriteNode *settings;
SKSpriteNode *music_onoff;
SKSpriteNode *difficulty_levels;
SKSpriteNode *purchase_ads;
SKSpriteNode *restore_purchases;
SKSpriteNode *level_select;
SKSpriteNode *create_level;
SKSpriteNode *cancel;
SKSpriteNode *info;
SKSpriteNode *itunes;

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        //ACTIONS
        SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:1.0],
                                               [SKAction fadeInWithDuration:1.0]]];
        //SKAction *blinkForTime = [SKAction repeatAction:blink count:4];
        SKAction *blinkForever = [SKAction repeatActionForever:blink];
        
        //SKAction *expand = [SKAction sequence:@[[SKAction scaleTo:1.2 duration:0.5],[SKAction scaleTo:1.0 duration:0.5]]];
        //SKAction *expandForever = [SKAction repeatActionForever:expand];

        [self.loading removeFromParent];
        
        //BACKGROUND
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"bkg"];
        //background.alpha=0.6;
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        background.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
        [self addChild:background];
        
        //NEW GAME
        //SKSpriteNode* new_game;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            self.newgame = [SKSpriteNode spriteNodeWithImageNamed:@"new_game@2x"]; //iPad
        } else {
            self.newgame = [SKSpriteNode spriteNodeWithImageNamed:@"new_game"]; //iPhone
        }
        [self.newgame setScale:1.0];
        self.newgame.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 2*(1.5*self.newgame.size.height));
        self.newgame.name = @"new_game";
        [self addChild:self.newgame];
        [self.newgame runAction:blinkForever];
        
        //TITLE
        SKSpriteNode* title;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            title = [SKSpriteNode spriteNodeWithImageNamed:@"title@2x"]; //iPad
            [title setScale:1.2];
        } else {
            title = [SKSpriteNode spriteNodeWithImageNamed:@"title"]; //iPhone
            [title setScale:1.2];
        }
        //background.alpha=0.6;
        if (self.frame.size.height < 1136) {
            title.position = CGPointMake(self.frame.size.width/2, self.newgame.position.y + 2*self.newgame.size.height);
        } else {
            title.position = CGPointMake(self.frame.size.width/2, 3*(self.frame.size.height/4));
        }
        //title.size = CGSizeMake(3*self.frame.size.width/5, self.frame.size.height/6);
        [self addChild:title];
        
        //LOADING
        self.loading = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
        self.loading.text = @"loading...";
        self.loading.fontColor = [SKColor orangeColor];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            self.loading.fontSize = 40; //iPad
        } else {
            self.loading.fontSize = 20; //iPhone
        }
        self.loading.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addChild:self.loading];
        self.loading.hidden = YES;

        //CREATE LEVEL
        //SKSpriteNode* create_level;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            self.create_level = [SKSpriteNode spriteNodeWithImageNamed:@"create_level@2x"]; //iPad
            //[self.create_level setScale:2.0];
        } else {
            self.create_level = [SKSpriteNode spriteNodeWithImageNamed:@"create_level"]; //iPhone
        }
        self.create_level.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.create_level.name = @"create_level";
        [self addChild:self.create_level];
        
        //LEVEL SELECT
        //SKSpriteNode* level_select;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            self.level_select = [SKSpriteNode spriteNodeWithImageNamed:@"level_select@2x"]; //iPad
            //[self.level_select setScale:2.0];
        } else {
            self.level_select = [SKSpriteNode spriteNodeWithImageNamed:@"level_select"]; //iPhone
        }
        //self.level_select.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 +10);
        self.level_select.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + (self.newgame.position.y-self.create_level.position.y)/2);
        self.level_select.name = @"level_select";
        [self addChild:self.level_select];
        
        //INFO
        //SKSpriteNode* info;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            self.info = [SKSpriteNode spriteNodeWithImageNamed:@"info@2x"]; //iPad
            //[self.info setScale:2.0];
        } else {
            self.info = [SKSpriteNode spriteNodeWithImageNamed:@"info"]; //iPhone
        }
        //self.info.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 -130);
        self.info.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - 2*(1.5*self.info.size.height));
        self.info.name = @"info";
        [self addChild:self.info];
        
        //SETTINGS
        //SKSpriteNode* settings;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            self.settings = [SKSpriteNode spriteNodeWithImageNamed:@"settings@2x"]; //iPad
            //[self.settings setScale:2.0];
        } else {
            self.settings = [SKSpriteNode spriteNodeWithImageNamed:@"settings"]; //iPhone
        }
        //self.settings.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 -60);
        self.settings.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - (self.create_level.position.y-self.info.position.y)/2);
        self.settings.name = @"settings";
        [self addChild:self.settings];
        
        //MUSIC
        [_appDelegate.controller.MUSIC_ON synchronize];
        if ([_appDelegate.controller.MUSIC_ON boolForKey:@"music_on"]) {
            [_appDelegate.controller stopMusic];
            [_appDelegate.controller playMusic:@"menu" type:@"mp3"];
        }

        
        //initialize current score as 0 for new games
        _appDelegate.current_score = 0;
        //initialize 3 lives for new games
        _appDelegate.lives = 3;

    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        
        if (n != self && [n.name isEqual: @"new_game"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showFullRev" object:nil];
            
            [self runAction:_appDelegate.tapSound];
            [self.info removeFromParent];
            [self.level_select removeFromParent];
            [self.create_level removeFromParent];
            [self.settings removeFromParent];
            self.loading.hidden = NO;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                //Background thread
                //Load scene here
                GameScene* startScene = [[GameScene alloc] initWithSize:self.frame.size level:1];
                [self.view presentScene:startScene transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
                
//                dispatch_async(dispatch_get_main_queue(), ^(void){
//                    //Main thread
//                    //callback here
//                });
            });
        }
        
        if (n != self && [n.name isEqual: @"create_level"]) {
            [self runAction:_appDelegate.tapSound];
            NSLog(@"Create Level");
            
            // perform segue from skscene
            //UIViewController *vc = self.view.window.rootViewController;
            //[vc performSegueWithIdentifier:@"createbutton" sender:nil];
            //[self.delegate showDifferentView];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showDifferentView" object:nil];
        }
        
        if (n != self && [n.name isEqual: @"settings"]) {
            [self runAction:_appDelegate.tapSound];
            //settings alert
            self.view.paused = NO;
            
            [self.info removeFromParent];
            [self.level_select removeFromParent];
            [self.create_level removeFromParent];
            [self.settings removeFromParent];
            [self.newgame removeFromParent];
            
            [menu_btn removeFromParent];
            [settings_btn removeFromParent];
            [buy_btn removeFromParent];
            
            
            //settings alert
            settings =[SKSpriteNode spriteNodeWithImageNamed:@"settings_label"];
            settings.position = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
            [self addChild:settings];
            
            //music on/off
            music_onoff =[SKSpriteNode spriteNodeWithImageNamed:@"music_onoff"];
            //music_onoff.position = CGPointMake(settings.position.x,settings.position.y+70);
            music_onoff.position = CGPointMake(settings.position.x,settings.position.y+20);
            [self addChild:music_onoff];
            
            //buttons
            if ([_appDelegate.controller.MUSIC_ON boolForKey:@"music_on"]) {
                [self toggleMusic:@"accept"];
            } else {
                [self toggleMusic:@"cancel"];
            }

            if ([_appDelegate.controller.SOUNDS_ON boolForKey:@"sounds_on"]) {
                [self toggleSounds:@"accept"];
            } else {
                [self toggleSounds:@"cancel"];
            }
            
            //changed to difficulty level
            difficulty_levels =[SKSpriteNode spriteNodeWithImageNamed:@"difficulty_levels"];
            difficulty_levels.position = CGPointMake(music_onoff.position.x,music_onoff.position.y-65);
            difficulty_levels.name = @"difficulty_levels";
            [self addChild:difficulty_levels];
            
            //buttons
            if ([[_appDelegate.controller.DIFFICULTY objectForKey:@"diff_level"]  isEqual: @"1"]) {
                [self toggleDifficulty:@"easy"];
            } else if ([[_appDelegate.controller.DIFFICULTY objectForKey:@"diff_level"]  isEqual: @"2"]) {
                [self toggleDifficulty:@"medium"];
            } else {
                [self toggleDifficulty:@"hard"];
            }
            /*
            purchase_ads =[SKSpriteNode spriteNodeWithImageNamed:@"purchase_ads"];
            purchase_ads.position = CGPointMake(settings.position.x,settings.position.y-60);
            purchase_ads.name = @"purchase_ads";
            [self addChild:purchase_ads];
            
            restore_purchases =[SKSpriteNode spriteNodeWithImageNamed:@"restore_purchases"];
            restore_purchases.position = CGPointMake(settings.position.x,settings.position.y-125);
            restore_purchases.name = @"restore_purchases";
            [self addChild:restore_purchases];
            */
            menu_btn =[SKSpriteNode spriteNodeWithImageNamed:@"menu_btn"];
            menu_btn.position = CGPointMake(settings.position.x-5+settings.frame.size.width/2,settings.position.y-5+settings.frame.size.height/2);
            menu_btn.name = @"menu_btn";
            [self addChild:menu_btn];

        }
        
        //change difficulty level
        if (n != self && [n.name isEqual: @"difficulty_levels"]) {
            self.view.paused = NO;
            [self runAction:_appDelegate.tapSound2];
            [self.difficulty_btn removeFromParent];
            NSLog(@"Difficulty Changed");
            if ([[_appDelegate.controller.DIFFICULTY objectForKey:@"diff_level"]  isEqual: @"1"]) {
                [self toggleDifficulty:@"medium"];
                [_appDelegate.controller.DIFFICULTY setObject:@"2" forKey:@"diff_level"];
                [_appDelegate.controller.DIFFICULTY synchronize];
            } else if ([[_appDelegate.controller.DIFFICULTY objectForKey:@"diff_level"]  isEqual: @"2"]) {
                [self toggleDifficulty:@"hard"];
                [_appDelegate.controller.DIFFICULTY setObject:@"3" forKey:@"diff_level"];
                [_appDelegate.controller.DIFFICULTY synchronize];
            } else {
                [self toggleDifficulty:@"easy"];
                [_appDelegate.controller.DIFFICULTY setObject:@"1" forKey:@"diff_level"];
                [_appDelegate.controller.DIFFICULTY synchronize];
            }
        }
        
        //buy
        if (n != self && [n.name isEqual: @"buy"]) {
            NSLog(@"Buy");
            self.view.paused = NO; //just to be able to tap
            [self performSelector:@selector(pauseScene) withObject:nil afterDelay:0.1];
            [self runAction:_appDelegate.tapSound2];
            [_appDelegate.controller unlock:@"BlustrickAllLevels"];
        }
        
        //purchases
        if (n != self && [n.name isEqual: @"purchase_ads"]) {
            NSLog(@"purchase");
            [self runAction:_appDelegate.tapSound2];
            [_appDelegate.controller unlock:@"BlustrickNoAds"];
        }
        
        if (n != self && [n.name isEqual: @"purchase_levels"]) {
            NSLog(@"purchase");
            [self runAction:_appDelegate.tapSound2];
            [_appDelegate.controller unlock:@"BlustrickAllLevels"];
        }
        
        //restore purchases
        if (n != self && [n.name isEqual: @"restore_purchases"]) {
            NSLog(@"restore");
            [self runAction:_appDelegate.tapSound2];
            [_appDelegate.controller restorePurchases];
        }
        
        if (n != self && [n.name isEqual: @"music_btn"]) {
            self.view.paused = NO;
            [self runAction:_appDelegate.tapSound2];
            [self.music_btn removeFromParent];
            if ([_appDelegate.controller.MUSIC_ON boolForKey:@"music_on"]) {
                [_appDelegate.controller.MUSIC_ON setBool:NO forKey:@"music_on"];
                [_appDelegate.controller stopMusic];
                [self toggleMusic:@"cancel"];
            } else {
                [_appDelegate.controller.MUSIC_ON setBool:YES forKey:@"music_on"];
                [self toggleMusic:@"accept"];
            }
        }
        
        if (n != self && [n.name isEqual: @"sounds_btn"]) {
            self.view.paused = NO;
            [self runAction:_appDelegate.tapSound2];
            [self.sounds_btn removeFromParent];
            if ([_appDelegate.controller.SOUNDS_ON boolForKey:@"sounds_on"]) {
                [_appDelegate.controller.SOUNDS_ON setBool:NO forKey:@"sounds_on"];
                [self toggleSounds:@"cancel"];
            } else {
                [_appDelegate.controller.SOUNDS_ON setBool:YES forKey:@"sounds_on"];
                [self toggleSounds:@"accept"];
            }
        }
        
        if (n != self && ([n.name isEqual: @"menu_btn"] || [n.name isEqual: @"cancel"])) {
            self.view.paused = NO;
            [self runAction:_appDelegate.tapSound2];
            MenuScene* menuScene = [[MenuScene alloc] initWithSize:self.frame.size];
            [self.view presentScene:menuScene transition:[SKTransition doorsCloseVerticalWithDuration:1.0]];
        }

        //level select
        if (n != self && [n.name isEqual: @"level_select"]) {
            self.view.paused = NO;
            [self runAction:_appDelegate.tapSound];
            //[_info removeFromParent];
            [self.info removeFromParent];
            [self.level_select removeFromParent];
            [self.create_level removeFromParent];
            [self.settings removeFromParent];
            [self.newgame removeFromParent];
            //level select
            level_select =[SKSpriteNode spriteNodeWithImageNamed:@"level_select_label"];
            level_select.position = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
            [self addChild:level_select];
            //cancel
            cancel = [SKSpriteNode spriteNodeWithImageNamed:@"cancel"];
            cancel.position = CGPointMake(level_select.position.x+level_select.frame.size.width/2 -15, level_select.position.y+level_select.frame.size.height/2 -15);
            cancel.name = @"cancel";
            [self addChild:cancel];
            
            //NSLog(@"cleared levels %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"cleared_levels"]);
            
            //50 levels, 7 each row, 8 rows
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            int k=1;
            for (int j=0; j<8; j++) {
                for (int i=0; i<7; i++) {
                    if (k <=50){
                        SKSpriteNode *lvl = [SKSpriteNode spriteNodeWithImageNamed:@"lvl"];
                        if (k==50) {
                            lvl.position =CGPointMake(self.frame.size.width/2 - (2+lvl.frame.size.width)/2 - (2+lvl.frame.size.width),level_select.position.y+150-j*(2+lvl.frame.size.height));
                        } else {
                            lvl.position =CGPointMake((level_select.position.x-level_select.frame.size.width/2+30) +i*(2+lvl.frame.size.width),level_select.position.y+150-j*(2+lvl.frame.size.height));
                        }
                        lvl.name = [NSString stringWithFormat:@"lvl_%i",k];
                        [self addChild:lvl];
                        
                        //level number
                        SKLabelNode *lvln = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
                        lvln.text = [NSString stringWithFormat:@"%i",k];
                        lvln.fontSize = 12;
                        lvln.position = CGPointMake(lvl.position.x,lvl.position.y-4);
                        lvln.name = [NSString stringWithFormat:@"lvln_%i",k];
                        lvln.fontColor = [SKColor blackColor];
                        [self addChild:lvln];
                        
                        
                        //check if level cleared
                        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"cleared_levels"] containsObject:[NSString stringWithFormat:@"%i",k]]){
                            SKSpriteNode *lvlclrd = [SKSpriteNode spriteNodeWithImageNamed:@"accept"];
                            [lvlclrd setScale:0.4];
                            lvlclrd.position = CGPointMake(lvl.position.x,lvl.position.y+lvl.frame.size.height/2);
                            [self addChild:lvlclrd];
                        }
                        
                        //lock icon
                        if (![[NSUserDefaults standardUserDefaults]boolForKey:@"BlustrickAllLevels"] && k>[[_appDelegate.controller.MAX_LEVEL objectForKey:@"max_level"]integerValue]) {
                            
                            //if (![[NSUserDefaults standardUserDefaults]boolForKey:@"BlustrickAllLevels"] && k>9) // changed from this line - prohibited more than 9 levels in the locked version
                            
                            SKSpriteNode *lock = [SKSpriteNode spriteNodeWithImageNamed:@"lock"];
                            lock.position = CGPointMake(lvl.position.x,lvl.position.y);
                            //[lock setScale:1.5];
                            [self addChild:lock];
                        }
                    
                        k++;
                    } else if (k == 51) {
                        SKSpriteNode *lvl = [SKSpriteNode spriteNodeWithImageNamed:@"lvl"];
                        lvl.position =CGPointMake(self.frame.size.width/2 - (2+lvl.frame.size.width)/2,level_select.position.y+150-j*(2+lvl.frame.size.height));
                        lvl.name = [NSString stringWithFormat:@"lvl_%i",k];
                        [self addChild:lvl];
                        
                        //level number
                        SKLabelNode *lvln = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
                        lvln.text = [NSString stringWithFormat:@"Shuffle"];
                        lvln.fontSize = 7;
                        lvln.position = CGPointMake(lvl.position.x,lvl.position.y-4);
                        lvln.name = [NSString stringWithFormat:@"lvln_%i",k];
                        lvln.fontColor = [SKColor blackColor];
                        [self addChild:lvln];
                        
                        k++;
                    } else if (k == 52) {
                        SKSpriteNode *lvl = [SKSpriteNode spriteNodeWithImageNamed:@"lvl"];
                        lvl.position =CGPointMake(self.frame.size.width/2 + (2+lvl.frame.size.width)/2,level_select.position.y+150-j*(2+lvl.frame.size.height));
                        lvl.name = [NSString stringWithFormat:@"lvl_%i",k];
                        [self addChild:lvl];
                        
                        //level number
                        SKLabelNode *lvln = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
                        lvln.text = [NSString stringWithFormat:@"?"];
                        lvln.fontSize = 14;
                        lvln.position = CGPointMake(lvl.position.x,lvl.position.y-4);
                        lvln.name = [NSString stringWithFormat:@"lvln_%i",k];
                        lvln.fontColor = [SKColor blackColor];
                        [self addChild:lvln];
                        
                        k++;
                    } else if (k == 53) {
                        SKSpriteNode *lvl = [SKSpriteNode spriteNodeWithImageNamed:@"lvl"];
                        lvl.position =CGPointMake(self.frame.size.width/2 + (2+lvl.frame.size.width)/2 + (2+lvl.frame.size.width),level_select.position.y+150-j*(2+lvl.frame.size.height));
                        lvl.name = [NSString stringWithFormat:@"lvl_%i",k];
                        [self addChild:lvl];
                        
                        //level number
                        SKLabelNode *lvln = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
                        lvln.text = [NSString stringWithFormat:@"Created"];
                        lvln.fontSize = 7;
                        lvln.position = CGPointMake(lvl.position.x,lvl.position.y-4);
                        lvln.name = [NSString stringWithFormat:@"lvln_%i",k];
                        lvln.fontColor = [SKColor blackColor];
                        [self addChild:lvln];
                        
                        k++;
                    }
                }
            }
            });
        }
        
        
        if (n != self && [n.name hasPrefix:@"lvln_"]) {
            self.view.paused = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showFullRev" object:nil];
            
            //get level number
            int curlvl = (int)[[n.name substringFromIndex:5]integerValue]; //"lvln_X" number X has index 5
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"BlustrickAllLevels"] || curlvl<=[[_appDelegate.controller.MAX_LEVEL objectForKey:@"max_level"]integerValue]) {
                //was curlvl<=9 before
                [self runAction:_appDelegate.tapSound];
                GameScene* startScene = [[GameScene alloc] initWithSize:self.frame.size level:curlvl];
                [self.view presentScene:startScene transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
            } else if (curlvl==51) { //added
                curlvl = [self generateRandomNumberBetweenMin:1 Max:[[_appDelegate.controller.MAX_LEVEL objectForKey:@"max_level"]integerValue]]; //was int tmp
                [self runAction:_appDelegate.tapSound];
                GameScene* startScene = [[GameScene alloc] initWithSize:self.frame.size level:curlvl]; // was tmp
                [self.view presentScene:startScene transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
            } else if (curlvl>=52) { //added
                [self runAction:_appDelegate.tapSound];
                GameScene* startScene = [[GameScene alloc] initWithSize:self.frame.size level:curlvl];
                [self.view presentScene:startScene transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
            } 
        }
        
        //info
        if (n != self && [n.name isEqual: @"info"]) {
            self.view.paused = NO;
            [self runAction:_appDelegate.tapSound];
            //[_info removeFromParent];
            [self.info removeFromParent];
            [self.level_select removeFromParent];
            [self.create_level removeFromParent];
            [self.settings removeFromParent];
            [self.newgame removeFromParent];
            info =[SKSpriteNode spriteNodeWithImageNamed:@"info_label"];
            info.position = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
            [self addChild:info];
            //cancel
            cancel = [SKSpriteNode spriteNodeWithImageNamed:@"cancel"];
            cancel.position = CGPointMake(info.position.x+info.frame.size.width/2 -15, info.position.y+info.frame.size.height/2 -15);
            cancel.name = @"cancel";
            [self addChild:cancel];
            //itunes
            itunes =[SKSpriteNode spriteNodeWithImageNamed:@"itunes"];
            itunes.position = CGPointMake(info.position.x, info.position.y-info.frame.size.height/3);
            itunes.name = @"itunes";
            [self addChild:itunes];
        }
        
        if (n != self && [n.name isEqual: @"itunes"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/artist/appmuumba/id871587578"]]; //changed
        }

    }
}

//generate random numbers within range
-(int)generateRandomNumberBetweenMin:(int)min Max:(int)max
{
    return ( (arc4random() % (max-min+1)) + min );
}

-(void)pauseScene{
    self.view.paused = YES;
}

-(void)toggleMusic:(NSString *)icon{
    self.music_btn = [SKSpriteNode spriteNodeWithImageNamed:icon];
    [self.music_btn setScale:0.7];
    self.music_btn.position = CGPointMake(music_onoff.position.x-75,music_onoff.position.y-15);
    self.music_btn.name = @"music_btn";
    [self addChild:self.music_btn];
}

-(void)toggleSounds:(NSString *)icon{
    self.sounds_btn = [SKSpriteNode spriteNodeWithImageNamed:icon];
    [self.sounds_btn setScale:0.7];
    self.sounds_btn.position = CGPointMake(music_onoff.position.x+65,music_onoff.position.y-15);
    self.sounds_btn.name = @"sounds_btn";
    [self addChild:self.sounds_btn];
}

-(void)toggleDifficulty:(NSString *)icon{
    //NSLog(@"%@",icon);
    self.difficulty_btn = [SKSpriteNode spriteNodeWithImageNamed:icon];
    [self.difficulty_btn setScale:0.9];
    self.difficulty_btn.position = CGPointMake(difficulty_levels.position.x,difficulty_levels.position.y-10);
    self.difficulty_btn.name = @"difficulty_levels";
    [self addChild:self.difficulty_btn];
}

@end
