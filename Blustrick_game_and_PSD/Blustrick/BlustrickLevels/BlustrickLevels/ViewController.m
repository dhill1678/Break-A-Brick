//
//  ViewController.m
//  BlustrickLevels
//
//  Created by Zois Avgerinos on 7/19/14.
//  Copyright (c) 2014 Zois Avgerinos. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
NSArray *icons;
int imageIndex;
NSMutableString *result;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    imageIndex = 0;
    [self createButtons];
    
    icons = [[NSArray alloc]initWithObjects:@"normal_brick",@"none",@"glass_brick",@"bold_brick",@"metal_brick",nil];
    result = [[NSMutableString alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createString:(id)sender {
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
            [result appendString:@"@\""];
            [result appendString:[NSString stringWithFormat:@"%i",i]];
            [result appendString:@"\","];
            [result appendString:@"@\""];
            [result appendString:[NSString stringWithFormat:@"%i",j]];
            [result appendString:@"\","];
            [result appendString:@"@\""];
            [result appendString:[NSString stringWithFormat:@"%@",[button accessibilityIdentifier]]];
            [result appendString:@"\","];
            if(i==6 && j==6){
                [result appendString:@"nil]"];
            }
        }
    }
    
    NSLog(@"result = %@",result); //copy paste that to Blustrick project
    //NSLog(@"result length = %@",result.length); //copy paste that to Blustrick project
}

- (IBAction)reset:(id)sender {
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

-(void)createButtons{
    UIButton *btn;
    for (int i=0; i<7; i++) {
        for (int j=0; j<7; j++) {
            btn = [[UIButton alloc] initWithFrame:CGRectMake(20+i*40, 50+j*40, 40, 40)];
            [btn setImage:[UIImage imageNamed:@"bold_brick"] forState:UIControlStateNormal];
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
    [sender setImage:[UIImage imageNamed:[icons objectAtIndex:imageIndex]] forState:UIControlStateNormal];
    [sender setAccessibilityIdentifier:[icons objectAtIndex:imageIndex]];
    if (imageIndex+1 < [icons count]) {
        imageIndex++;
    } else {
        imageIndex = 0;
    }
}

@end
