//
//  TileSpace.h
//  MazeGame
//
//  Created by Jerry Jei-Rui Bao on 10/31/13.
//
//

#import "CCLayer.h"

@interface TileSpace : CCLayer {
    bool isDoor;
    bool isKey;
    bool isCheckpoint;
    bool hasPlayer;
    int numStepsAllowed;
}

-(id) initWithDoor:(bool)d initWithKey:(bool)k initWithCheckpoint:(bool)c initWithPlayer:(bool)p initWithNumStepsAllowed:(int)num;
-(void) setDoor:(bool)d;
-(void) setKey:(bool)k;
-(void) setCheckpoint:(bool)c;
-(void) setPlayer:(bool)p;
-(void) setNumStepsAllowed:(int)num;
-(void) decrementOne;
-(bool) isDoor;
-(bool) isKey;
-(bool) isCheckpoint;
-(bool) hasPlayer;
-(int) getNumSteps;


@end
