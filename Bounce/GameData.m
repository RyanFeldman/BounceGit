//
//  GameData.m
//  Bounce
//
//  Created by Ryan on 2/27/16.
//  Copyright (c) 2016 ryan. All rights reserved.
//

#import "GameData.h"

@interface GameData()
@property NSString *filePath;

@end

@implementation GameData

//
+(id)data {
    GameData *data = [GameData new];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = @"archive.data";
    data.filePath = [path stringByAppendingString:fileName];
    
    return data;
}

-(void)save {
    NSNumber *highScoreObject = [NSNumber numberWithInt:self.highScore];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:highScoreObject];
    [data writeToFile:self.filePath atomically:YES];
}

-(void)load {
    NSData *data = [NSData dataWithContentsOfFile:self.filePath];
    NSNumber *highScoreObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    self.highScore = highScoreObject.intValue;
}

@end
