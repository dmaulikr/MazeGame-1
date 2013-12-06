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
        levelFile = @"level1.plist";
        [self initLevel:levelFile];
        [self scheduleUpdate];
        
    }
    return self;
}

-(void) initLevel: (NSString*) levelFile {
    
    NSDictionary* level = [NSDictionary dictionaryWithContentsOfFile: levelFile];
    maxX = [[level objectForKey:@"width"] integerValue];
    maxY = [[level objectForKey:@"height"] integerValue];
    NSArray* start = [level objectForKey:@"start"];
    NSArray* door = [level objectForKey:@"door"];
    NSArray* key = [level objectForKey:@"key"];
    NSArray* levelLayout = [level objectForKey:@"levelLayout"];
    
    gameSpace = [[NSMutableArray alloc] init];
    for (int gridWidth = 0; gridWidth < maxX; gridWidth++) {
        
        NSMutableArray* subArr = [[NSMutableArray alloc] init];
        for (int gridHeight = 0; gridHeight < maxY; gridHeight++) {
            
            int numStepsAllowed = [[[levelLayout
                                     objectAtIndex:gridWidth]
                                     objectAtIndex:gridHeight]
                                     integerValue];
            [subArr addObject:
             [[TileSpace alloc] initWithDoor:false initWithKey:false
                                initWithCheckpoint:false initWithPlayer:false
                                initWithNumStepsAllowed:numStepsAllowed]];
            if (numStepsAllowed > 0) { numTilesLeft++; }
        }
        [gameSpace addObject: subArr];
    }
    [[[gameSpace objectAtIndex:[[key objectAtIndex:0] integerValue]] objectAtIndex:[[key objectAtIndex:1] integerValue]] setKey:true];
    [[[gameSpace objectAtIndex:[[start objectAtIndex:0] integerValue]] objectAtIndex:[[start objectAtIndex:1] integerValue]] setPlayer:true];
    playerLocX = [[start objectAtIndex:0] integerValue];
    playerLocY = [[start objectAtIndex:1] integerValue];
    [[[gameSpace objectAtIndex:[[door objectAtIndex:0] integerValue]] objectAtIndex:[[door objectAtIndex:1] integerValue]] setDoor:true];

}

-(void) draw
{
    ccColor4F red = ccc4f(1.0, 0.0, 0.0, 1.0); //parameters correspond to red, green, blue, and alpha (transparancy)
    ccColor4F blue = ccc4f(0.0, 0.0, 1.0, 1.0);
    ccColor4F green = ccc4f(0.0, 0.8, 0.0, 1.0);
    ccColor4F yellow = ccc4f(1.0, 1.0, 0.0, 1.0);
    ccColor4F white = ccc4f(1.0, 1.0, 1.0, 1.0);
    ccColor4F brown = ccc4f(0.5, 0.25, 0.0, 1.0);
    
    for(int row = 0; row < HEIGHT_GAME; row += WIDTH_TILE)
    {
        ccDrawLine(ccp(0, row + Y_OFF_SET), ccp(WIDTH_GAME, row + Y_OFF_SET));
    }
    
    for (int col = 0; col <= WIDTH_GAME; col += WIDTH_TILE) {
        ccDrawLine(ccp(col, 0 + Y_OFF_SET), ccp(col, HEIGHT_GAME + Y_OFF_SET));
    }
    
    for (int row = 0; row < NUM_COLUMNS; row += 1) {
        for (int col = 0; col < NUM_ROWS; col += 1) {
            if ([gameSpace[row][col] isKey] && [gameSpace[row][col] getNumSteps] > 0) {
                ccDrawSolidRect(ccp(row + (WIDTH_TILE * row), col + (WIDTH_TILE * col)), ccp(row + (WIDTH_TILE * row) + WIDTH_TILE, col + (WIDTH_TILE * col) + WIDTH_TILE), yellow);
            } else if ([gameSpace[row][col] isDoor] && [gameSpace[row][col] getNumSteps] > 0) {
                ccDrawSolidRect(ccp(row + (WIDTH_TILE * row), col + (WIDTH_TILE * col)), ccp(row + (WIDTH_TILE * row) + WIDTH_TILE, col + (WIDTH_TILE * col) + WIDTH_TILE), brown);
            } else if ([gameSpace[row][col] hasPlayer] && [gameSpace[row][col] getNumSteps] > 0) {
                ccDrawSolidRect(ccp(row + (WIDTH_TILE * row), col + (WIDTH_TILE * col)), ccp(row + (WIDTH_TILE * row) + WIDTH_TILE, col + (WIDTH_TILE * col) + WIDTH_TILE), white);
            } else if ([gameSpace[row][col] getNumSteps] == 2) {
                ccDrawSolidRect(ccp(row + (WIDTH_TILE * row), col + (WIDTH_TILE * col)), ccp(row + (WIDTH_TILE * row) + WIDTH_TILE, col + (WIDTH_TILE * col) + WIDTH_TILE), blue);
            } else if ([gameSpace[row][col] getNumSteps] <= 0) {
                ccDrawSolidRect(ccp(row + (WIDTH_TILE * row), col + (WIDTH_TILE * col)), ccp(row + (WIDTH_TILE * row) + WIDTH_TILE, col + (WIDTH_TILE * col) + WIDTH_TILE), red);
            } else if ([gameSpace[row][col] getNumSteps] == 1) {
                ccDrawSolidRect(ccp(row + (WIDTH_TILE * row), col + (WIDTH_TILE * col)), ccp(row + (WIDTH_TILE * row) + WIDTH_TILE, col + (WIDTH_TILE * col) + WIDTH_TILE), green);
            }
        }
    }
}

-(void) update: (ccTime) delta
{
    KKInput* input = [KKInput sharedInput];
    input.gestureSwipeEnabled = YES;
    
    TileSpace* playerTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
    TileSpace* nextTile;
    
    if (input.gestureSwipeRecognizedThisFrame) {
        KKSwipeGestureDirection dir = input.gestureSwipeDirection;
        [playerTile decrementOne];
        if ([playerTile getNumSteps] == 0) { numTilesLeft--; }
        switch (dir) {
            case KKSwipeGestureDirectionDown:
                if (playerLocY > 0) {
                    playerLocY--;
                    nextTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
                    [playerTile setPlayer:false];
                    [nextTile setPlayer:true];
                }
                break;
            case KKSwipeGestureDirectionLeft:
                if (playerLocX > 0) {
                    playerLocX--;
                    nextTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
                    [playerTile setPlayer:false];
                    [nextTile setPlayer:true];
                }
                break;
            case KKSwipeGestureDirectionRight:
                if (playerLocX < maxX - 1) {
                    playerLocX++;
                    nextTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
                    [playerTile setPlayer:false];
                    [nextTile setPlayer:true];
                }
                break;
            case KKSwipeGestureDirectionUp:
                if (playerLocY < maxY - 1) {
                    playerLocY++;
                    nextTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
                    [playerTile setPlayer:false];
                    [nextTile setPlayer:true];
                }
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
            if ([playerTile isDoor]) {
                if (hasKey && numTilesLeft) { /* game over player won */ }
                else { /* let them know they need to get the key */ }
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
    
}

@end
