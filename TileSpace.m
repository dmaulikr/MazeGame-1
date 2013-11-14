//
//  TileSpace.m
//  MazeGame
//
//  Created by Jerry Jei-Rui Bao on 10/31/13.
//
//

#import "TileSpace.h"

@implementation TileSpace

-(id) initWithDoor:(bool)d initWithKey:(bool)k initWithCheckpoint:(bool)c initWithPlayer:(bool)p initWithNumStepsAllowed:(int)num {
    if ((self = [super init])) {
        
        isDoor = d;
        isKey = k;
        isCheckpoint = c;
        hasPlayer = p;
        numStepsAllowed = num;
    }
}

@end
