//
//  GameScene.m
//  Blustrick
//
//  Created by Zois Avgerinos on 6/30/14.
//  Copyright (c) 2014 Zois Avgerinos. All rights reserved.
//

#import "GameScene.h"
#import "MenuScene.h"
#import "AppDelegate.h"
#import "GameOver.h"
#import "ViewController.h"

//class extension
@interface GameScene()
@property (nonatomic) SKSpriteNode *paddle;
@property (nonatomic) SKSpriteNode *right_arrow;
@property (nonatomic) SKSpriteNode *left_arrow;
@property (nonatomic) SKSpriteNode *ball; //use as self.ball or _ball
@property (nonatomic) SKSpriteNode *superball;
@property (nonatomic) SKSpriteNode *background;
@property (nonatomic) SKLabelNode *level;
@property (nonatomic) SKLabelNode *hi;
@property (nonatomic) SKLabelNode *score;
@property (nonatomic) SKSpriteNode *pause;
@property (nonatomic) SKSpriteNode *music_btn;
@property (nonatomic) SKSpriteNode *sounds_btn;
@property (nonatomic) SKSpriteNode *difficulty_btn;

@property (nonatomic) NSArray *gifts;

@property (nonatomic) SKAction *playSFX_paddle;
@property (nonatomic) SKAction *playSFX_brick;
@property (nonatomic) SKAction *playSFX_glass;
@property (nonatomic) SKAction *playSFX_metal;
@property (nonatomic) SKAction *playSFX_wall;
@property (nonatomic) SKAction *playSFX_lose;
@property (nonatomic) SKAction *playSFX_bullet;
@property (nonatomic) SKAction *playSFX_life;
@property (nonatomic) SKAction *playSFX_glue;
@property (nonatomic) SKAction *playSFX_crack;
@property (nonatomic) SKAction *playSFX_money;
@property (nonatomic) SKAction *playSFX_win;
@property (nonatomic) SKAction *playSFX_gameover;
@property (nonatomic) SKAction *playSFX_gamewin;
@property (nonatomic) SKAction *playSFX_extraball;
@property (nonatomic) SKAction *playSFX_superball;
@property (nonatomic) SKAction *playSFX_half;
@property (nonatomic) SKAction *playSFX_double;
@property (nonatomic) SKAction *playSFX_quit;

@property (nonatomic, strong) AppDelegate *appDelegate;

@end

//categories
static const uint32_t ballCategory = 1;               //00000000000000000000000000000001
//static const uint32_t ballCategory = 0x1;
static const uint32_t brickCategory = 2;              //00000000000000000000000000000010
//static const uint32_t brickCategory = 0x1 << 1;
static const uint32_t paddleCategory = 4;             //00000000000000000000000000000100
static const uint32_t edgeCategory = 8;               //00000000000000000000000000001000
static const uint32_t bottomEdgeCategory = 16;        //00000000000000000000000000010000
static const uint32_t giftCategory = 32;              //00000000000000000000000000100000

@implementation GameScene
SKSpriteNode *levelLabel;
NSArray* paddles;
NSUserDefaults *hi_score;
NSMutableArray *lives_array;

//quit alert
SKSpriteNode *quit_alert;
SKSpriteNode *accept_ok;
SKSpriteNode *cancel;

//level clear alert
SKSpriteNode *win;
SKLabelNode *current_level;
SKLabelNode *current_scr;
SKLabelNode *current_hiscr;
SKSpriteNode *menu_btn;
SKSpriteNode *playagain_btn;
SKSpriteNode *settings_btn;
SKSpriteNode *forward_btn;

//settings alert
SKSpriteNode *settings;
SKSpriteNode *music_onoff;
SKSpriteNode *difficulty_levels;
SKSpriteNode *purchase_levels;
SKSpriteNode *purchase_ads;
SKSpriteNode *restore_purchases;

NSTimer* repeat_bullets;

SKAction *blinkForever;

#pragma mark - Sprite Kit
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}
-(void)didEndContact:(SKPhysicsContact *)contact{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }

}
    
-(void)didBeginContact:(SKPhysicsContact *)contact{
    //This method passes you the two bodies that collide, but does not guarantee that they are passed in any particular order. So this bit of code just arranges them so they are sorted by their category bit masks so you can make some assumptions later.
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    //BALL HITS BRICKS
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == brickCategory) {

        //check metal
        if ([secondBody.node.name isEqualToString:@"metal_brick"]) {
            [self runAction:self.playSFX_metal];
            _appDelegate.current_score+=(difficulty_multiplier/2)*5;
            self.score.text = [NSString stringWithFormat:@"%i",_appDelegate.current_score];
            if ([firstBody.node.name isEqualToString:@"super_ball"]) {
                [secondBody.node removeFromParent];
            }
            return;
        }
        
        //if bullet remove it
        if ([firstBody.node.name isEqualToString:@"bullet"]) {
            [firstBody.node removeFromParent];
        }

        //remove brick
        [secondBody.node removeFromParent];
        
        //check win
        if ([self isLevelWon]) {
            
            //save it as cleared
            NSMutableArray *tmp = [[NSMutableArray alloc]initWithArray:[_appDelegate.controller.CLEARED_LEVELS objectForKey:@"cleared_levels"]];
            if (![tmp containsObject:self.level.text]) {
                [tmp addObject:self.level.text];
            }
            
            [_appDelegate.controller.CLEARED_LEVELS setObject:tmp forKey:@"cleared_levels"];
            
            //check if last level
            [_appDelegate.controller.MAX_LEVEL synchronize];
            int next_level = (int)[self.level.text integerValue] +1;
            
            if (next_level > 50){
                //if (next_level > [[_appDelegate.controller.MAX_LEVEL objectForKey:@"max_level"]integerValue])
                
                //GAME COMPLETE
                [self gameComplete];
                return;
            } else {
                //increment open levels / unlock new levels
                [_appDelegate.controller.MAX_LEVEL setObject:[NSString stringWithFormat:@"%d",next_level] forKey:@"max_level"];
            }
            
            [self runAction:self.playSFX_win];
            //pause
            [self performSelector:@selector(pauseScene) withObject:nil afterDelay:0.1];

            //win alert
            [_pause removeFromParent];
            
            //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                //win =[SKSpriteNode spriteNodeWithImageNamed:@"level_cleared@2x"]; //iPad
            //} else {
                win =[SKSpriteNode spriteNodeWithImageNamed:@"level_cleared"]; //iPhone
            //}
            win.position = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
            win.name = @"level_cleared";
            [self addChild:win];
            
            //hi-score
            current_hiscr = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
            current_hiscr.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            current_hiscr.text = self.hi.text;
            //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                //current_hiscr.fontSize = 14; //iPad //needs to be changed
                //current_hiscr.position = CGPointMake(win.position.x+30,win.position.y-20); //need to be changed
            //} else {
                current_hiscr.fontSize = 14; //iPhone
                current_hiscr.position = CGPointMake(win.position.x+15,win.position.y-10);
            //}
            current_hiscr.fontColor = [SKColor blackColor];
            [self addChild:current_hiscr];
            
            //score
            current_scr = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
            current_scr.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            current_scr.text = [NSString stringWithFormat:@"%i",_appDelegate.current_score]; //need to be changed
            //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                //current_scr.fontSize = 14; //iPad //needs to be changed
                //current_scr.position = CGPointMake(win.position.x+30,win.position.y+30); //need to be changed
            //} else {
                current_scr.fontSize = 14; //iPhone
                current_scr.position = CGPointMake(win.position.x+15,win.position.y+15);
            //}
            current_scr.fontColor = [SKColor blackColor];
            [self addChild:current_scr];
            
            //buttons
            //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                //menu_btn =[SKSpriteNode spriteNodeWithImageNamed:@"menu_btn@2x"]; //iPad
                //menu_btn.position = CGPointMake(win.position.x,win.position.y+10-win.frame.size.height/2); //need to be changed
            //} else {
                menu_btn =[SKSpriteNode spriteNodeWithImageNamed:@"menu_btn"]; // iPhone
                menu_btn.position = CGPointMake(win.position.x,win.position.y+5-win.frame.size.height/2);
            //}
            menu_btn.name = @"menu_btn";
            [self addChild:menu_btn];
            
            //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                //playagain_btn =[SKSpriteNode spriteNodeWithImageNamed:@"replay@2x"]; //iPad
                //playagain_btn.position = CGPointMake(win.position.x+100,win.position.y+10-win.frame.size.height/2); //need to be changed
            //} else {
                playagain_btn =[SKSpriteNode spriteNodeWithImageNamed:@"replay"]; //iPhone
                playagain_btn.position = CGPointMake(win.position.x+50,win.position.y+5-win.frame.size.height/2); //need to be changed
            //}
            playagain_btn.name = @"repeat_level";
            [self addChild:playagain_btn];
            
            //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                //settings_btn =[SKSpriteNode spriteNodeWithImageNamed:@"settings_btn@2x"]; //iPad
                //settings_btn.position = CGPointMake(win.position.x-100,win.position.y+10-win.frame.size.height/2); //need to be changed
            //} else {
                settings_btn =[SKSpriteNode spriteNodeWithImageNamed:@"settings_btn"]; //iPhone
                settings_btn.position = CGPointMake(win.position.x-50,win.position.y+5-win.frame.size.height/2); //need to be changed
            //}
            settings_btn.name = @"settings_btn";
            [self addChild:settings_btn];
            
            //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                //forward_btn =[SKSpriteNode spriteNodeWithImageNamed:@"forward@2x"]; //iPad
                //forward_btn.position = CGPointMake(win.position.x+200,win.position.y+10-win.frame.size.height/2); //need to be changed
            //} else {
                forward_btn =[SKSpriteNode spriteNodeWithImageNamed:@"forward"]; //iPhone
                forward_btn.position = CGPointMake(win.position.x+100,win.position.y+5-win.frame.size.height/2); //need to be changed
            //}
            forward_btn.name = @"forward";
            [self addChild:forward_btn];
            
            return;  //so as not to play last brick's SFX
        }

        //brick types
        if ([secondBody.node.name isEqualToString:@"normal_brick"] || [secondBody.node.name isEqualToString:@"broken_brick"]) {
            [self runAction:self.playSFX_brick];
            _appDelegate.current_score+=(difficulty_multiplier/2)*10;
        } else if ([secondBody.node.name isEqualToString:@"glass_brick"]) {
            [self runAction:self.playSFX_glass];
            _appDelegate.current_score+=(difficulty_multiplier/2)*20;
            
            //gifts are random
            NSUInteger randomMove = arc4random() % [_gifts count];
            NSString *rand_gift = [_gifts objectAtIndex:randomMove];
            SKSpriteNode *gift;
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                gift = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%@%@",rand_gift,@"@2x"]];
            } else {
                gift = [SKSpriteNode spriteNodeWithImageNamed:rand_gift];
            }
            
            //position
            gift.position = CGPointMake(secondBody.node.position.x,secondBody.node.position.y);
            
            gift.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:gift.frame.size];
            gift.physicsBody.allowsRotation = NO;
            gift.physicsBody.dynamic = YES;
            gift.physicsBody.friction = 0.0f;
            gift.name = rand_gift;
            gift.physicsBody.categoryBitMask = giftCategory;
            
            gift.physicsBody.contactTestBitMask = paddleCategory;
            gift.physicsBody.collisionBitMask = 0;
            
            [self addChild:gift];
            //push it down
            [gift.physicsBody applyImpulse:CGVectorMake(0.0f, -ipad_multiplier*7.0f)];
        } else if ([secondBody.node.name isEqualToString:@"bold_brick"]) {
            [self runAction:self.playSFX_crack];
            _appDelegate.current_score+=(difficulty_multiplier/2)*30;
            float xpos = secondBody.node.position.x;
            float ypos = secondBody.node.position.y;
            [secondBody.node removeFromParent];
            
            SKSpriteNode *brokenbrick;
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                brokenbrick = [SKSpriteNode spriteNodeWithImageNamed:@"broken_brick@2x"];
            } else {
                brokenbrick = [SKSpriteNode spriteNodeWithImageNamed:@"broken_brick"];
            }
            brokenbrick.size = CGSizeMake((self.frame.size.width-7)/7, ((self.frame.size.width-7)/7)/2);
            brokenbrick.position = CGPointMake(xpos, ypos);
            brokenbrick.name = @"broken_brick";
            //[brokenbrick setScale:0.25];
            brokenbrick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brokenbrick.frame.size];
            brokenbrick.physicsBody.dynamic = NO;
            //category
            brokenbrick.physicsBody.categoryBitMask = brickCategory;
            [self addChild:brokenbrick];
            
            //return so as not to have the emitter effect in bold bricks
            return;
        }
        //break effect
        NSString* sksPath = [[NSBundle mainBundle]pathForResource:@"spark" ofType:@"sks"];
        SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:sksPath];
        emitter.position = secondBody.node.position;
        emitter.numParticlesToEmit = 3;
        //advance effect so you can see it immediately
        //[emitter advanceSimulationTime:10.0];
        [self addChild:emitter];
        
    }
    
    //BALL HITS PADDLE
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory) {
        //NSLog(@"hit paddle");
        [self runAction:self.playSFX_paddle withKey:@"sfx"];
        SKAction *compress = [SKAction sequence:@[[SKAction scaleTo:0.9 duration:0.2],
                                                  [SKAction scaleTo:1.0 duration:0.2]]];
        [_paddle runAction:compress];
        
        if ([secondBody.node.name isEqualToString:@"glue_paddle"] || [secondBody.node.name isEqualToString:@"glue_paddle@2x"]) {
                [self runAction:self.playSFX_glue];
                firstBody.velocity = CGVectorMake(0.0f, 0.0f);
        }
    }
    
    //BALL HITS BOTTOM
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomEdgeCategory) {
        //check how many balls we have
        int numballs=0;
        for (SKNode* node in self.children) {
            if ([node.name isEqualToString:@"white_ball"] || [node.name isEqualToString:@"super_ball"]){
                numballs++;
            }
        }
        if (numballs>1) {
            [firstBody.node removeFromParent];
            return;
        }

        if (![firstBody.node.name isEqualToString:@"bullet"]) {
            _appDelegate.lives--;
            
            if (_appDelegate.lives == -1) {
                //GAME OVER
                [self gameOver];
            }else{
                [self runAction:self.playSFX_lose];
                
                //remove one life image
                SKSpriteNode *removelife = [lives_array lastObject];
                [removelife removeFromParent];
                //also remove from array
                [lives_array removeObjectAtIndex:[lives_array count]-1];
                
                //initial position
                [self resetBallAndPaddle];
            }
        } else {
            _appDelegate.current_score-=(5-(difficulty_multiplier/2))*10;
        }
    }
    
    //BALL HITS EDGES
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == edgeCategory) {
        [self runAction:self.playSFX_wall];
        _appDelegate.current_score+=(difficulty_multiplier/2)*1;
    }
    
    //GIFTS HIT PADDLE
    if (firstBody.categoryBitMask == paddleCategory && secondBody.categoryBitMask == giftCategory) {
        //remove gift
        [contact.bodyA.node removeFromParent];
        
        //change paddle
        if ([secondBody.node.name isEqualToString:@"double_gift"] || [secondBody.node.name isEqualToString:@"half_gift"] || [secondBody.node.name isEqualToString:@"magnet"] || [secondBody.node.name isEqualToString:@"bullet_gift"]) {
            [self changePaddle:secondBody.node.name];
        }
        
        //extra life up to total 6 (changed to 12 below)
        if ([secondBody.node.name isEqualToString:@"life"]){
            if ([lives_array count]<12) {
                [self runAction:self.playSFX_life];
                SKSpriteNode* life = [SKSpriteNode spriteNodeWithImageNamed:@"white_ball"]; // may need to be changed with below - check first
                //life.name = [NSString stringWithFormat:@"life_%i",i];
                SKSpriteNode* tmp = [lives_array lastObject];
                [life setScale:0.7];
                life.position = CGPointMake(tmp.position.x+tmp.frame.size.width-3,tmp.position.y);
                _appDelegate.lives++;
                [self addChild:life];
                [lives_array addObject:life];
            }
        }
        
        //cash
        if ([secondBody.node.name isEqualToString:@"coin_gift"]){
            [self runAction:self.playSFX_money];
            _appDelegate.current_score+=(difficulty_multiplier/2)*500;
        }
        
        //superball gift
        if ([secondBody.node.name isEqualToString:@"superball"]){
            //only one superball allowed
            for (SKNode* node in self.children) {
                if ([node.name isEqualToString:@"super_ball"]){
                    return;
                }
            }
            
            [self runAction:self.playSFX_superball];

            float xpos = _ball.position.x;
            float ypos = _ball.position.y;
            [_ball removeFromParent];
            
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                self.superball = [SKSpriteNode spriteNodeWithImageNamed:@"red_ball@2x"]; //ipad
                [self.superball setScale:0.7]; //needs to be changed
            } else {
                self.superball = [SKSpriteNode spriteNodeWithImageNamed:@"red_ball"]; //iphone
                [self.superball setScale:0.7];
            }
            self.superball.name = @"super_ball";
            //position center
            self.superball.position = CGPointMake(xpos,ypos);
            //physics will be a circle
            self.superball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.superball.frame.size.width/2];
            //friction. use 0 to avoid oscillations
            self.superball.physicsBody.friction = 0.0f;
            //air friction
            self.superball.physicsBody.linearDamping = 0.0f;
            //bounciness. elastic collision has restitution 1
            self.superball.physicsBody.restitution = 1.0f;
            //category
            self.superball.physicsBody.categoryBitMask = ballCategory;
            //notify against
            self.superball.physicsBody.contactTestBitMask = paddleCategory | brickCategory | bottomEdgeCategory | edgeCategory;
            //collision
            //interact with
            self.superball.physicsBody.collisionBitMask = paddleCategory | edgeCategory | bottomEdgeCategory;
            //add to scene
            [self addChild:self.superball];
            
            [self.superball.physicsBody applyImpulse:CGVectorMake(ipad_multiplier*5,ipad_multiplier*5)];//top right 45deg

        }
        
        //extra balls
        if ([secondBody.node.name isEqualToString:@"extraball"]){
            [self runAction:self.playSFX_extraball];
            
            //random number of extra balls up to 5
            for (int i=0; i<[self generateRandomNumberBetweenMin:1 Max:5]; i++) {
                [self addBall:self.frame.size kick:YES];
                
            }
        }
    }
    
    //hi-score
    NSNumber *current_hiscore = [hi_score objectForKey:@"hi_score"];
    if (_appDelegate.current_score > [current_hiscore intValue]) {
        [hi_score setObject:[NSNumber numberWithInt:_appDelegate.current_score] forKey:@"hi_score"];
        [hi_score synchronize];
        [self.hi setText:[NSString stringWithFormat:@"%i",_appDelegate.current_score]];
    }
    
    self.score.text = [NSString stringWithFormat:@"%i",_appDelegate.current_score];

}

