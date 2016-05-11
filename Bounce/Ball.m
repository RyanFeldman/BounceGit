//
//  Ball.m
//  Bounce
//
//  Created by Ryan on 2/11/16.
//  Copyright (c) 2016 ryan. All rights reserved.
//

#import "Ball.h"

const uint32_t ballCategory = 0x1 << 0;
const uint32_t paddleCategory = 0x1 << 1;
const double size = 15;
const double gravity = -300.0;
const int numberOfColors = 5;

@implementation Ball {


double xVel; //Velocity in x direction
double yVel;
double x;
double y;
double xi; //Initial x (of this "bounce")
double yi; //Initial y (of this "bounce"(
double startTime;
double timeTilGround; //Time it HITS ground
int bounceNumber; //number of position it will hit next (1/2/3)
    
}


-(id)init {
    //Choose color at random
    int r = arc4random_uniform(numberOfColors);
    UIColor *color;
    if (r == 0)
        color = [UIColor redColor];
    else if (r == 1)
        color = [UIColor cyanColor];
    else if (r == 2)
        color = [UIColor yellowColor];
    else if (r == 3)
        color = [UIColor magentaColor];
    else
        color = [UIColor orangeColor];
    
    self = [super initWithColor:color size:CGSizeMake(size, size)];
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.categoryBitMask = ballCategory;
    self.physicsBody.contactTestBitMask = paddleCategory;
    self.physicsBody.allowsRotation = NO;
    xVel = 0;
    yVel = 0;
    
    timeTilGround = 0;
    
    return self;
}

-(void)start:(double)initialV withX:(double)xPos withY:(double)yPos withTime:(double)time withTimeGround:(double)tGround{
    xVel = initialV;
    startTime = time;
    xi = xPos;
    yi = yPos;
    x = xi;
    y = yi;
    timeTilGround = tGround;
    self.position = CGPointMake(x, y);
    bounceNumber = 1;
}

//Update ball position
-(void)move:(double)currentTime {
    double timePassed = currentTime - startTime;
    x = xi + xVel * timePassed;
    y = yi + (yVel * timePassed) + (.5)*(gravity)*(timePassed*timePassed);
    
    SKAction *calcPosition = [SKAction moveByX:(x-self.position.x) y:(y-self.position.y) duration:0];
    [self runAction:calcPosition];
}

//Called when ball hits a paddle, reset for next path. paddleSize = horizontal length
-(void)bounce:(double)velocity withTime:(double)time withAngle:(double)angle withTimeTilGround:(double)t{
    
    bounceNumber ++;
    
    xVel = velocity * cos(angle);
    yVel = velocity * sin(angle);
    xi = self.position.x;
    yi = self.position.y;
    
    startTime = time;
    
    timeTilGround = t;
    
}

-(double)getGravity {
    return gravity;
}

-(double)getTimeTilGround {
    return timeTilGround;
}

-(int)getBounceNumber {
    return bounceNumber;
}

@end












