//
//  CFMyScene.m
//  spritetest
//
//  Created by Brad on 2/16/14.
//  Copyright (c) 2014 Brad. All rights reserved.
//

#import "CFMyScene.h"
@import CoreMotion;


@interface CFMyScene  ()

{
    
int _nextFlappy;
double _nextFlappySpawn;
    
}

@property (strong,nonatomic) SKSpriteNode *eagle;
@property (strong,nonatomic) CMMotionManager *motionManager;
@property (strong,nonatomic) NSMutableArray *flappyArray;
#define kNumFlappys   10

@end

@implementation CFMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        NSLog(@"SKScene:initWithSize %f x %f",size.width,size.height);
        
        _nextFlappySpawn = 0;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        for (int i = 0; i < 2; i++) {
            SKSpriteNode * bg = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
            bg.anchorPoint = CGPointZero;
            bg.position = CGPointMake(i * bg.size.width, 0);
            bg.name = @"background";
            [self addChild:bg];
        }
       
        self.eagle = [SKSpriteNode spriteNodeWithImageNamed:@"eagle.png"];
        self.eagle.position = CGPointMake(self.frame.size.width *.2, self.frame.size.height *.5);
        [self addChild:self.eagle];
        
        //move the ship using Sprite Kit's Physics Engine
        //1
        self.eagle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.eagle.frame.size];
        
        //2
       self.eagle.physicsBody.dynamic = YES;
        
        //3
        self.eagle.physicsBody.affectedByGravity = YES;
        
        //4
        self.eagle.physicsBody.mass = 0.02;
        
        _motionManager = [[CMMotionManager alloc] init];
        
        //[self startMotion];
        
        
        
    }
    
    self.flappyArray = [[NSMutableArray alloc] initWithCapacity:kNumFlappys];
    for (int i = 0; i < kNumFlappys; ++i) {
        SKSpriteNode *flappy = [SKSpriteNode spriteNodeWithImageNamed:@"flappy"];
        flappy.hidden = YES;
        [self.flappyArray addObject:flappy];
        [self addChild:flappy];
    }
    return self;
}

-(void)startMotion
{
    if (self.motionManager.accelerometerAvailable) {
        [self.motionManager startAccelerometerUpdates];
        NSLog(@"accelerometer updates on...");
    }
    
}

- (void)stopMonitoringAcceleration
{
    if (self.motionManager.accelerometerAvailable && _motionManager.accelerometerActive) {
        [self.motionManager stopAccelerometerUpdates];
        NSLog(@"accelerometer updates off...");
    }
}

-(void)update:(CFTimeInterval)currentTime {
    [self enumerateChildNodesWithName:@"background" usingBlock: ^(SKNode *node, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *) node;
        bg.position = CGPointMake(bg.position.x - 5, bg.position.y);
        
        if (bg.position.x <= -bg.size.width) {
            bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y);
        }
    }];
    
    double curTime = CACurrentMediaTime();
    
    if (curTime > _nextFlappySpawn)
    {
        //NSLog(@"spawning new asteroid");
        float randSecs = [self randomValueBetween:0.20 andValue:1.0];
        _nextFlappySpawn = randSecs + curTime;
        
        float randY = [self randomValueBetween:0.0f andValue:self.frame.size.height - 30.0f];
        float randDuration = [self randomValueBetween:5.0f andValue:8.0f];
        
        SKSpriteNode *flappy = self.flappyArray[_nextFlappy];
        _nextFlappy++;
        
        if (_nextFlappy >= self.flappyArray.count)
        {
            _nextFlappy = 0;
        }
        
        [flappy removeAllActions];
        flappy.position = CGPointMake(self.frame.size.width + flappy.size.width/2, randY);
        flappy.hidden = NO;
        
        CGPoint location = CGPointMake(-600, randY);
        
        SKAction *moveAction = [SKAction moveTo:location duration:randDuration];
        SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
            flappy.hidden = YES;
        }];
        
        SKAction *moveFlappyActionWithDone = [SKAction sequence:@[moveAction,doneAction]];
        [flappy runAction:moveFlappyActionWithDone];
        
    }
    //[self updateShipPositionFromMotionManager];
}

- (void)updateShipPositionFromMotionManager
{
    CMAccelerometerData* data = _motionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.2) {
        NSLog(@"acceleration value = %f",data.acceleration.x);
        [self.eagle.physicsBody applyForce:CGVectorMake(0.0, -10.0 * data.acceleration.x)];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.eagle.physicsBody setVelocity:CGVectorMake(0, 0)];
    [self.eagle.physicsBody applyImpulse:CGVectorMake(0,7)];
}

- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}



@end