#pragma mark - Methods

-(void)gameOver{
    GameOver* gameover = [[GameOver alloc] initWithSize:self.frame.size level:(int)[self.level.text integerValue] isComplete:NO];
    [self.view presentScene:gameover transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
}

-(void)gameComplete{
    GameOver* complete = [[GameOver alloc] initWithSize:self.frame.size level:(int)[self.level.text integerValue] isComplete:YES];
    [self.view presentScene:complete transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
}

-(void)pauseScene{
    self.view.paused = YES;
}

-(void)resetBallAndPaddle{
    [_ball removeFromParent];
    [_superball removeFromParent];
    [_paddle removeFromParent];
    [_left_arrow removeFromParent];
    [_right_arrow removeFromParent];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [self addPaddle:self.size type:@"main_paddle@2x" x:CGRectGetMidX(self.frame) y:100];
    } else {
        [self addPaddle:self.size type:@"main_paddle" x:CGRectGetMidX(self.frame) y:100];
    }
    [self addBall:self.size kick:NO];

}

-(void)removeBallAndPaddle{
    for (SKNode* node in self.children) {
        if ([node.name isEqualToString:@"white_ball"] || [node.name isEqualToString:@"super_ball"] || node.physicsBody.categoryBitMask == paddleCategory){
            [node removeFromParent];
        }
    }
    [_left_arrow removeFromParent];
    [_right_arrow removeFromParent];
}

-(void)changePaddle:(NSString *)type{
    //save position
    float x = _paddle.position.x;
    float y = _paddle.position.y;
    [_paddle removeFromParent];
    [_right_arrow removeFromParent];
    [_left_arrow removeFromParent];
    
    if ([type isEqualToString:@"double_gift"]) {
        [self runAction:self.playSFX_double];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            [self addPaddle:self.frame.size type:@"double_paddle@2x" x:x y:y];
        } else {
            [self addPaddle:self.frame.size type:@"double_paddle" x:x y:y];
        }
    }else if ([type isEqualToString:@"half_gift"]) {
        [self runAction:self.playSFX_half];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            [self addPaddle:self.frame.size type:@"half_paddle@2x" x:x y:y];
        } else {
            [self addPaddle:self.frame.size type:@"half_paddle" x:x y:y];
        }
    }else if ([type isEqualToString:@"bullet_gift"]) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            [self addPaddle:self.frame.size type:@"bullet_paddle@2x" x:x y:y];
        } else {
            [self addPaddle:self.frame.size type:@"bullet_paddle" x:x y:y];
        }
        [self runAction:self.playSFX_bullet];
        repeat_bullets = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                          target: self
                                                        selector: @selector(fire)
                                                        userInfo: nil
                                                         repeats: YES];
        
    }else if ([type isEqualToString:@"magnet"]) {
        [self runAction:self.playSFX_glue];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            [self addPaddle:self.frame.size type:@"glue_paddle@2x" x:x y:y];
        } else {
            [self addPaddle:self.frame.size type:@"glue_paddle" x:x y:y];
        }
    }
}

//generate random numbers within range
-(int)generateRandomNumberBetweenMin:(int)min Max:(int)max
{
    return ( (arc4random() % (max-min+1)) + min );
}

-(BOOL)isLevelWon {
    int numberOfBricks = 0;
    for (SKNode* node in self.children) {
        
        if (node.physicsBody.categoryBitMask == brickCategory && ![node.name isEqualToString:@"metal_brick"]){
            numberOfBricks++;
        }
    }
    return (numberOfBricks <= 0);
}

-(void)fire{
    [self runAction:self.playSFX_bullet];
    
    SKSpriteNode* bullet;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
         bullet = [SKSpriteNode spriteNodeWithImageNamed:@"bullet@2x"];
    } else {
         bullet = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
    }
    
    //position
    int offset = 0;
    int tmp = [self generateRandomNumberBetweenMin:0 Max:2];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        if (tmp==0) {
            offset = 0; //may need to be changed
        }else if (tmp==1){
            offset=100;  //may need to be changed
        }else{
            offset=-100; //may need to be changed
        }
    } else {
        if (tmp==0) {
            offset = 0; //may need to be changed
        }else if (tmp==1){
            offset=50;  //may need to be changed
        }else{
            offset=-50; //may need to be changed
        }
    }
    bullet.position = CGPointMake(_paddle.position.x+offset,_paddle.position.y);
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.frame.size];
    bullet.physicsBody.allowsRotation = NO;
    bullet.physicsBody.dynamic = YES;
    bullet.physicsBody.friction = 0.0f;
    bullet.name = @"bullet";
    bullet.physicsBody.categoryBitMask = ballCategory;//have the same effects as balls
    
    bullet.physicsBody.contactTestBitMask = brickCategory;
    bullet.physicsBody.collisionBitMask = brickCategory;
    
    [self addChild:bullet];
    //push it up
    [bullet.physicsBody applyImpulse:CGVectorMake(0.0f, ipad_multiplier*5.0f)];
}

