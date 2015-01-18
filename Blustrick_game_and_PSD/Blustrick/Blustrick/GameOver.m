//
//  GameOver.m
//  Blustrick
//
//  Created by Zois Avgerinos on 7/15/14.
//  Copyright (c) 2014 Zois Avgerinos. All rights reserved.
//

#import "GameOver.h"
#import "AppDelegate.h"
#import "MenuScene.h"
#import "GameScene.h"

//class extension
@interface GameOver()
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic) SKAction *playSFX_gameover;
@property (nonatomic) SKAction *playSFX_gamewin;
@property (nonatomic) SKSpriteNode *background;
@property (nonatomic) SKSpriteNode *music_btn;
@property (nonatomic) SKSpriteNode *sounds_btn;
@property (nonatomic) SKSpriteNode *difficulty_btn;

@end

@implementation GameOver
SKLabelNode *current_level;
SKLabelNode *current_scr;
SKSpriteNode *game_complete;
SKSpriteNode *menu_btn;
SKSpriteNode *playagain_btn;
SKSpriteNode *settings_btn;
SKSpriteNode *buy_btn;
SKSpriteNode *settings;
SKSpriteNode *music_onoff;
SKSpriteNode *difficulty_levels;
SKSpriteNode *purchase_levels;
SKSpriteNode *purchase_ads;
SKSpriteNode *restore_purchases;

-(id)initWithSize:(CGSize)size level:(int)level isComplete:(BOOL)complete{
    self = [super initWithSize:size];
    if (self) {
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self addBackground:@"bkg"];
        if (!complete){
            self.playSFX_gameover = [SKAction playSoundFileNamed:@"gameover.caf" waitForCompletion:NO];
            [self runAction:self.playSFX_gameover];
            game_complete =[SKSpriteNode spriteNodeWithImageNamed:@"game_over"];
        } else {
            self.playSFX_gamewin = [SKAction playSoundFileNamed:@"gamewin.mp3" waitForCompletion:NO];
            [self runAction:self.playSFX_gamewin];
            game_complete =[SKSpriteNode spriteNodeWithImageNamed:@"game_complete"];
        }
        
        game_complete.position = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
        game_complete.name = @"game_complete";
        [self addChild:game_complete];
         
        //level
        if(!complete){
            current_level = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
            current_level.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            current_level.text = [NSString stringWithFormat:@"%i",level];
            current_level.fontSize = 14;
            current_level.position = CGPointMake(game_complete.position.x+15,game_complete.position.y+15); //needs to be changed
            current_level.fontColor = [SKColor blackColor];
            [self addChild:current_level];
        }
        
        //score
        current_scr = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
        current_scr.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        current_scr.text = [NSString stringWithFormat:@"%i",_appDelegate.current_score];
        current_scr.fontSize = 14;
        if (complete) {
            current_scr.position = CGPointMake(game_complete.position.x+15,game_complete.position.y+15);
        } else {
            current_scr.position = CGPointMake(game_complete.position.x+15,game_complete.position.y-10);
        }
        current_scr.fontColor = [SKColor blackColor];
        [self addChild:current_scr];
        
        //buttons
        menu_btn =[SKSpriteNode spriteNodeWithImageNamed:@"menu_btn"];
        menu_btn.position = CGPointMake(game_complete.position.x,game_complete.position.y+5-game_complete.frame.size.height/2);
        menu_btn.name = @"menu_btn";
        [self addChild:menu_btn];
        
        playagain_btn =[SKSpriteNode spriteNodeWithImageNamed:@"replay"];
        playagain_btn.position = CGPointMake(game_complete.position.x+50,game_complete.position.y+5-game_complete.frame.size.height/2);
        playagain_btn.name = @"playagain_btn";
        [self addChild:playagain_btn];
        
        settings_btn =[SKSpriteNode spriteNodeWithImageNamed:@"settings_btn"];
        settings_btn.position = CGPointMake(game_complete.position.x-50,game_complete.position.y+5-game_complete.frame.size.height/2);
        settings_btn.name = @"settings_btn";
        [self addChild:settings_btn];
        /*
        buy_btn =[SKSpriteNode spriteNodeWithImageNamed:@"buy"];
        buy_btn.position = CGPointMake(game_complete.position.x+100,game_complete.position.y+5-game_complete.frame.size.height/2);
        buy_btn.name = @"buy";
        [self addChild:buy_btn];
        */
        //MUSIC
        [_appDelegate.controller.MUSIC_ON synchronize];
        [_appDelegate.controller.MUSIC_ON synchronize];
        if ([_appDelegate.controller.MUSIC_ON boolForKey:@"music_on"]) {
            [_appDelegate.controller stopMusic];
            [_appDelegate.controller playMusic:@"gameover" type:@"mp3"];
        }


    }
    return self;
}

