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

#define WIDTH_TILE 80
#define HEIGHT_TILE 80
#define WIDTH_WINDOW 320
#define HEIGHT_WINDOW 480
#define DELAY_IN_SECONDS 0.15
#define Y_OFF_SET 0
#define HEIGHT_GAME HEIGHT_WINDOW
#define WIDTH_GAME WIDTH_WINDOW
#define NUM_ROWS (HEIGHT_GAME / HEIGHT_TILE)
#define NUM_COLUMNS (WIDTH_GAME / WIDTH_TILE)
bool endLevel = false;

-(id) init {
    if ((self = [super init])) {
        
        [self schedule:@selector(nextFrame) interval:DELAY_IN_SECONDS];
        [self initLevel:@"level1.plist"];
        [self scheduleUpdate];
        
    }
    return self;
}

-(void) initLevel: (NSString*) levelFile {
    
    NSDictionary* level = [NSDictionary dictionaryWithContentsOfFile: levelFile];
    int w = [[level objectForKey:@"width"] integerValue];
    int h = [[level objectForKey:@"height"] integerValue];
    NSArray* start = [level objectForKey:@"start"];
    NSArray* door = [level objectForKey:@"door"];
    NSArray* key = [level objectForKey:@"key"];
    NSArray* levelLayout = [level objectForKey:@"levelLayout"];
    
    gameSpace = [[NSMutableArray alloc] init];
    for (int gridWidth = 0; gridWidth < w; gridWidth++) {
        
        NSMutableArray* subArr = [[NSMutableArray alloc] init];
        for (int gridHeight = 0; gridHeight < h; gridHeight++) {
            
            [subArr addObject:
             [[TileSpace alloc] initWithDoor:false initWithKey:false
                                initWithCheckpoint:false initWithPlayer:false
                                initWithNumStepsAllowed:
                                    [[[levelLayout
                                       objectAtIndex:gridWidth]
                                       objectAtIndex:gridHeight]
                                        integerValue]
              ]];
        }
        [gameSpace addObject: subArr];
    }
    [[[gameSpace objectAtIndex:[[key objectAtIndex:0] integerValue]] objectAtIndex:[[key objectAtIndex:1] integerValue]] setKey:true];
    [[[gameSpace objectAtIndex:[[start objectAtIndex:0] integerValue]] objectAtIndex:[[start objectAtIndex:1] integerValue]] setPlayer:true];
    [[[gameSpace objectAtIndex:[[door objectAtIndex:0] integerValue]] objectAtIndex:[[door objectAtIndex:1] integerValue]] setDoor:true];
}

-(void) draw
{
    ccColor4F rectColor = ccc4f(0.5, 0.5, 0.5, 1.0); //parameters correspond to red, green, blue, and alpha (transparancy)
    ccDrawSolidRect(ccp(0,0 + Y_OFF_SET), ccp(WIDTH_GAME, HEIGHT_GAME + Y_OFF_SET), rectColor);
    
    
    for(int row = 0; row < HEIGHT_GAME; row += WIDTH_TILE)
    {
        ccDrawLine(ccp(0, row + Y_OFF_SET), ccp(WIDTH_GAME, row + Y_OFF_SET));
        
    }
    
    for (int col = 0; col <= WIDTH_GAME; col += WIDTH_TILE) {
        ccDrawLine(ccp(col, 0 + Y_OFF_SET), ccp(col, HEIGHT_GAME + Y_OFF_SET));
    }
}

-(void) update: (ccTime) delta
{
    KKInput* input = [KKInput sharedInput];
    input.gestureSwipeEnabled = YES;
    
    TileSpace* playerTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
    
    if (input.gestureSwipeRecognizedThisFrame) {
        KKSwipeGestureDirection dir = input.gestureSwipeDirection;
        [playerTile decrementOne];
        switch (dir) {
            case KKSwipeGestureDirectionDown:
                playerLocY--;
                break;
            case KKSwipeGestureDirectionLeft:
                playerLocX--;
                break;
            case KKSwipeGestureDirectionRight:
                playerLocX++;
                break;
            case KKSwipeGestureDirectionUp:
                playerLocY++;
                break;
        }
        playerTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
        if ([playerTile getNumSteps] < 0) { /* game over the player fell */ }
        else {
            if ([playerTile isKey]) { hasKey = true; }
            if ([playerTile isCheckpoint]) {
                checkpointX = playerLocX;
                checkpointY = playerLocY;
                hasCheckpoint = true;
            }
            [playerTile setPlayer:true];
        }
    }

}

-(void) nextFrame
{
    
}

-(void) updateGrid
{
    //updates the grid array after there is a move
}

@end
