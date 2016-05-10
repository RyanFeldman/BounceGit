//
//  Ball.h
//  Bounce
//
//  Created by Ryan on 2/11/16.
//  Copyright (c) 2016 ryan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Ball : SKSpriteNode

- (id)init;
- (double)getGravity;
- (void)move:(double)currentTime;
- (void)start:(double)initialV withX:(double)xPos withY:(double)yPos withTime:(double)time withTimeGround:(double)tGround;
- (void)bounce:(double)velocity withTime:(double)time withAngle:(double)angle withTimeTilGround:(double)t;
- (double)getTimeTilGround;
- (int)getBounceNumber;

@end