#pragma mark - Add Elements
- (void)addBall:(CGSize)size kick:(BOOL)kick{
    /* Setup ball */
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        self.ball = [SKSpriteNode spriteNodeWithImageNamed:@"white_ball@2x"]; //ipad
    } else {
        self.ball = [SKSpriteNode spriteNodeWithImageNamed:@"white_ball"]; //iphone
    }
    self.ball.name = @"white_ball";
    [self.ball setScale:0.7]; //may need to be changed
    //position center
    self.ball.position = CGPointMake(size.width/2, _paddle.position.y+_paddle.frame.size.height);
    //physics will be a circle
    self.ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.ball.frame.size.width/2];
    //friction. use 0 to avoid oscillations
    self.ball.physicsBody.friction = 0.0f;
    //air friction
    self.ball.physicsBody.linearDamping = 0.0f;
    //bounciness. elastic collision has restitution 1
    self.ball.physicsBody.restitution = 1.0f;
    //category
    self.ball.physicsBody.categoryBitMask = ballCategory;
    //notify against
    self.ball.physicsBody.contactTestBitMask = paddleCategory | brickCategory | bottomEdgeCategory | edgeCategory;
    //collision
    //interact only with bricks and paddle
    self.ball.physicsBody.collisionBitMask = brickCategory | paddleCategory | edgeCategory | bottomEdgeCategory; //pass through gifts!
    
    //add to scene
    [self addChild:self.ball];
    
    if (kick) {
    //kick it
    [self.ball.physicsBody applyImpulse:CGVectorMake(ipad_multiplier*3.0*[self generateRandomNumberBetweenMin:-3 Max:5]/4, ipad_multiplier*3.0*[self generateRandomNumberBetweenMin:3 Max:5]/4)];//top right
    }
    

}

-(void)addPaddle:(CGSize)size type:(NSString*)type x:(float)x y:(float)y{
    
    [repeat_bullets invalidate];
    repeat_bullets=nil;

    //create paddle sprite
    self.paddle = [SKSpriteNode spriteNodeWithImageNamed:type]; // may need to be changed
    self.paddle.name = type;
    self.paddle.position = CGPointMake(x, y);
    //self.paddle.position = CGPointMake(size.width/2, 100);
    //add physics body
    self.paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.paddle.frame.size];
    //make it static
    self.paddle.physicsBody.dynamic = NO;
    //category
    self.paddle.physicsBody.categoryBitMask = paddleCategory;
    
    //extra image beneath it to show where to touch
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        self.right_arrow = [SKSpriteNode spriteNodeWithImageNamed:@"arrow_right@2x"]; //ipad
        self.right_arrow.position = CGPointMake(self.paddle.position.x+40, self.paddle.position.y-50);
        [self.right_arrow setScale:0.8];
        [self addChild:self.right_arrow];
        self.left_arrow = [SKSpriteNode spriteNodeWithImageNamed:@"arrow_left@2x"];
        self.left_arrow.position = CGPointMake(self.paddle.position.x-40, self.paddle.position.y-50);
        [self.left_arrow setScale:0.8];
        [self addChild:self.left_arrow];
    } else {
        self.right_arrow = [SKSpriteNode spriteNodeWithImageNamed:@"arrow_right"]; //iphone
        self.right_arrow.position = CGPointMake(self.paddle.position.x+20, self.paddle.position.y-25);
        [self addChild:self.right_arrow];
        self.left_arrow = [SKSpriteNode spriteNodeWithImageNamed:@"arrow_left"];
        self.left_arrow.position = CGPointMake(self.paddle.position.x-20, self.paddle.position.y-25);
        [self addChild:self.left_arrow];
    }
    [self.right_arrow runAction:blinkForever];
    [self.left_arrow runAction:blinkForever];
    
    //add to scene
    [self addChild:self.paddle];
    
}

-(void)createBricks:(NSArray *)type{
    SKSpriteNode *brick;
    int k=0;
    for (int i=0; i<7; i++) {
        for (int j=0; j<7; j++) {
            
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                if ([type count]>k && i==[[type objectAtIndex:k]integerValue] && j==[[type objectAtIndex:k+1]integerValue]) {
                    //we pass the name as "none" in order to skip a brick
                    if ([[type objectAtIndex:k+2] isEqualToString:@"none"]) {
                        k=k+3;
                        continue;
                    }
                    brick = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%@%@",[type objectAtIndex:k+2],@"@2x"]];
                    brick.name=[type objectAtIndex:k+2];
                    k=k+3;
                } else {
                    brick = [SKSpriteNode spriteNodeWithImageNamed:@"normal_brick@2x"];
                    brick.name=@"normal_brick";
                }
                //[brick setScale:0.25];
            } else {
                if ([type count]>k && i==[[type objectAtIndex:k]integerValue] && j==[[type objectAtIndex:k+1]integerValue]) {
                    //we pass the name as "none" in order to skip a brick
                    if ([[type objectAtIndex:k+2] isEqualToString:@"none"]) {
                        k=k+3;
                        continue;
                    }
                    brick = [SKSpriteNode spriteNodeWithImageNamed:[type objectAtIndex:k+2]];
                    brick.name=[type objectAtIndex:k+2];
                    k=k+3;
                } else {
                    brick = [SKSpriteNode spriteNodeWithImageNamed:@"normal_brick"];
                    brick.name=@"normal_brick";
                }
                //[brick setScale:0.25];
            }
            brick.size = CGSizeMake((self.frame.size.width-7)/7, ((self.frame.size.width-7)/7)/2);
            
            //static physics body
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
            brick.physicsBody.dynamic = NO;
            //category
            brick.physicsBody.categoryBitMask = brickCategory;
            //position
            int xPos = (brick.frame.size.width/2)+3.5+i*brick.frame.size.width;
            //int yPos = (self.frame.size.height - 100)-j*25;
            int yPos;
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                yPos = (self.frame.size.height - 150)-j*brick.frame.size.height; //200 seemed too big
            } else {
                yPos = (self.frame.size.height - 100)-j*brick.frame.size.height;
            }
            brick.position = CGPointMake(xPos, yPos);
            [self addChild:brick];
        }
    }
}

