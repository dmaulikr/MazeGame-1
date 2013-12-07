//
//  Grid.m
//  MazeGame
//
//  Created by Jerry Jei-Rui Bao on 10/30/13.
//
//

#import "Grid.h"
#import "TileSpace.h"
#import "LevelSelectLayer.h"

CCSprite *runner;
CCSprite *key;

@implementation Grid

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
        runner = [CCSprite spriteWithFile:@"runner.png"];
        runner.position = ccp(20, 20);
        runner.scale = 0.3;
        key = [CCSprite spriteWithFile:@"key.gif"];
        key.position = ccp(20, 20);
        key.scale = 0.5;
        [self addChild:runner];
        [self addChild:key];
        [self initLevel:levelFile];
        
        [self scheduleUpdate];
    }
    return self;
}

+(id) scene: (NSString*) level {
    CCScene* gameScene = [CCScene node];
    Grid* layer = [Grid node];
    [layer initLevel:level];
    [gameScene addChild: layer];
    return gameScene;
}

-(void) initLevel: (NSString*) levelFile {
    
    key.visible = false;
    hasKey = false;
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
    ccColor4F brown = ccc4f(0.5, 0.25, 0.0, 1.0);
    int widthBlock = WIDTH_WINDOW / maxX;
    int heightBlock = HEIGHT_WINDOW / maxY;
    
    for(int row = 0; row < HEIGHT_WINDOW; row += widthBlock)
    {
        ccDrawLine(ccp(0, row), ccp(WIDTH_WINDOW, row));
    }
    
    for (int col = 0; col <= WIDTH_GAME; col += widthBlock) {
        ccDrawLine(ccp(col, 0 + Y_OFF_SET), ccp(col, HEIGHT_GAME + Y_OFF_SET));
    }
    
    for (int row = 0; row < maxX; row += 1) {
        for (int col = 0; col < maxY; col += 1) {
            if ([gameSpace[row][col] hasPlayer] && [gameSpace[row][col] getNumSteps] > 0) {
                runner.position = ccp(row + (widthBlock * row) + 40, col + (heightBlock * col) + 40);
                key.position = ccp(row + (widthBlock * row) + 70, col + (heightBlock * col) + 35);
   
                if (hasKey) {
                    key.visible = true;
                }
            }
            if ([gameSpace[row][col] isKey] && [gameSpace[row][col] getNumSteps] > 0) {
                ccDrawSolidRect(ccp(row + (widthBlock * row), col + (heightBlock * col)), ccp(row + (widthBlock * row) + widthBlock, col + (heightBlock * col) + heightBlock), yellow);
            } else if ([gameSpace[row][col] isDoor] && [gameSpace[row][col] getNumSteps] > 0) {
                ccDrawSolidRect(ccp(row + (widthBlock * row), col + (heightBlock * col)), ccp(row + (widthBlock * row) + widthBlock, col + (heightBlock * col) + heightBlock), brown);
            } else if ([gameSpace[row][col] getNumSteps] == 2) {
                ccDrawSolidRect(ccp(row + (widthBlock * row), col + (heightBlock * col)), ccp(row + (widthBlock * row) + widthBlock, col + (heightBlock * col) + heightBlock), blue);
            } else if ([gameSpace[row][col] getNumSteps] <= 0) {
                ccDrawSolidRect(ccp(row + (widthBlock * row), col + (heightBlock * col)), ccp(row + (widthBlock * row) + widthBlock, col + (heightBlock * col) + heightBlock), red);
            } else if ([gameSpace[row][col] getNumSteps] == 1) {
                ccDrawSolidRect(ccp(row + (widthBlock * row), col + (heightBlock * col)), ccp(row + (widthBlock * row) + widthBlock, col + (heightBlock * col) + heightBlock), green);
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
        if ([playerTile getNumSteps] == 0) { numTilesLeft--; }
        switch (dir) {
            case KKSwipeGestureDirectionDown:
                if (playerLocY > 0) {
                    playerLocY--;
                    nextTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
                    [playerTile setPlayer:false];
                    [nextTile setPlayer:true];
                    [playerTile decrementOne];
                }
                break;
            case KKSwipeGestureDirectionLeft:
                if (playerLocX > 0) {
                    playerLocX--;
                    nextTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
                    [playerTile setPlayer:false];
                    [nextTile setPlayer:true];
                    [playerTile decrementOne];
                }
                break;
            case KKSwipeGestureDirectionRight:
                if (playerLocX < maxX - 1) {
                    playerLocX++;
                    nextTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
                    [playerTile setPlayer:false];
                    [nextTile setPlayer:true];
                    [playerTile decrementOne];
                }
                break;
            case KKSwipeGestureDirectionUp:
                if (playerLocY < maxY - 1) {
                    playerLocY++;
                    nextTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
                    [playerTile setPlayer:false];
                    [nextTile setPlayer:true];
                    [playerTile decrementOne];
                }
                break;
        }
        playerTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
        if ([playerTile getNumSteps] <= 0) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Game Over!" message:@"You fell in lava :(" delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:nil];
            [alert show];
        } else {
            if ([playerTile isKey]) { hasKey = true; }
            if ([playerTile isCheckpoint]) {
                checkpointX = playerLocX;
                checkpointY = playerLocY;
                hasCheckpoint = true;
            }
            if ([playerTile isDoor]) {
                if (hasKey && numTilesLeft) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"You won!" message:@"Sweeeeet" delegate:self cancelButtonTitle:@"Replay" otherButtonTitles:@"Back to level select", nil];
                    [alert show];
                } else {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Door Locked!" message:@"Dudebro you need the key :3" delegate:self cancelButtonTitle:@"Hokay" otherButtonTitles:nil];
                    [alert show];
                }
            }
            [playerTile setPlayer:true];
        }
    }

}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self initLevel:levelFile];
    } else if (buttonIndex == 1) {
        [[CCDirector sharedDirector] replaceScene:[LevelSelectLayer scene]];
    }
}


-(void) nextFrame
{
    
}

-(void) updateGrid
{
    
}

@end
