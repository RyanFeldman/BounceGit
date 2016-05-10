//
//  GameScene.m
//  Bounce
//
//  Created by Ryan on 2/3/16.
//  Copyright (c) 2016 ryan. All rights reserved.
//

#import "GameScene.h"
#import "GameData.h"
#import "Ball.h"

int position = 1;
int level = 1;
int count = 0;
int goneCount = 0;
int lives = 3;
int score = 0;
int highScore;
int combo = 0;
double minTime = 5;
double initialV;
double startHeight; //Height of new ball
double t = 0; //Time
double timeLastBall; //Time last ball was started
bool gameIsRunning = false;
bool howToPlayShowing = false;
SKSpriteNode *paddle;
NSMutableArray *balls;
NSMutableArray *livesDisplayed;
SKLabelNode *scoreLabel;
SKLabelNode *highScoreLabel;
SKLabelNode *comboLabel;
SKLabelNode *howToPlay;

static const double lifeSize = 10.0;
static const double distanceBetweenLives = 5.0;
static const double MIN_TIME_BETWEEN_BALLS = 0.45;
static const double NEW_BALL_MULTIPLIER = 1.5; //Multiplier of time between new ball added and any other ball
static const int STARTING_LIVES = 4;

@implementation GameScene

static const uint32_t paddleCategory = 0x1 << 1;

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    self.anchorPoint = CGPointMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    self.backgroundColor = [UIColor blackColor];
    
    [self startNewGame];
}

-(void)startNewGame {
    
    /* Paddle setup */
    paddle = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(self.frame.size.width/3.0, 10)];
    paddle.position = CGPointMake(paddle.size.width/2.0, paddle.size.height/2.0);
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:paddle.size];
    paddle.physicsBody.dynamic = NO;
    paddle.physicsBody.categoryBitMask = paddleCategory;
    [self addChild:paddle];
    
    howToPlay = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    howToPlay.text = @"Tap either side to move paddle!";
    howToPlay.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    howToPlay.fontSize = 18;
    [self addChild:howToPlay];
    howToPlayShowing = true;
    
    //Calculate initial velocity for new balls
    Ball *test = [[Ball alloc] init];
    startHeight = self.frame.size.height-100; //startHeight set
    double time = sqrt((2*(startHeight-paddle.size.height))/(-1*test.getGravity));
    initialV = ((paddle.size.width/2)+(test.size.width/2.0)) / time;
    
    //Balls Mutable Array setup
    balls = [[NSMutableArray alloc] init];
    
    //Reset all values
    score = 0;
    combo = 0;
    level = 1;
    position = 1;
    lives = STARTING_LIVES;
    goneCount = 0;
    count = 0;
    
    //Set up labels
    scoreLabel = [[SKLabelNode alloc] init];
    scoreLabel.fontName = @"Helvetica";
    scoreLabel.text = @"0";
    scoreLabel.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-50.0);
    [self addChild:scoreLabel];
    
    comboLabel = [[SKLabelNode alloc] init];
    comboLabel.fontName = @"Helvetica";
    comboLabel.text = @"Combo: x1";
    comboLabel.fontSize = 12;
    comboLabel.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-65.0);
    [self addChild:comboLabel];
    
    GameData *data = [GameData data];
    [data load];
    highScore = data.highScore;
    
    highScoreLabel = [[SKLabelNode alloc] init];
    highScoreLabel.fontName = @"Helvetica";
    highScoreLabel.text = [NSString stringWithFormat:@"%d", highScore];
    highScoreLabel.position = CGPointMake(self.frame.size.width-50.0, self.frame.size.height-50.0);
    highScoreLabel.fontSize = 25;
    [self addChild:highScoreLabel];
    
    
    //Display lives
    [self startDisplayLives];
    
    [self setPaused:false];
    gameIsRunning = true;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    if (howToPlayShowing) {
        [howToPlay setHidden:true];
        howToPlayShowing = false;
    }
    
    for (UITouch *touch in touches) {
        //Touch to move paddle
        if (gameIsRunning) {
            CGPoint location = [touch locationInNode:self];
            //Set paddle location
            if (location.x > self.frame.size.width/2.0)
                position = MIN(3, position+1);
            else
                position = MAX(1, position-1);
            paddle.position = CGPointMake(paddle.size.width/2.0 + (position-1)*paddle.size.width, paddle.size.height/2.0);
        }
        //Game Over, touch to resume game
        else {
            GameScene *gameScene = [[GameScene alloc] initWithSize:self.frame.size];
            [self.view presentScene:gameScene];
            //Only want howToPlay on first time
            [howToPlay setHidden:true];
            howToPlayShowing = false;
        }
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    t = (double)currentTime;
    
    //Add new ball to balls if count of balls so far is less than level
    if (count < level && currentTime - timeLastBall > minTime) {
        Ball *temp = [[Ball alloc] init];
        double timeGround = t + paddle.size.width/(initialV);
        bool works = true;
        for (long i=balls.count-1;i >= 0;i--) {
            Ball *test = [balls objectAtIndex:i];
            if (test.getBounceNumber > 1 && timeGround <= test.getTimeTilGround + NEW_BALL_MULTIPLIER*MIN_TIME_BETWEEN_BALLS*(test.getBounceNumber-1) && timeGround >= test.getTimeTilGround - NEW_BALL_MULTIPLIER*MIN_TIME_BETWEEN_BALLS*(test.getBounceNumber-1)) {
                works = false;
                break;
            }
            
        }
        if (works) {
            count ++;
            [self addChild:temp];
            [temp start:initialV withX:(-1*(temp.size.width/2)) withY:startHeight withTime:currentTime withTimeGround:timeGround];
            [balls addObject:temp];
            timeLastBall = currentTime;
            minTime = (arc4random_uniform(7) + 1)/2.0;
        }
    }
    
    if (balls.count > 0) { //If array is empty, don't bother
        
    
        //Update ball's positions and check if life lost
        for (long i=balls.count-1;i >= 0;i--) {
            Ball *ball = [balls objectAtIndex:i];
            [ball move:currentTime];
            //Remove any ball out of screen
            if (ball.position.x >= self.frame.size.width+ball.size.width/2.0) {
                [balls removeObjectAtIndex:i];
                [ball removeFromParent];
                goneCount ++;
            }
            //Check if life lost
            else if (ball.position.y <= -1*(ball.size.height/2.0)) {
                lives --;
                //Display lives
                if (lives >= 0)
                    [self startDisplayLives];
                if (lives > 0)//Keep combo if gameover
                    combo = 0;
                goneCount ++;
                [balls removeObjectAtIndex:i];
                [ball removeFromParent];
                if (lives < 1)
                    [self gameOver];
            }
        }
    }
    
    //New level
    if (goneCount == level) {
        level++;
        goneCount = 0;
        count = 0;
    }
    
    
    
    //Update scoreLabel and comboLabel
    scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    comboLabel.text = [NSString stringWithFormat:@"Combo: x%d", combo];
    
    
}