-(void)addBricks:(CGSize)size level:(int)level{
    NSArray *type;
    NSMutableArray *tmp_array;
    NSArray *icons;
    NSArray *myArray;
    NSString *background_num;
    NSString *background_img;
    
    [_appDelegate.controller.CURRENT setObject:[NSString stringWithFormat:@"%i",level] forKey:@"current_level"];
    [_appDelegate.controller.CURRENT synchronize];
    
    switch (level) {
        case 1:
            [self addBackground:@"bkg1"];
            type = [[NSArray alloc]initWithObjects:@"3",@"1",@"glass_brick",@"3",@"2",@"glass_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"glass_brick",@"3",@"5",@"glass_brick",nil];
            break;
        case 2:
            [self addBackground:@"bkg1"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"metal_brick",@"0",@"6",@"metal_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"bold_brick",@"2",@"2",@"glass_brick",@"2",@"4",@"glass_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"bold_brick",@"3",@"3",@"metal_brick",@"3",@"4",@"bold_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"bold_brick",@"4",@"2",@"glass_brick",@"4",@"4",@"glass_brick",@"5",@"2",@"bold_brick",@"5",@"3",@"bold_brick",@"5",@"4",@"bold_brick",@"6",@"0",@"metal_brick",@"6",@"6",@"metal_brick",nil];
            break;
        case 3:
            [self addBackground:@"bkg1"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"normal_brick",@"0",@"1",@"normal_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"normal_brick",@"0",@"4",@"normal_brick",@"0",@"5",@"normal_brick",@"0",@"6",@"normal_brick",@"1",@"0",@"none",@"1",@"1",@"bold_brick",@"1",@"2",@"glass_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"normal_brick",@"1",@"5",@"normal_brick",@"1",@"6",@"normal_brick",@"2",@"0",@"none",@"2",@"1",@"none",@"2",@"2",@"bold_brick",@"2",@"3",@"glass_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"normal_brick",@"2",@"6",@"normal_brick",@"3",@"0",@"none",@"3",@"1",@"none",@"3",@"2",@"none",@"3",@"3",@"bold_brick",@"3",@"4",@"glass_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"normal_brick",@"4",@"0",@"none",@"4",@"1",@"none",@"4",@"2",@"none",@"4",@"3",@"none",@"4",@"4",@"bold_brick",@"4",@"5",@"glass_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"none",@"5",@"1",@"none",@"5",@"2",@"none",@"5",@"3",@"none",@"5",@"4",@"none",@"5",@"5",@"bold_brick",@"5",@"6",@"normal_brick",@"6",@"0",@"none",@"6",@"1",@"none",@"6",@"2",@"none",@"6",@"3",@"none",@"6",@"4",@"none",@"6",@"5",@"none",@"6",@"6",@"normal_brick",nil];
            break;

        case 4:
            [self addBackground:@"bkg1"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"normal_brick",@"0",@"1",@"glass_brick",@"1",@"0",@"metal_brick",@"1",@"1",@"metal_brick",@"1",@"2",@"metal_brick",@"2",@"1",@"glass_brick",@"2",@"4",@"glass_brick",@"3",@"0",@"metal_brick",@"3",@"1",@"metal_brick",@"3",@"2",@"metal_brick",@"3",@"3",@"bold_brick",@"3",@"4",@"metal_brick",@"3",@"5",@"metal_brick",@"3",@"6",@"metal_brick",@"4",@"1",@"glass_brick",@"4",@"4",@"glass_brick",@"5",@"0",@"metal_brick",@"5",@"1",@"metal_brick",@"5",@"2",@"metal_brick",@"6",@"1",@"glass_brick",nil];
            break;
        case 5:
            [self addBackground:@"bkg1"];
            type = [[NSArray alloc]initWithObjects:@"0",@"3",@"bold_brick",@"1",@"1",@"glass_brick",@"1",@"3",@"bold_brick",@"1",@"5",@"glass_brick",@"2",@"3",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"bold_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"bold_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"bold_brick",@"4",@"3",@"bold_brick",@"5",@"1",@"glass_brick",@"5",@"3",@"bold_brick",@"5",@"5",@"glass_brick",@"6",@"3",@"bold_brick",nil];
            break;
        case 6:
            [self addBackground:@"bkg2"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"1",@"none",@"1",@"2",@"none",@"1",@"3",@"none",@"1",@"4",@"none",@"1",@"5",@"none",@"2",@"1",@"none",@"2",@"3",@"bold_brick",@"2",@"5",@"none",@"3",@"1",@"none",@"3",@"2",@"bold_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"bold_brick",@"3",@"5",@"none",@"4",@"1",@"none",@"4",@"3",@"bold_brick",@"4",@"5",@"none",@"5",@"1",@"none",@"5",@"2",@"none",@"5",@"3",@"none",@"5",@"4",@"none",@"5",@"5",@"none",@"6",@"0",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 7:
            [self addBackground:@"bkg2"];
            type = [[NSArray alloc]initWithObjects:@"1",@"1",@"bold_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"bold_brick",@"1",@"5",@"bold_brick",@"2",@"1",@"metal_brick",@"2",@"2",@"metal_brick",@"2",@"3",@"metal_brick",@"2",@"4",@"metal_brick",@"2",@"5",@"bold_brick",@"3",@"1",@"glass_brick",@"3",@"2",@"glass_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"metal_brick",@"3",@"5",@"bold_brick",@"4",@"3",@"glass_brick",@"4",@"4",@"metal_brick",@"4",@"5",@"bold_brick",@"5",@"3",@"glass_brick",@"5",@"4",@"metal_brick",@"5",@"5",@"bold_brick",nil];
            break;
        case 8:
            [self addBackground:@"bkg2"];
            type = [[NSArray alloc]initWithObjects:@"0",@"1",@"none",@"0",@"3",@"none",@"0",@"5",@"none",@"1",@"1",@"none",@"1",@"2",@"metal_brick",@"1",@"3",@"none",@"1",@"5",@"none",@"1",@"6",@"metal_brick",@"2",@"0",@"glass_brick",@"2",@"1",@"none",@"2",@"3",@"none",@"2",@"5",@"none",@"3",@"0",@"bold_brick",@"3",@"1",@"none",@"3",@"3",@"none",@"3",@"4",@"metal_brick",@"3",@"5",@"none",@"4",@"0",@"glass_brick",@"4",@"1",@"none",@"4",@"3",@"none",@"4",@"5",@"none",@"5",@"1",@"none",@"5",@"2",@"metal_brick",@"5",@"3",@"none",@"5",@"5",@"none",@"5",@"6",@"metal_brick",@"6",@"1",@"none",@"6",@"3",@"none",@"6",@"5",@"none",nil];
            break;
        case 9:
            [self addBackground:@"bkg2"];
            type = [[NSArray alloc]initWithObjects:@"1",@"1",@"metal_brick",@"1",@"2",@"metal_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"metal_brick",@"1",@"5",@"metal_brick",@"2",@"1",@"metal_brick",@"2",@"2",@"glass_brick",@"2",@"3",@"glass_brick",@"2",@"4",@"glass_brick",@"2",@"5",@"metal_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"glass_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"glass_brick",@"3",@"5",@"bold_brick",@"4",@"1",@"metal_brick",@"4",@"2",@"glass_brick",@"4",@"3",@"glass_brick",@"4",@"4",@"glass_brick",@"4",@"5",@"metal_brick",@"5",@"1",@"metal_brick",@"5",@"2",@"metal_brick",@"5",@"3",@"bold_brick",@"5",@"4",@"metal_brick",@"5",@"5",@"metal_brick",nil];
            break;
        case 10:
            [self addBackground:@"bkg2"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"1",@"glass_brick",@"1",@"3",@"metal_brick",@"1",@"5",@"glass_brick",@"2",@"1",@"bold_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"metal_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"metal_brick",@"3",@"5",@"bold_brick",@"4",@"1",@"bold_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"bold_brick",@"5",@"1",@"glass_brick",@"5",@"3",@"metal_brick",@"5",@"5",@"glass_brick",@"6",@"0",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 11:
            [self addBackground:@"bkg3"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"glass_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"metal_brick",@"0",@"4",@"bold_brick",@"0",@"6",@"glass_brick",@"1",@"0",@"none",@"1",@"1",@"none",@"1",@"2",@"none",@"1",@"3",@"none",@"1",@"4",@"none",@"1",@"5",@"none",@"1",@"6",@"none",@"2",@"0",@"glass_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"metal_brick",@"2",@"4",@"bold_brick",@"2",@"6",@"glass_brick",@"3",@"0",@"none",@"3",@"1",@"none",@"3",@"2",@"none",@"3",@"3",@"none",@"3",@"4",@"none",@"3",@"5",@"none",@"3",@"6",@"none",@"4",@"0",@"glass_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"metal_brick",@"4",@"4",@"bold_brick",@"4",@"6",@"glass_brick",@"5",@"0",@"none",@"5",@"1",@"none",@"5",@"2",@"none",@"5",@"3",@"none",@"5",@"4",@"none",@"5",@"5",@"none",@"5",@"6",@"none",@"6",@"0",@"glass_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"metal_brick",@"6",@"4",@"bold_brick",@"6",@"6",@"glass_brick",nil];
            break;
        case 12:
            [self addBackground:@"bkg3"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"glass_brick",@"1",@"0",@"none",@"1",@"1",@"none",@"1",@"2",@"none",@"1",@"3",@"none",@"1",@"4",@"none",@"1",@"5",@"none",@"2",@"5",@"none",@"3",@"1",@"none",@"3",@"2",@"none",@"3",@"3",@"none",@"3",@"5",@"none",@"4",@"1",@"none",@"4",@"2",@"glass_brick",@"4",@"5",@"none",@"5",@"1",@"none",@"5",@"2",@"none",@"5",@"3",@"none",@"5",@"4",@"none",@"5",@"5",@"none",nil];
            break;
        case 13:
            [self addBackground:@"bkg3"];
            type = [[NSArray alloc]initWithObjects:@"1",@"0",@"glass_brick",@"1",@"1",@"bold_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"bold_brick",@"1",@"5",@"bold_brick",@"2",@"5",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"bold_brick",@"3",@"3",@"glass_brick",@"3",@"5",@"bold_brick",@"4",@"1",@"bold_brick",@"4",@"5",@"bold_brick",@"5",@"1",@"bold_brick",@"5",@"2",@"bold_brick",@"5",@"3",@"bold_brick",@"5",@"4",@"bold_brick",@"5",@"5",@"bold_brick",nil];
            break;
        case 14:
            [self addBackground:@"bkg3"];
            type = [[NSArray alloc]initWithObjects:@"1",@"0",@"metal_brick",@"1",@"1",@"metal_brick",@"1",@"2",@"metal_brick",@"1",@"3",@"metal_brick",@"1",@"4",@"metal_brick",@"1",@"5",@"metal_brick",@"2",@"5",@"metal_brick",@"3",@"1",@"metal_brick",@"3",@"2",@"metal_brick",@"3",@"3",@"metal_brick",@"3",@"4",@"glass_brick",@"3",@"5",@"metal_brick",@"4",@"1",@"metal_brick",@"4",@"5",@"metal_brick",@"5",@"1",@"metal_brick",@"5",@"2",@"metal_brick",@"5",@"3",@"metal_brick",@"5",@"4",@"metal_brick",@"5",@"5",@"metal_brick",nil];
            break;
        case 15:
            [self addBackground:@"bkg3"];
            type = [[NSArray alloc]initWithObjects:@"0",@"3",@"bold_brick",@"1",@"1",@"bold_brick",@"1",@"3",@"none",@"1",@"5",@"bold_brick",@"2",@"2",@"glass_brick",@"2",@"3",@"none",@"2",@"4",@"glass_brick",@"3",@"1",@"none",@"3",@"2",@"none",@"3",@"3",@"none",@"3",@"4",@"none",@"3",@"5",@"none",@"4",@"2",@"glass_brick",@"4",@"3",@"none",@"4",@"4",@"glass_brick",@"5",@"1",@"bold_brick",@"5",@"3",@"none",@"5",@"5",@"bold_brick",@"6",@"3",@"bold_brick",nil];
            break;
        case 16:
            [self addBackground:@"bkg4"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"1",@"none",@"1",@"5",@"none",@"2",@"2",@"none",@"2",@"4",@"none",@"3",@"3",@"glass_brick",@"4",@"2",@"none",@"4",@"4",@"none",@"5",@"1",@"none",@"5",@"5",@"none",@"6",@"0",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 17:
            [self addBackground:@"bkg4"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"none",@"0",@"1",@"none",@"0",@"3",@"glass_brick",@"0",@"5",@"none",@"0",@"6",@"none",@"1",@"0",@"none",@"1",@"6",@"none",@"2",@"1",@"glass_brick",@"2",@"5",@"glass_brick",@"3",@"1",@"bold_brick",@"3",@"3",@"metal_brick",@"3",@"5",@"bold_brick",@"4",@"1",@"glass_brick",@"4",@"5",@"glass_brick",@"5",@"0",@"none",@"5",@"6",@"none",@"6",@"0",@"none",@"6",@"1",@"none",@"6",@"3",@"glass_brick",@"6",@"5",@"none",@"6",@"6",@"none",nil];
            break;
        case 18:
            [self addBackground:@"bkg4"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"none",@"0",@"1",@"none",@"0",@"2",@"none",@"0",@"3",@"none",@"0",@"4",@"none",@"0",@"5",@"none",@"0",@"6",@"bold_brick",@"1",@"0",@"none",@"1",@"1",@"none",@"1",@"2",@"none",@"1",@"3",@"none",@"1",@"4",@"none",@"1",@"6",@"none",@"2",@"0",@"none",@"2",@"1",@"none",@"2",@"2",@"none",@"2",@"3",@"none",@"2",@"5",@"none",@"2",@"6",@"none",@"3",@"0",@"none",@"3",@"1",@"none",@"3",@"2",@"none",@"3",@"4",@"none",@"3",@"5",@"none",@"3",@"6",@"none",@"4",@"0",@"metal_brick",@"4",@"1",@"none",@"4",@"3",@"none",@"4",@"4",@"none",@"4",@"5",@"none",@"4",@"6",@"none",@"5",@"1",@"glass_brick",@"5",@"2",@"none",@"5",@"3",@"none",@"5",@"4",@"none",@"5",@"5",@"none",@"5",@"6",@"none",@"6",@"0",@"bold_brick",@"6",@"2",@"metal_brick",@"6",@"3",@"none",@"6",@"4",@"none",@"6",@"5",@"none",@"6",@"6",@"none",nil];
            break;
        case 19:
            [self addBackground:@"bkg4"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"none",@"0",@"1",@"none",@"0",@"2",@"glass_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"glass_brick",@"0",@"5",@"none",@"0",@"6",@"none",@"1",@"0",@"none",@"1",@"1",@"none",@"1",@"3",@"bold_brick",@"1",@"5",@"none",@"1",@"6",@"none",@"2",@"0",@"glass_brick",@"2",@"3",@"bold_brick",@"2",@"6",@"glass_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"bold_brick",@"3",@"3",@"bold_brick",@"3",@"4",@"bold_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"glass_brick",@"4",@"3",@"bold_brick",@"4",@"6",@"glass_brick",@"5",@"0",@"none",@"5",@"1",@"none",@"5",@"3",@"bold_brick",@"5",@"5",@"none",@"5",@"6",@"none",@"6",@"0",@"none",@"6",@"1",@"none",@"6",@"2",@"glass_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"glass_brick",@"6",@"5",@"none",@"6",@"6",@"none",nil];
            break;
        case 20:
            [self addBackground:@"bkg4"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"none",@"0",@"1",@"none",@"0",@"2",@"metal_brick",@"0",@"3",@"none",@"0",@"4",@"metal_brick",@"0",@"5",@"none",@"0",@"6",@"none",@"1",@"0",@"none",@"1",@"1",@"none",@"1",@"3",@"none",@"1",@"5",@"none",@"1",@"6",@"none",@"2",@"0",@"metal_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"none",@"2",@"4",@"bold_brick",@"2",@"6",@"metal_brick",@"3",@"0",@"none",@"3",@"1",@"none",@"3",@"2",@"none",@"3",@"3",@"glass_brick",@"3",@"4",@"none",@"3",@"5",@"none",@"3",@"6",@"none",@"4",@"0",@"metal_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"none",@"4",@"4",@"bold_brick",@"4",@"6",@"metal_brick",@"5",@"0",@"none",@"5",@"1",@"none",@"5",@"3",@"none",@"5",@"5",@"none",@"5",@"6",@"none",@"6",@"0",@"none",@"6",@"1",@"none",@"6",@"2",@"metal_brick",@"6",@"3",@"none",@"6",@"4",@"metal_brick",@"6",@"5",@"none",@"6",@"6",@"none",nil];
            break;
        case 21:
            [self addBackground:@"bkg5"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"metal_brick",@"0",@"6",@"metal_brick",@"1",@"0",@"none",@"1",@"6",@"none",@"2",@"0",@"none",@"2",@"1",@"none",@"2",@"2",@"bold_brick",@"2",@"3",@"glass_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"none",@"2",@"6",@"none",@"3",@"0",@"none",@"3",@"1",@"none",@"3",@"2",@"none",@"3",@"3",@"metal_brick",@"3",@"4",@"none",@"3",@"5",@"none",@"3",@"6",@"none",@"4",@"0",@"none",@"4",@"1",@"none",@"4",@"2",@"bold_brick",@"4",@"3",@"glass_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"none",@"4",@"6",@"none",@"5",@"0",@"none",@"5",@"6",@"none",@"6",@"0",@"metal_brick",@"6",@"6",@"metal_brick",nil];
            break;
        case 22:
            [self addBackground:@"bkg5"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"4",@"glass_brick",@"1",@"5",@"bold_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"3",@"glass_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"glass_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"2",@"glass_brick",@"3",@"3",@"bold_brick",@"3",@"4",@"glass_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"glass_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"glass_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"bold_brick",@"5",@"2",@"glass_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 23:
            [self addBackground:@"bkg5"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"1",@"glass_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"bold_brick",@"1",@"5",@"glass_brick",@"2",@"1",@"glass_brick",@"2",@"5",@"glass_brick",@"3",@"1",@"glass_brick",@"3",@"3",@"bold_brick",@"3",@"5",@"glass_brick",@"4",@"1",@"glass_brick",@"4",@"5",@"glass_brick",@"5",@"1",@"glass_brick",@"5",@"2",@"bold_brick",@"5",@"3",@"bold_brick",@"5",@"4",@"bold_brick",@"5",@"5",@"glass_brick",@"6",@"0",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 24:
            [self addBackground:@"bkg5"];
            type = [[NSArray alloc]initWithObjects:@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"bold_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"glass_brick",@"1",@"4",@"bold_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"bold_brick",@"3",@"3",@"bold_brick",@"4",@"3",@"bold_brick",@"5",@"3",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 25:
            [self addBackground:@"bkg5"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"metal_brick",@"0",@"5",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"glass_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"metal_brick",@"1",@"5",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"bold_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"metal_brick",@"2",@"5",@"bold_brick",@"4",@"0",@"glass_brick",@"4",@"1",@"glass_brick",@"4",@"2",@"glass_brick",@"4",@"3",@"metal_brick",@"4",@"5",@"bold_brick",@"5",@"0",@"glass_brick",@"5",@"1",@"bold_brick",@"5",@"2",@"glass_brick",@"5",@"3",@"metal_brick",@"5",@"5",@"bold_brick",@"6",@"0",@"glass_brick",@"6",@"1",@"glass_brick",@"6",@"2",@"glass_brick",@"6",@"3",@"metal_brick",@"6",@"5",@"bold_brick",nil];
            break;
        case 26:
            [self addBackground:@"bkg6"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"none",@"0",@"2",@"none",@"0",@"4",@"none",@"0",@"5",@"none",@"0",@"6",@"none",@"1",@"0",@"none",@"1",@"1",@"none",@"1",@"2",@"none",@"1",@"5",@"none",@"1",@"6",@"none",@"2",@"2",@"none",@"2",@"5",@"none",@"3",@"1",@"glass_brick",@"4",@"2",@"none",@"4",@"5",@"none",@"5",@"0",@"none",@"5",@"1",@"none",@"5",@"2",@"none",@"5",@"5",@"none",@"5",@"6",@"none",@"6",@"0",@"bold_brick",@"6",@"1",@"none",@"6",@"2",@"none",@"6",@"4",@"none",@"6",@"5",@"none",@"6",@"6",@"none",nil];
            break;
        case 27:
            [self addBackground:@"bkg6"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"none",@"0",@"1",@"none",@"0",@"2",@"none",@"0",@"3",@"none",@"0",@"5",@"none",@"0",@"6",@"none",@"1",@"0",@"none",@"1",@"1",@"none",@"1",@"3",@"none",@"1",@"4",@"metal_brick",@"1",@"6",@"none",@"2",@"0",@"none",@"2",@"3",@"none",@"3",@"0",@"metal_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"glass_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"glass_brick",@"3",@"5",@"bold_brick",@"4",@"0",@"none",@"4",@"3",@"none",@"5",@"0",@"none",@"5",@"1",@"none",@"5",@"3",@"none",@"5",@"4",@"metal_brick",@"5",@"6",@"none",@"6",@"0",@"none",@"6",@"1",@"none",@"6",@"2",@"none",@"6",@"3",@"none",@"6",@"5",@"none",@"6",@"6",@"none",nil];
            break;
        case 28:
            [self addBackground:@"bkg6"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"none",@"0",@"3",@"metal_brick",@"0",@"6",@"none",@"1",@"1",@"none",@"1",@"3",@"glass_brick",@"1",@"5",@"none",@"1",@"6",@"bold_brick",@"2",@"2",@"none",@"2",@"4",@"none",@"2",@"6",@"bold_brick",@"3",@"0",@"metal_brick",@"3",@"1",@"glass_brick",@"3",@"3",@"glass_brick",@"3",@"5",@"glass_brick",@"3",@"6",@"metal_brick",@"4",@"2",@"none",@"4",@"4",@"none",@"4",@"6",@"bold_brick",@"5",@"1",@"none",@"5",@"3",@"glass_brick",@"5",@"5",@"none",@"5",@"6",@"bold_brick",@"6",@"0",@"none",@"6",@"3",@"metal_brick",@"6",@"6",@"none",nil];
            break;
        case 29:
            [self addBackground:@"bkg6"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"5",@"none",@"0",@"6",@"none",@"1",@"1",@"bold_brick",@"1",@"5",@"none",@"1",@"6",@"none",@"2",@"2",@"bold_brick",@"3",@"2",@"metal_brick",@"3",@"3",@"bold_brick",@"4",@"0",@"glass_brick",@"4",@"1",@"glass_brick",@"4",@"2",@"glass_brick",@"4",@"3",@"metal_brick",@"4",@"4",@"bold_brick",@"5",@"0",@"none",@"5",@"1",@"none",@"5",@"2",@"glass_brick",@"5",@"5",@"bold_brick",@"6",@"0",@"none",@"6",@"1",@"none",@"6",@"2",@"glass_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 30:
            [self addBackground:@"bkg6"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"none",@"0",@"2",@"none",@"0",@"3",@"glass_brick",@"0",@"5",@"glass_brick",@"1",@"1",@"metal_brick",@"1",@"3",@"glass_brick",@"1",@"5",@"glass_brick",@"2",@"0",@"none",@"2",@"2",@"none",@"2",@"3",@"glass_brick",@"2",@"5",@"glass_brick",@"3",@"1",@"glass_brick",@"3",@"3",@"glass_brick",@"3",@"5",@"glass_brick",@"4",@"1",@"glass_brick",@"4",@"3",@"glass_brick",@"4",@"5",@"glass_brick",@"5",@"1",@"glass_brick",@"5",@"3",@"glass_brick",@"5",@"5",@"glass_brick",@"6",@"1",@"glass_brick",@"6",@"3",@"glass_brick",@"6",@"5",@"glass_brick",nil];
            break;
        case 31:
            [self addBackground:@"bkg7"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"none",@"0",@"2",@"none",@"0",@"3",@"none",@"0",@"5",@"none",@"0",@"6",@"bold_brick",@"1",@"1",@"metal_brick",@"1",@"2",@"glass_brick",@"1",@"4",@"metal_brick",@"1",@"5",@"glass_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"none",@"2",@"2",@"none",@"2",@"3",@"none",@"2",@"5",@"none",@"2",@"6",@"bold_brick",@"3",@"1",@"metal_brick",@"3",@"2",@"glass_brick",@"3",@"4",@"metal_brick",@"3",@"5",@"glass_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"none",@"4",@"2",@"none",@"4",@"3",@"none",@"4",@"5",@"none",@"4",@"6",@"bold_brick",@"5",@"1",@"metal_brick",@"5",@"2",@"glass_brick",@"5",@"4",@"metal_brick",@"5",@"5",@"glass_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"none",@"6",@"2",@"none",@"6",@"3",@"none",@"6",@"5",@"none",@"6",@"6",@"bold_brick",nil];
            break;
        case 32:
            [self addBackground:@"bkg7"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"metal_brick",@"0",@"1",@"none",@"1",@"1",@"none",@"1",@"2",@"bold_brick",@"1",@"3",@"glass_brick",@"1",@"4",@"glass_brick",@"1",@"5",@"bold_brick",@"2",@"1",@"none",@"2",@"2",@"bold_brick",@"2",@"3",@"glass_brick",@"2",@"4",@"glass_brick",@"2",@"5",@"bold_brick",@"3",@"2",@"bold_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"metal_brick",@"4",@"1",@"none",@"4",@"2",@"bold_brick",@"4",@"3",@"glass_brick",@"4",@"4",@"glass_brick",@"4",@"5",@"bold_brick",@"5",@"1",@"none",@"5",@"2",@"bold_brick",@"5",@"3",@"glass_brick",@"5",@"4",@"glass_brick",@"5",@"5",@"bold_brick",@"6",@"0",@"metal_brick",@"6",@"1",@"none",nil];
            break;
        case 33:
            [self addBackground:@"bkg7"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"3",@"none",@"0",@"6",@"bold_brick",@"1",@"0",@"none",@"1",@"2",@"glass_brick",@"1",@"3",@"glass_brick",@"1",@"4",@"glass_brick",@"1",@"6",@"none",@"2",@"1",@"glass_brick",@"2",@"2",@"metal_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"metal_brick",@"2",@"5",@"glass_brick",@"3",@"1",@"glass_brick",@"3",@"2",@"none",@"3",@"3",@"bold_brick",@"3",@"4",@"none",@"3",@"5",@"glass_brick",@"4",@"1",@"glass_brick",@"4",@"2",@"metal_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"metal_brick",@"4",@"5",@"glass_brick",@"5",@"0",@"none",@"5",@"2",@"glass_brick",@"5",@"3",@"glass_brick",@"5",@"4",@"glass_brick",@"5",@"6",@"none",@"6",@"0",@"bold_brick",@"6",@"3",@"none",@"6",@"6",@"bold_brick",nil];
            break;
        case 34:
            [self addBackground:@"bkg7"];
            type = [[NSArray alloc]initWithObjects:@"0",@"1",@"none",@"0",@"2",@"none",@"0",@"3",@"none",@"0",@"4",@"none",@"0",@"5",@"none",@"0",@"6",@"none",@"2",@"1",@"bold_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"metal_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"glass_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"glass_brick",@"3",@"5",@"glass_brick",@"3",@"6",@"bold_brick",@"4",@"1",@"bold_brick",@"4",@"6",@"bold_brick",@"6",@"1",@"none",@"6",@"2",@"none",@"6",@"3",@"none",@"6",@"4",@"none",@"6",@"5",@"none",@"6",@"6",@"none",nil];
            break;
        case 35:
            [self addBackground:@"bkg7"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"bold_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"bold_brick",@"1",@"5",@"bold_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"bold_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"bold_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"bold_brick",@"3",@"3",@"bold_brick",@"3",@"4",@"bold_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"bold_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"bold_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"bold_brick",@"5",@"2",@"bold_brick",@"5",@"3",@"bold_brick",@"5",@"4",@"bold_brick",@"5",@"5",@"bold_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 36:
            [self addBackground:@"bkg8"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"glass_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"bold_brick",@"1",@"5",@"glass_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"bold_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"bold_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"bold_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"bold_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"bold_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"bold_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"glass_brick",@"5",@"2",@"bold_brick",@"5",@"3",@"bold_brick",@"5",@"4",@"bold_brick",@"5",@"5",@"glass_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 37:
            [self addBackground:@"bkg8"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"none",@"1",@"2",@"none",@"1",@"3",@"none",@"1",@"4",@"none",@"1",@"5",@"none",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"none",@"2",@"2",@"bold_brick",@"2",@"3",@"glass_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"none",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"none",@"3",@"2",@"glass_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"glass_brick",@"3",@"5",@"none",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"none",@"4",@"2",@"bold_brick",@"4",@"3",@"glass_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"none",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"none",@"5",@"2",@"none",@"5",@"3",@"none",@"5",@"4",@"none",@"5",@"5",@"none",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 38:
            [self addBackground:@"bkg8"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"none",@"1",@"1",@"none",@"1",@"2",@"none",@"1",@"3",@"none",@"1",@"4",@"none",@"1",@"5",@"none",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"bold_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"none",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"none",@"3",@"2",@"none",@"3",@"3",@"none",@"3",@"4",@"bold_brick",@"3",@"5",@"none",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"none",@"4",@"2",@"bold_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"none",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"none",@"5",@"2",@"none",@"5",@"3",@"none",@"5",@"4",@"none",@"5",@"5",@"none",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 39:
            [self addBackground:@"bkg8"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"glass_brick",@"1",@"1",@"glass_brick",@"1",@"2",@"glass_brick",@"1",@"3",@"glass_brick",@"1",@"4",@"glass_brick",@"1",@"5",@"glass_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"bold_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"glass_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"glass_brick",@"3",@"2",@"glass_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"bold_brick",@"3",@"5",@"glass_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"glass_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"glass_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"glass_brick",@"5",@"2",@"glass_brick",@"5",@"3",@"glass_brick",@"5",@"4",@"glass_brick",@"5",@"5",@"glass_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 40:
            [self addBackground:@"bkg8"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"metal_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"metal_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"glass_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"bold_brick",@"1",@"5",@"glass_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"glass_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"glass_brick",@"2",@"5",@"glass_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"glass_brick",@"3",@"2",@"bold_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"bold_brick",@"3",@"5",@"glass_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"glass_brick",@"4",@"2",@"glass_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"glass_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"glass_brick",@"5",@"2",@"bold_brick",@"5",@"3",@"bold_brick",@"5",@"4",@"bold_brick",@"5",@"5",@"glass_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"metal_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"metal_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 41:
            [self addBackground:@"bkg9"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"none",@"0",@"4",@"bold_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"glass_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"none",@"1",@"4",@"bold_brick",@"1",@"5",@"glass_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"bold_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"none",@"2",@"4",@"bold_brick",@"2",@"5",@"bold_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"none",@"3",@"1",@"none",@"3",@"2",@"none",@"3",@"3",@"none",@"3",@"4",@"none",@"3",@"5",@"none",@"3",@"6",@"none",@"4",@"0",@"bold_brick",@"4",@"1",@"bold_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"none",@"4",@"4",@"bold_brick",@"4",@"5",@"bold_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"glass_brick",@"5",@"2",@"bold_brick",@"5",@"3",@"none",@"5",@"4",@"bold_brick",@"5",@"5",@"glass_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"none",@"6",@"4",@"bold_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 42:
            [self addBackground:@"bkg9"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"metal_brick",@"1",@"2",@"metal_brick",@"1",@"4",@"metal_brick",@"1",@"5",@"metal_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"metal_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"glass_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"metal_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"glass_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"glass_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"metal_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"glass_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"metal_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"metal_brick",@"5",@"2",@"metal_brick",@"5",@"4",@"metal_brick",@"5",@"5",@"metal_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 43:
            [self addBackground:@"bkg9"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"metal_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"bold_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"glass_brick",@"1",@"4",@"bold_brick",@"1",@"5",@"bold_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"glass_brick",@"2",@"2",@"metal_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"metal_brick",@"2",@"5",@"glass_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"glass_brick",@"3",@"2",@"bold_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"bold_brick",@"3",@"5",@"glass_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"glass_brick",@"4",@"2",@"metal_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"metal_brick",@"4",@"5",@"glass_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"bold_brick",@"5",@"2",@"bold_brick",@"5",@"3",@"glass_brick",@"5",@"4",@"bold_brick",@"5",@"5",@"bold_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"metal_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 44:
            [self addBackground:@"bkg9"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"metal_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"metal_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"glass_brick",@"1",@"2",@"glass_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"metal_brick",@"1",@"5",@"glass_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"bold_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"bold_brick",@"2",@"6",@"metal_brick",@"3",@"0",@"metal_brick",@"3",@"1",@"metal_brick",@"3",@"2",@"metal_brick",@"3",@"3",@"metal_brick",@"3",@"4",@"glass_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"bold_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"bold_brick",@"4",@"6",@"metal_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"glass_brick",@"5",@"2",@"glass_brick",@"5",@"3",@"bold_brick",@"5",@"4",@"metal_brick",@"5",@"5",@"glass_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"metal_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"metal_brick",nil];
            break;
        case 45:
            [self addBackground:@"bkg10"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"glass_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"metal_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"metal_brick",@"1",@"1",@"bold_brick",@"1",@"2",@"metal_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"metal_brick",@"1",@"5",@"bold_brick",@"1",@"6",@"normal_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"glass_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"metal_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"bold_brick",@"3",@"3",@"bold_brick",@"3",@"4",@"glass_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"glass_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"metal_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"metal_brick",@"5",@"1",@"bold_brick",@"5",@"2",@"metal_brick",@"5",@"3",@"bold_brick",@"5",@"4",@"metal_brick",@"5",@"5",@"bold_brick",@"5",@"6",@"normal_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"glass_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"metal_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 46:
            [self addBackground:@"bkg10"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"glass_brick",@"1",@"2",@"glass_brick",@"1",@"3",@"glass_brick",@"1",@"4",@"metal_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"bold_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"bold_brick",@"2",@"5",@"bold_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"bold_brick",@"3",@"4",@"bold_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"bold_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"bold_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"2",@"metal_brick",@"5",@"3",@"glass_brick",@"5",@"4",@"glass_brick",@"5",@"5",@"glass_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 47:
            [self addBackground:@"bkg10"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"none",@"0",@"5",@"none",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"glass_brick",@"1",@"2",@"glass_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"none",@"1",@"5",@"bold_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"glass_brick",@"2",@"2",@"glass_brick",@"2",@"3",@"bold_brick",@"2",@"4",@"metal_brick",@"2",@"5",@"bold_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"bold_brick",@"3",@"3",@"bold_brick",@"3",@"4",@"metal_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"glass_brick",@"4",@"2",@"glass_brick",@"4",@"3",@"bold_brick",@"4",@"4",@"metal_brick",@"4",@"5",@"bold_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"glass_brick",@"5",@"2",@"glass_brick",@"5",@"3",@"bold_brick",@"5",@"4",@"none",@"5",@"5",@"bold_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"none",@"6",@"5",@"none",@"6",@"6",@"bold_brick",nil];
            break;
        case 48:
            [self addBackground:@"bkg10"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"metal_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"bold_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"glass_brick",@"1",@"4",@"bold_brick",@"1",@"5",@"bold_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"bold_brick",@"2",@"2",@"bold_brick",@"2",@"3",@"glass_brick",@"2",@"4",@"bold_brick",@"2",@"5",@"bold_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"metal_brick",@"3",@"1",@"glass_brick",@"3",@"2",@"glass_brick",@"3",@"3",@"metal_brick",@"3",@"4",@"glass_brick",@"3",@"5",@"glass_brick",@"3",@"6",@"metal_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"bold_brick",@"4",@"2",@"bold_brick",@"4",@"3",@"glass_brick",@"4",@"4",@"bold_brick",@"4",@"5",@"bold_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"bold_brick",@"5",@"2",@"bold_brick",@"5",@"3",@"glass_brick",@"5",@"4",@"bold_brick",@"5",@"5",@"bold_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"metal_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 49:
            [self addBackground:@"bkg10"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"glass_brick",@"0",@"4",@"metal_brick",@"0",@"5",@"bold_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"bold_brick",@"1",@"1",@"bold_brick",@"1",@"2",@"metal_brick",@"1",@"3",@"glass_brick",@"1",@"4",@"metal_brick",@"1",@"5",@"bold_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"bold_brick",@"2",@"2",@"metal_brick",@"2",@"3",@"glass_brick",@"2",@"4",@"metal_brick",@"2",@"5",@"bold_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"bold_brick",@"3",@"3",@"glass_brick",@"3",@"4",@"bold_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"bold_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"bold_brick",@"4",@"2",@"metal_brick",@"4",@"3",@"glass_brick",@"4",@"4",@"metal_brick",@"4",@"5",@"bold_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"bold_brick",@"5",@"1",@"bold_brick",@"5",@"2",@"metal_brick",@"5",@"3",@"glass_brick",@"5",@"4",@"metal_brick",@"5",@"5",@"bold_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"glass_brick",@"6",@"4",@"metal_brick",@"6",@"5",@"bold_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 50:
            [self addBackground:@"bkg10"];
            type = [[NSArray alloc]initWithObjects:@"0",@"0",@"bold_brick",@"0",@"1",@"bold_brick",@"0",@"2",@"bold_brick",@"0",@"3",@"bold_brick",@"0",@"4",@"bold_brick",@"0",@"5",@"metal_brick",@"0",@"6",@"bold_brick",@"1",@"0",@"metal_brick",@"1",@"1",@"bold_brick",@"1",@"2",@"bold_brick",@"1",@"3",@"bold_brick",@"1",@"4",@"metal_brick",@"1",@"5",@"bold_brick",@"1",@"6",@"bold_brick",@"2",@"0",@"bold_brick",@"2",@"1",@"metal_brick",@"2",@"2",@"glass_brick",@"2",@"3",@"metal_brick",@"2",@"4",@"glass_brick",@"2",@"5",@"bold_brick",@"2",@"6",@"bold_brick",@"3",@"0",@"bold_brick",@"3",@"1",@"bold_brick",@"3",@"2",@"glass_brick",@"3",@"3",@"bold_brick",@"3",@"4",@"glass_brick",@"3",@"5",@"bold_brick",@"3",@"6",@"glass_brick",@"4",@"0",@"bold_brick",@"4",@"1",@"metal_brick",@"4",@"2",@"glass_brick",@"4",@"3",@"metal_brick",@"4",@"4",@"glass_brick",@"4",@"5",@"bold_brick",@"4",@"6",@"bold_brick",@"5",@"0",@"metal_brick",@"5",@"1",@"bold_brick",@"5",@"2",@"bold_brick",@"5",@"3",@"bold_brick",@"5",@"4",@"metal_brick",@"5",@"5",@"bold_brick",@"5",@"6",@"bold_brick",@"6",@"0",@"bold_brick",@"6",@"1",@"bold_brick",@"6",@"2",@"bold_brick",@"6",@"3",@"bold_brick",@"6",@"4",@"bold_brick",@"6",@"5",@"metal_brick",@"6",@"6",@"bold_brick",nil];
            break;
        case 52:
            // choose random background
            background_num = [NSString stringWithFormat:@"%d",[self generateRandomNumberBetweenMin:11 Max:22]];
            background_img = [NSString stringWithFormat:@"bkg%@", background_num];
            [self addBackground:background_img];
            
            // create brick matrix
            tmp_array = [[NSMutableArray alloc] init];
            icons = [[NSArray alloc]initWithObjects:@"normal_brick",@"none",@"glass_brick",@"bold_brick",@"metal_brick",nil];

            for (int i=0; i<7; i++) {
                for (int j=0; j<7; j++) {
                    int brick_num = [self generateRandomNumberBetweenMin:0 Max:4];
                    if (brick_num > 0) {
                        [tmp_array addObject:[NSString stringWithFormat:@"%d",i]];
                        [tmp_array addObject:[NSString stringWithFormat:@"%d",j]];
                        [tmp_array addObject:[icons objectAtIndex:brick_num]];
                    }
                }
            }
            type = tmp_array;
            break;
        case 53:
            // choose random background
            background_num = [NSString stringWithFormat:@"%d",[self generateRandomNumberBetweenMin:11 Max:22]];
            background_img = [NSString stringWithFormat:@"bkg%@", background_num];
            [self addBackground:background_img];
            
            // create brick matrix
            //tmp_array = [[NSMutableArray alloc] init];
            myArray = [[_appDelegate.controller.CREATED objectForKey:@"made_level"] componentsSeparatedByString:@","];
            type = myArray;
            break;

        default:
            break;
    }
    
    NSLog(@"%lu",(unsigned long)type.count);
    [self createBricks:type];

}

-(void)addEdges:(CGSize)size{
    //add an invisible line at the bottom, just 1px up from the bottom edge
    //SKNode *bottomEdge = [SKNode node];
    //bottomEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 1) toPoint:CGPointMake(size.width, 1)];
    //bottomEdge.physicsBody.categoryBitMask = bottomEdgeCategory;
    //[self addChild:bottomEdge];
    
    //add an invisible line at the top, below the top bar
    SKNode *topEdge = [SKNode node];
    topEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, size.height-levelLabel.frame.size.height-5-self.pause.frame.size.height/2) toPoint:CGPointMake(size.width, size.height-levelLabel.frame.size.height-5-self.pause.frame.size.height)];
    topEdge.physicsBody.categoryBitMask = edgeCategory;
    [self addChild:topEdge];
    
    //a visual thing for the bottom ?
    CGSize sz = CGSizeMake(self.frame.size.width*2, 3);
    SKSpriteNode *bt = [[SKSpriteNode alloc]initWithColor:[SKColor orangeColor] size:sz];
    bt.position = CGPointMake(self.frame.size.width/2, 30);
    bt.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bt.frame.size];
    bt.physicsBody.categoryBitMask = bottomEdgeCategory;
    bt.physicsBody.collisionBitMask = ballCategory;
    bt.physicsBody.contactTestBitMask = ballCategory;
    bt.physicsBody.dynamic=NO;
    [self addChild:bt];
    [bt runAction:blinkForever];
    
}

-(void)addBackground:(NSString *)image{
    //BACKGROUND
    self.background = [SKSpriteNode spriteNodeWithImageNamed:image];
    //background.alpha=0.6;
    self.background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.background.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    [self addChild:self.background];
}

-(void)addTopBar:(CGSize)size level:(int)level{
    //level
    //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        //levelLabel = [SKSpriteNode spriteNodeWithImageNamed:@"level@2x"];
    //} else {
        levelLabel = [SKSpriteNode spriteNodeWithImageNamed:@"level"];
    //}
    levelLabel.position = CGPointMake(levelLabel.frame.size.width/2, size.height-levelLabel.frame.size.height/2);
    [self addChild:levelLabel];
    self.level = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
    self.level.name = @"level";
    self.level.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    self.level.text = [NSString stringWithFormat:@"%i",level];
    //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        //self.level.fontSize = 20; //probably needs to be changed
        //self.level.position = CGPointMake(self.frame.size.width*0.07,size.height-levelLabel.frame.size.height+14);
    //} else {
        self.level.fontSize = 10;
        self.level.position = CGPointMake(levelLabel.frame.size.width*0.25,size.height-levelLabel.frame.size.height+8);
    //}
    self.level.fontColor = [SKColor blackColor];
    [self addChild:self.level];

    
    
    //hi-score
    hi_score = [NSUserDefaults standardUserDefaults];
    [hi_score synchronize];

    SKSpriteNode *hiLabel;
    //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        //hiLabel = [SKSpriteNode spriteNodeWithImageNamed:@"hi@2x"];
        //hiLabel.position = CGPointMake(levelLabel.frame.size.width+10+hiLabel.frame.size.width/2, size.height-levelLabel.frame.size.height/2); //probably needs to be changed
    //} else {
        hiLabel = [SKSpriteNode spriteNodeWithImageNamed:@"hi"];
        hiLabel.position = CGPointMake(self.frame.size.width/2, size.height-levelLabel.frame.size.height/2);
    //}
    [self addChild:hiLabel];
    self.hi = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
    self.hi.name = @"hi";
    self.hi.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    if (![hi_score objectForKey:@"hi_score"]) {
        self.hi.text = @"0";
    }else{
        self.hi.text = [NSString stringWithFormat:@"%@",[hi_score objectForKey:@"hi_score"]];
    }
    //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        //self.hi.fontSize = 12;
        //self.hi.position = CGPointMake(self.frame.size.width*0.60,size.height-levelLabel.frame.size.height+7); //probably needs to be changed
    //} else {
        self.hi.fontSize = 12;
        self.hi.position = CGPointMake(hiLabel.position.x+hiLabel.size.width*0.4,size.height-levelLabel.frame.size.height+7);
    //}
    self.hi.fontColor = [SKColor blackColor];
    [self addChild:self.hi];
    
    //current score
    SKSpriteNode *scoreLabel = [SKSpriteNode spriteNodeWithImageNamed:@"score"];
    scoreLabel.position = CGPointMake(self.frame.size.width-scoreLabel.frame.size.width/2, size.height-levelLabel.frame.size.height/2);
    [self addChild:scoreLabel];
    self.score = [[SKLabelNode alloc] initWithFontNamed:@"AGENTORANGE"];
    self.score.name = @"score";
    self.score.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    self.score.text = [NSString stringWithFormat:@"%i",_appDelegate.current_score];
    self.score.fontSize = 12;
    self.score.position = CGPointMake(scoreLabel.position.x+scoreLabel.size.width*0.4,size.height-levelLabel.frame.size.height+7);
    self.score.fontColor = [SKColor blackColor];
    [self addChild:self.score];
    
    //play-pause
    [self addPause:@"pause"];
    
    //quit
    SKSpriteNode *quit =[SKSpriteNode spriteNodeWithImageNamed:@"quit"];
    quit.position = CGPointMake(size.width-quit.frame.size.width/2, size.height-levelLabel.frame.size.height-5-self.pause.frame.size.height/2);
    quit.name = @"quit";
    [self addChild:quit];
    
    //reset
    SKSpriteNode *reset =[SKSpriteNode spriteNodeWithImageNamed:@"reset"];
    reset.position = CGPointMake(0+reset.frame.size.width/2, size.height-levelLabel.frame.size.height-5-self.pause.frame.size.height/2);
    reset.name = @"reset";
    [self addChild:reset];
}

-(void)addPause:(NSString *)icon{
    self.pause = [SKSpriteNode spriteNodeWithImageNamed:icon];
    self.pause.position = CGPointMake(self.frame.size.width/2,self.frame.size.height-levelLabel.frame.size.height-5-self.pause.frame.size.height/2);
    self.pause.name = @"play_pause";
    [self addChild:self.pause];
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


#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *n = [self nodeAtPoint:touchLocation];
    
    if (n != self && !self.view.paused && [n.name isEqual: @"quit"]) {
        [self runAction:self.playSFX_quit];
        
        //alert
        [quit_alert removeFromParent];
        [accept_ok removeFromParent];
        [cancel removeFromParent];
        [_pause removeFromParent];
        
        quit_alert = [SKSpriteNode spriteNodeWithImageNamed:@"quit_alert"];
        quit_alert.position = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
        [self addChild:quit_alert];
        //buttons
        cancel = [SKSpriteNode spriteNodeWithImageNamed:@"cancel"];
        cancel.position = CGPointMake(self.frame.size.width/2-quit_alert.frame.size.width/4,self.frame.size.height/2-quit_alert.frame.size.height/2);
        cancel.name=@"cancel";
        [self addChild:cancel];
        accept_ok = [SKSpriteNode spriteNodeWithImageNamed:@"accept"];
        accept_ok.position = CGPointMake(self.frame.size.width/2+quit_alert.frame.size.width/4,self.frame.size.height/2-quit_alert.frame.size.height/2);
        accept_ok.name=@"accept";
        [self addChild:accept_ok];
    }
    
    if (n != self && [n.name isEqual: @"reset"]) {
        [self runAction:_appDelegate.tapSound2];
        [self resetBallAndPaddle];
    }
    
    if (n != self && [n.name isEqual: @"cancel"]) {
        [self runAction:_appDelegate.tapSound2];
        self.view.paused = NO;
        [quit_alert removeFromParent];
        [accept_ok removeFromParent];
        [cancel removeFromParent];
        [self addPause:@"pause"];
    }
    
    if (n != self && [n.name isEqual: @"accept"]) {
        [self runAction:_appDelegate.tapSound2];
        self.view.paused = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFullRev" object:nil];
        MenuScene* menu = [[MenuScene alloc] initWithSize:self.size];
        [self.view presentScene:menu transition:[SKTransition doorsCloseVerticalWithDuration:1.0]];
    }
    
    if (n != self && [n.name isEqual: @"play_pause"]) {
        [self runAction:_appDelegate.tapSound2];
        [self.pause removeFromParent];
        if (!self.view.paused) {
            [self addPause:@"play"];
        } else {
            [self addPause:@"pause"];
        }
    }
    
    //change difficulty level
    if (n != self && [n.name isEqual: @"difficulty_levels"]) {
        self.view.paused = NO;
        [self removeBallAndPaddle];
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
    
    /*
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
    */
    if (n != self && [n.name isEqual: @"music_btn"]) {
        self.view.paused = NO;
        [self removeBallAndPaddle];
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
        [self removeBallAndPaddle];
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


    if (n != self && [n.name isEqual: @"menu_btn"]) {
        [self runAction:_appDelegate.tapSound2];
        self.view.paused = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFullRev" object:nil];
        MenuScene* menuScene = [[MenuScene alloc] initWithSize:self.frame.size];
        [self.view presentScene:menuScene transition:[SKTransition doorsCloseVerticalWithDuration:1.0]];
    }
    
    if (n != self && [n.name isEqual: @"playagain_btn"]) {
        [self runAction:_appDelegate.tapSound2];
        self.view.paused = NO;
        _appDelegate.lives = 3;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFullRev" object:nil];
        GameScene* startScene = [[GameScene alloc] initWithSize:self.frame.size level:1];
        [self.view presentScene:startScene transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
    }
    
    if (n != self && [n.name isEqual: @"settings_btn"]) {
        [self runAction:_appDelegate.tapSound2];
        self.view.paused = NO; //just to be able to tap
        [self performSelector:@selector(pauseScene) withObject:nil afterDelay:0.1];
        
        [current_level removeFromParent];
        [current_scr removeFromParent];
        [menu_btn removeFromParent];
        [playagain_btn removeFromParent];
        [settings_btn removeFromParent];
        [win removeFromParent];
        [forward_btn removeFromParent];
        
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
        menu_btn =[SKSpriteNode spriteNodeWithImageNamed:@"menu_btn"];
        menu_btn.position = CGPointMake(settings.position.x-105+settings.frame.size.width/2,settings.position.y-5+settings.frame.size.height/2);
        menu_btn.name = @"menu_btn";
        [self addChild:menu_btn];
        
        playagain_btn =[SKSpriteNode spriteNodeWithImageNamed:@"replay"];
        playagain_btn.position = CGPointMake(settings.position.x-55+settings.frame.size.width/2,settings.position.y-5+settings.frame.size.height/2);
        playagain_btn.name = @"repeat_level";
        [self addChild:playagain_btn];
        
        forward_btn =[SKSpriteNode spriteNodeWithImageNamed:@"forward"];
        forward_btn.position = CGPointMake(settings.position.x-5+settings.frame.size.width/2,settings.position.y-5+settings.frame.size.height/2);
        forward_btn.name = @"forward";
        [self addChild:forward_btn];
    }
    
    //next level
    if (n != self && [n.name isEqual: @"forward"]) {
        [self runAction:_appDelegate.tapSound2];
        self.view.paused = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFullRev" object:nil];
        NSString *cur_lvl = self.level.text;
        GameScene* startScene = [[GameScene alloc] initWithSize:self.frame.size level:(int)[cur_lvl integerValue]+1];
        [self.view presentScene:startScene transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
    }

    if (n != self && [n.name isEqual: @"repeat_level"]) {
        [self runAction:_appDelegate.tapSound2];
        self.view.paused = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFullRev" object:nil];
        NSString *cur_lvl = self.level.text;
        GameScene* startScene = [[GameScene alloc] initWithSize:self.frame.size level:(int)[cur_lvl integerValue]];
        [self.view presentScene:startScene transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
    }
    
    
    //TOUCH ON PADDLE
    SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:touchLocation];
    if (![paddles containsObject:body.node.name]) {
        
        for (SKNode* node in self.children) {
            
            if ([node.name isEqualToString:@"white_ball"] || [node.name isEqualToString:@"super_ball"]){
                float speed = sqrt(node.physicsBody.velocity.dx*node.physicsBody.velocity.dx + node.physicsBody.velocity.dy * node.physicsBody.velocity.dy);
                if (speed == 0){
                    if (touchLocation.x < self.paddle.position.x && touchLocation.y < self.frame.size.height/2 && touchLocation.y > self.paddle.position.y) {
                        //(touchLocation.x < 160 && touchLocation.y < 300)
                        float length = sqrt((self.paddle.position.x-touchLocation.x)*(self.paddle.position.x-touchLocation.x) + (touchLocation.y-self.paddle.position.y)*(touchLocation.y-self.paddle.position.y));
                        NSLog(@"length:%f",length);
                        [node.physicsBody applyImpulse:CGVectorMake(-ipad_multiplier*difficulty_multiplier*((self.paddle.position.x-touchLocation.x)/length), ipad_multiplier*difficulty_multiplier*((touchLocation.y-self.paddle.position.y)/length))];
                        NSLog(@"x:%f y:%f",touchLocation.x,touchLocation.y);
                    } else if (touchLocation.x >= self.paddle.position.x && touchLocation.y < self.frame.size.height/2 && touchLocation.y > self.paddle.position.y){
                        //(touchLocation.x >= 160 && touchLocation.y < 300)
                        float length = sqrt((touchLocation.x-self.paddle.position.x)*(touchLocation.x-self.paddle.position.x) + (touchLocation.y-self.paddle.position.y)*(touchLocation.y-self.paddle.position.y));
                        NSLog(@"length:%f",length);
                        [node.physicsBody applyImpulse:CGVectorMake(ipad_multiplier*difficulty_multiplier*((touchLocation.x-self.paddle.position.x)/length), ipad_multiplier*difficulty_multiplier*((touchLocation.y-self.paddle.position.y)/length))];
                        NSLog(@"x:%f y:%f",touchLocation.x,touchLocation.y);
                    }
                }
            }
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        //move only in x-axis, keep same y position
        CGPoint newPos = CGPointMake(location.x, 100);
        CGPoint newPos2;
        CGPoint newPos3;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            newPos2 = CGPointMake(location.x +40, self.paddle.position.y-50);
            newPos3 = CGPointMake(location.x -40, self.paddle.position.y-50);
        } else {
            newPos2 = CGPointMake(location.x +20, self.paddle.position.y-25);
            newPos3 = CGPointMake(location.x -20, self.paddle.position.y-25);
        }
        
        //do nothing if we touch too high
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            if (location.y > 200 && location.y<self.size.height-levelLabel.frame.size.height-5-self.pause.frame.size.height) {
                return;
            }
        } else {
            if (location.y > 100 && location.y<self.size.height-levelLabel.frame.size.height-5-self.pause.frame.size.height) {
                return;
            }
        }
        //don't move beyond scene edges
        //left
        if (newPos.x < self.paddle.frame.size.width/2) {
            newPos.x = self.paddle.frame.size.width/2;
        }
        //right
        if (newPos.x > self.size.width - self.paddle.frame.size.width/2) {
            newPos.x = self.size.width - self.paddle.frame.size.width/2;
        }
        
        self.paddle.position = newPos;
        self.right_arrow.position = newPos2;
        self.left_arrow.position = newPos3;
        
        //carry balls together
        for (SKNode* node in self.children) {
            
            if ([node.name isEqualToString:@"white_ball"] || [node.name isEqualToString:@"super_ball"]){
                float speed = sqrt(node.physicsBody.velocity.dx*node.physicsBody.velocity.dx + node.physicsBody.velocity.dy * node.physicsBody.velocity.dy);
                if (speed == 0){
                    node.position = CGPointMake(_paddle.position.x,_paddle.position.y+_paddle.frame.size.height);
                }
            }
        }

    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *n = [self nodeAtPoint:touchLocation];

    if (n != self && [n.name isEqual: @"play_pause"]) {
        if (!self.view.paused) {
            self.view.paused = YES;
        } else {
            self.view.paused = NO;
        }
    }
    
    if (n != self && [n.name isEqual: @"quit"]) {
        self.view.paused = YES;
    }

}

#pragma mark - Init
-(void)initSFX{
    self.playSFX_paddle = [SKAction playSoundFileNamed:@"ball_hit_paddle.mp3" waitForCompletion:NO];
    self.playSFX_brick = [SKAction playSoundFileNamed:@"ball_break_brick.mp3" waitForCompletion:NO];
    self.playSFX_glass = [SKAction playSoundFileNamed:@"ball_break_glass.mp3" waitForCompletion:NO];
    self.playSFX_wall = [SKAction playSoundFileNamed:@"ball_hit_wall.mp3" waitForCompletion:NO];
    self.playSFX_metal = [SKAction playSoundFileNamed:@"ball_hit_metal.mp3" waitForCompletion:NO];
    self.playSFX_lose = [SKAction playSoundFileNamed:@"lose.mp3" waitForCompletion:NO];
    self.playSFX_bullet = [SKAction playSoundFileNamed:@"lazer3.mp3" waitForCompletion:NO];
    self.playSFX_life = [SKAction playSoundFileNamed:@"life.mp3" waitForCompletion:NO];
    self.playSFX_glue = [SKAction playSoundFileNamed:@"glue.mp3" waitForCompletion:NO];
    self.playSFX_crack = [SKAction playSoundFileNamed:@"crack.mp3" waitForCompletion:NO];
    self.playSFX_money = [SKAction playSoundFileNamed:@"money.caf" waitForCompletion:NO];
    self.playSFX_win = [SKAction playSoundFileNamed:@"level_complete.mp3" waitForCompletion:NO];
    self.playSFX_gameover = [SKAction playSoundFileNamed:@"gameover.caf" waitForCompletion:NO];
    self.playSFX_extraball = [SKAction playSoundFileNamed:@"extraball.mp3" waitForCompletion:NO];
    self.playSFX_superball = [SKAction playSoundFileNamed:@"superball.caf" waitForCompletion:NO];
    self.playSFX_half = [SKAction playSoundFileNamed:@"half.mp3" waitForCompletion:NO];
    self.playSFX_double = [SKAction playSoundFileNamed:@"double.mp3" waitForCompletion:NO];
    self.playSFX_quit = [SKAction playSoundFileNamed:@"quit.mp3" waitForCompletion:NO];
    self.playSFX_gamewin = [SKAction playSoundFileNamed:@"gamewin.mp3" waitForCompletion:NO];
}

-(id)initWithSize:(CGSize)size level:(int)level {
    if (self = [super initWithSize:size]) {
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        /* Setup your scene here */
        self.backgroundColor = [SKColor whiteColor];
        //physics body surrounding the scene
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        //category
        self.physicsBody.categoryBitMask = edgeCategory;
        self.physicsBody.friction = 0.0f;
        //change gravity settings of the physics world
        //reduce gravity
        //self.physicsWorld.gravity = CGVectorMake(0, -1.6); //pull down on y-axis 1.6 m/s^2
        //zero gravity
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        //delegate
        self.physicsWorld.contactDelegate = self;
        
        //MUSIC ON/OFF
        [_appDelegate.controller.MUSIC_ON synchronize];
        if ([_appDelegate.controller.MUSIC_ON boolForKey:@"music_on"]) {
            [_appDelegate.controller stopMusic];
            [_appDelegate.controller playMusic:@"game" type:@"mp3"];
        }

        //SOUND FX ON/OFF
        [_appDelegate.controller.SOUNDS_ON synchronize];
        if ([_appDelegate.controller.SOUNDS_ON boolForKey:@"sounds_on"]) {
            [self initSFX];
        }
        
        // define difficulty multiplier
        if ([[_appDelegate.controller.DIFFICULTY objectForKey:@"diff_level"]  isEqual: @"1"]) {
            difficulty_multiplier = 2;
        } else if ([[_appDelegate.controller.DIFFICULTY objectForKey:@"diff_level"]  isEqual: @"2"]) {
            difficulty_multiplier = 5;
        } else {
            difficulty_multiplier = 8;
        }
        
        // define ipad multiplier
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            ipad_multiplier = 6;
        } else {
            ipad_multiplier = 1;
        }
        
        //animation
        SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:1.0],
                                               [SKAction fadeInWithDuration:1.0]]];
        blinkForever = [SKAction repeatActionForever:blink];

        //BRICKS
        [self addBricks:size level:level];
        
        //PADDLE
        //insert paddle first because ball uses its y-position
        paddles = [[NSArray alloc]initWithObjects:@"double_paddle",@"glue_paddle",@"half_paddle",@"main_paddle",@"bullet_paddle",nil];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            [self addPaddle:self.size type:@"main_paddle@2x" x:CGRectGetMidX(self.frame) y:100];
        } else {
            [self addPaddle:self.size type:@"main_paddle" x:CGRectGetMidX(self.frame) y:100];
        }
        
        //BALL
        [self addBall:size kick:NO];
        
        //TOP BAR
        [self addTopBar:size level:level];
        
        //EDGES
        [self addEdges:size];
        
        //LIVES
        lives_array = [[NSMutableArray alloc]init];
        for (int i=1; i<=_appDelegate.lives; i++) {
            SKSpriteNode* life = [SKSpriteNode spriteNodeWithImageNamed:@"white_ball"];
            //life.name = [NSString stringWithFormat:@"life_%i",i];
            [life setScale:0.7];
            life.position = CGPointMake(20*i,10);
            [self addChild:life];
            //put them in an array, so we can remove them
            [lives_array addObject:life];
        }
        
        //GIFTS
        _gifts = [[NSArray alloc]initWithObjects:@"half_gift",@"double_gift",@"magnet",@"life",@"bullet_gift",@"coin_gift",@"superball",@"extraball", nil];
        //test
        //_gifts = [[NSArray alloc]initWithObjects:@"magnet",@"extraball", nil];
        
        
    }
    return self;
}

@end
