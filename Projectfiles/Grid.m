//
//  Grid.m
//  MazeGame
//
//  Created by Jerry Jei-Rui Bao on 10/30/13.
//
//

#import "Grid.h"
#import "TileSpace.h"

@implementation Grid

#define WIDTH_TILE 40
#define HEIGHT_TILE 40
#define WIDTH_WINDOW 320
#define HEIGHT_WINDOW 480
#define DELAY_IN_SECONDS 0.15


-(id) init {
    if ((self = [super init])) {
        
        
    }
    [self schedule:@selector(nextFrame) interval:DELAY_IN_SECONDS];
    [self scheduleUpdate];
    return self;
}

-(void) initWidth:(int)w initHeight:(int)h {
        
    gameSpace = [[NSMutableArray alloc] init];
    for (int width = 0; width < w; width++) {
        
        NSMutableArray* subArr = [[NSMutableArray alloc] init];
        for (int height = 0; height < h; height++) {
            [subArr addObject: [[TileSpace alloc] initWithDoor:false initWithKey:false initWithCheckpoint:false initWithNumStepsAllowed:0]];
        }
        [gameSpace addObject: subArr];
    }
}

-(void) update: (ccTime) delta
{
    //sense the gestures
}

-(void) nextFrame
{
    //will call all updates for the next frame after a swipe gesture
}

-(void)updateGrid
{
    //updates the grid array after there is a move
}

@end
