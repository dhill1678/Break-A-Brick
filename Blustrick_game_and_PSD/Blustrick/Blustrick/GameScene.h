//
//  GameScene.h
//  Blustrick
//

//  Copyright (c) 2014 Zois Avgerinos. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <StoreKit/StoreKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate> {
    NSInteger difficulty_multiplier;
    NSInteger ipad_multiplier;
}

-(id)initWithSize:(CGSize)size level:(int)level;

@end