-(void)gameOver {
    gameIsRunning = false;
    if (howToPlayShowing) {
        [howToPlay setHidden:true];
        howToPlayShowing = false;
    }
    [self setPaused:true];
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    gameOverLabel.text = @"Game Over";
    gameOverLabel.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    [self addChild:gameOverLabel];
    
    
}

-(void)startDisplayLives {
    if (livesDisplayed.count > 0) {
        for (SKSpriteNode *life in livesDisplayed) {
            [life removeFromParent];
        }
    }
    livesDisplayed = [[NSMutableArray alloc] init];
    if (lives != 0)
        [self displayLives:0 withLivesLeft:lives];
}

//Recursively display lives to center them
-(void)displayLives:(int)numBetween withLivesLeft: (int)livesLeft{
    if (livesLeft % 2 == 1) { //Will be first life displayed
        SKSpriteNode *tempLife = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(lifeSize, lifeSize)];
        tempLife.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-80.0);
        [livesDisplayed addObject:tempLife];
        [self addChild:tempLife];
        if (livesLeft != 1)
            [self displayLives:1 withLivesLeft: livesLeft-1];
    }
    else {
        double distanceOffCenter = numBetween*lifeSize/2.0 + (numBetween+1)*distanceBetweenLives/2.0 + lifeSize/2.0;
        //Life to the right
        SKSpriteNode *tempLife = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(lifeSize, lifeSize)];
        tempLife.position = CGPointMake(self.frame.size.width/2.0-distanceOffCenter, self.frame.size.height-80.0);
        [self addChild:tempLife];
        //Life to the left
        SKSpriteNode *tempLife2 = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(lifeSize, lifeSize)];
        tempLife2.position = CGPointMake(self.frame.size.width/2.0+distanceOffCenter, self.frame.size.height-80.0);
        [livesDisplayed addObject:tempLife];
        [livesDisplayed addObject:tempLife2];
        [self addChild:tempLife2];
        if (livesLeft-2 != 0)
            [self displayLives: (numBetween+2) withLivesLeft:(livesLeft-2)];
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    Ball *ball = (Ball*)contact.bodyB.node;
    combo ++;
    score += combo;
    if (score > highScore) {
        highScore = score;
        highScoreLabel.text = [NSString stringWithFormat:@"%d", highScore];
        GameData *data = [GameData data];
        data.highScore = highScore;
        [data save];
    }
    
    double angle = 1;
    double velocity = 0;
    double timeTilGround = 0;
    
    for (int i=0;i < 50;i++) {
        bool works = true;
        angle = arc4random_uniform(36) + 45; //Choose angle between 55 and 80
        angle *= M_PI/180.0; //Convert to radians
        velocity = sqrt((-1*ball.getGravity*paddle.size.width)/(sin(2.0*angle))); //Initial velocity
        timeTilGround = t + paddle.size.width/(velocity*cos(angle));
        double multiplier; //If balls in position 1/3 or 3/1, make time til ground * 2.25
        if (ball.getBounceNumber != 3) {
            for (long i=balls.count-1;i >= 0;i--) {
                multiplier = 1.0;
                Ball *test = [balls objectAtIndex:i];
                if ((ball.getBounceNumber == 1 && test.getBounceNumber == 3) || (ball.getBounceNumber == 3 && test.getBounceNumber == 1))
                    multiplier = 2.25;
                if (test.getBounceNumber != ball.getBounceNumber + 1 &&
                    test.getBounceNumber <= 3) {
                    if (timeTilGround <= test.getTimeTilGround + MIN_TIME_BETWEEN_BALLS*multiplier && timeTilGround >= test.getTimeTilGround - MIN_TIME_BETWEEN_BALLS*multiplier) {
                        works = false;
                        break;
                    }
                }
            
            }
        }
        
        if (works)
            break;
        if (i == 49)
            NSLog(@"UH OH SPAGHETTIOS");
        
        
    }
    
    //Play bounce sounds
    NSString *bounceSound;
    if (ball.getBounceNumber == 1)
        bounceSound = @"Beep1.mp3";
    else if (ball.getBounceNumber == 2)
        bounceSound = @"Beep2.mp3";
    else
        bounceSound = @"Beep3.mp3";
    
    [self runAction:[SKAction playSoundFileNamed:bounceSound waitForCompletion:NO]];
    
    
    [ball bounce:velocity withTime:t withAngle:angle withTimeTilGround:timeTilGround];
    
}









@end
