//
//  Grid.h
//  MazeGame
//
//  Created by Jerry Jei-Rui Bao on 10/30/13.
//
//

#import "CCLayer.h"

@interface Grid : CCLayer {
    NSMutableArray* gameSpace;
    NSNumber* playerLocX;
    NSNumber* playerLocY;
    NSNumber* checkpointX;
    NSNumber* checkpointY;
    bool hasCheckpoint;
    bool hasKey;
}

-(void) initLevel: (NSString*) levelFile;
-(void) draw;
-(void) update: (ccTime) delta;

@end
