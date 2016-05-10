//
//  GameData.h
//  Bounce
//
//  Created by Ryan on 2/27/16.
//  Copyright (c) 2016 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject
@property int highScore;

+(id)data;
-(void)save;
-(void)load;
@end
