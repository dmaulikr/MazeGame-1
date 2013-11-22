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
    
    return self;
}

-(void) setDoor:(bool)d { isDoor = d; }
-(void) setKey:(bool)k { isKey = k; }
-(void) setCheckpoint:(bool)c { isCheckpoint = c; }
-(void) setPlayer:(bool)p { hasPlayer = p; }
-(void) setNumStepsAllowed:(int)num { numStepsAllowed = num; }
-(void) decrementOne { numStepsAllowed--; }
-(bool) isDoor { return isDoor; }
-(bool) isKey { return isKey; }
-(bool) isCheckpoint { return isCheckpoint; }
-(bool) hasPlayer { return hasPlayer; }
-(int) getNumSteps { return numStepsAllowed; }

@end