-(void)addBackground:(NSString *)image{
    //BACKGROUND
    self.background = [SKSpriteNode spriteNodeWithImageNamed:image];
    //background.alpha=0.6;
    self.background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.background.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    [self addChild:self.background];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *n = [self nodeAtPoint:touchLocation];
    
    if (n != self && [n.name isEqual: @"menu_btn"]) {
        self.view.paused = NO;
        [self runAction:_appDelegate.tapSound2];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFullRev" object:nil];
        MenuScene* menuScene = [[MenuScene alloc] initWithSize:self.frame.size];
        [self.view presentScene:menuScene transition:[SKTransition doorsCloseVerticalWithDuration:1.0]];
    }
    
    if (n != self && [n.name isEqual: @"playagain_btn"]) {
        self.view.paused = NO;
        [self runAction:_appDelegate.tapSound2];
        _appDelegate.lives = 3;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFullRev" object:nil];
        GameScene *startScene;
        NSLog(@"%i",[[_appDelegate.controller.CURRENT objectForKey:@"current_level"] integerValue]);
        if ([[_appDelegate.controller.CURRENT objectForKey:@"current_level"] integerValue] >= 51) {
            startScene = [[GameScene alloc] initWithSize:self.frame.size level:[[_appDelegate.controller.CURRENT objectForKey:@"current_level"] integerValue]];
        } else {
            startScene = [[GameScene alloc] initWithSize:self.frame.size level:1];
        }
        [self.view presentScene:startScene transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
    }
    
    if (n != self && [n.name isEqual: @"settings_btn"]) {
        [self runAction:_appDelegate.tapSound2];
        //settings alert
        self.view.paused = NO;
        [game_complete removeFromParent];
        [current_level removeFromParent];
        [current_scr removeFromParent];
        [menu_btn removeFromParent];
        [settings_btn removeFromParent];
        [playagain_btn removeFromParent];
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
        purchase_levels =[SKSpriteNode spriteNodeWithImageNamed:@"purchase_levels"];
        purchase_levels.position = CGPointMake(settings.position.x,settings.position.y+5);
        purchase_levels.name = @"purchase_levels";
        [self addChild:purchase_levels];
        
        purchase_ads =[SKSpriteNode spriteNodeWithImageNamed:@"purchase_ads"];
        purchase_ads.position = CGPointMake(settings.position.x,settings.position.y-60);
        purchase_ads.name = @"purchase_ads";
        [self addChild:purchase_ads];
        
        restore_purchases =[SKSpriteNode spriteNodeWithImageNamed:@"restore_purchases"];
        restore_purchases.position = CGPointMake(settings.position.x,settings.position.y-125);
        restore_purchases.name = @"restore_purchases";
        [self addChild:restore_purchases];
        */
        //menu_btn =[SKSpriteNode spriteNodeWithImageNamed:@"menu_btn"];
        //menu_btn.position = CGPointMake(settings.position.x-5+settings.frame.size.width/2,settings.position.y-5+settings.frame.size.height/2);
        //menu_btn.name = @"menu_btn";
        //[self addChild:menu_btn];
        
        menu_btn =[SKSpriteNode spriteNodeWithImageNamed:@"menu_btn"];
        menu_btn.position = CGPointMake(settings.position.x-55+settings.frame.size.width/2,settings.position.y-5+settings.frame.size.height/2);
        menu_btn.name = @"menu_btn";
        [self addChild:menu_btn];
        
        playagain_btn =[SKSpriteNode spriteNodeWithImageNamed:@"replay"];
        playagain_btn.position = CGPointMake(settings.position.x-5+settings.frame.size.width/2,settings.position.y-5+settings.frame.size.height/2);
        playagain_btn.name = @"playagain_btn";
        [self addChild:playagain_btn];
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
        self.view.paused = NO; //just to be able to tap
        [self performSelector:@selector(pauseScene) withObject:nil afterDelay:0.1];
        [self runAction:_appDelegate.tapSound2];
        [_appDelegate.controller unlock:@"BlustrickAllLevels"];
    }
    
    //purchases
    if (n != self && [n.name isEqual: @"purchase_ads"]) {
        [self runAction:_appDelegate.tapSound2];
        [_appDelegate.controller unlock:@"BlustrickNoAds"];
    }
    
    if (n != self && [n.name isEqual: @"purchase_levels"]) {
        [self runAction:_appDelegate.tapSound2];
        [_appDelegate.controller unlock:@"BlustrickAllLevels"];    }
    
    //restore purchases
    if (n != self && [n.name isEqual: @"restore_purchases"]) {
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
