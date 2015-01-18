//
//  AppDelegate.h
//  Blustrick
//
//  Created by Zois Avgerinos on 6/30/14.
//  Copyright (c) 2014 Zois Avgerinos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SKAction *tapSound;
@property (strong, nonatomic) SKAction *tapSound2;
@property (nonatomic) int lives;
@property (nonatomic) int current_score;

@property (weak, nonatomic) ViewController *controller;
@end
