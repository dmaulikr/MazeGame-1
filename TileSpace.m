//
//  TileSpace.m
//  MazeGame
//
//  Created by Jerry Jei-Rui Bao on 10/31/13.
//
//

#import "TileSpace.h"

@implementation TileSpace

-(id) initDoor:(bool)d initKey:(bool)k initCheckpoint:(bool)c initNumStepsAllowed:(int)num {
    if ((self = [super init])) {
        
        isDoor = d;
        isKey = k;
        isCheckpoint = c;
        numStepsAllowed = num;
    }
}

@end
