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
NSString *levelFile;

int currMinute;
int currSecond;
int currHour;
int mins;
bool running;
NSTimeInterval startTime;
NSTimeInterval stoppedTime;
NSDate *startDate;
NSTimeInterval secondsAlreadyRun;

@implementation Grid

@synthesize stopWatchLabel;

#define HEIGHT_TILE 80
#define WIDTH_WINDOW 320
#define HEIGHT_WINDOW 480
#define DELAY_IN_SECONDS 0.4
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
        runner.position = ccp(8, 8);
        runner.scale = 0.4;
        key = [CCSprite spriteWithFile:@"key.gif"];
        key.position = ccp(20, 20);
        key.scale = 0.75;
        CCMenuItemImage* back = [CCMenuItemImage itemWithNormalImage:@"back.png" selectedImage:@"back.png" target:self selector:@selector(navBarSelection:)];
        back.tag = 1;
        CCMenuItemImage* retry = [CCMenuItemImage itemWithNormalImage:@"retry.png" selectedImage:@"retry.png" target:self selector:@selector(navBarSelection:)];
        retry.tag = 2;
        CCMenu* navBar = [CCMenu menuWithItems:back, retry, nil];
        [navBar alignItemsHorizontally];
        navBar.scale = 2.3;
        navBar.position = ccp(265, 905);
        [self addChild:runner];
        [self addChild:key];
        [self addChild:navBar];
        [self initLevel:levelFile];
        
        [self scheduleUpdate];
    }
    return self;
}

+(id) scene: (NSString*) level {
    CCScene* gameScene = [CCScene node];
    Grid* layer = [Grid node];
    [layer initLevel:level];
    layer->levelFile = level;
    [gameScene addChild: layer];
    return gameScene;
}
//- (void)updateTime {
//    
//    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
//    NSTimeInterval elapsed = currentTime - startTime;
//    
//    
//    int mins = (int) (elapsed / 60.0);
//    elapsed -= mins * 60;
//    int secs = (int) (elapsed);
//    elapsed -= secs;
//    int fraction = elapsed * 10.0;
//    
//    [self removeChild:stopWatchLabel];
//    [stopWatchLabel setString:[NSString
//                            stringWithFormat:@"%u:%u.%u", mins, secs, fraction]];
//    [self addChild:stopWatchLabel];
//    [self performSelector:@selector(updateTime) withObject:self afterDelay:0.1];
//}

-(void) navBarSelection: (CCMenuItem*) navBarItem {
    int navBarParam = navBarItem.tag;
    switch (navBarParam) {
        case 1:
            [[CCDirector sharedDirector] replaceScene:[LevelSelectLayer scene]];
            break;
        case 2:
            [self initLevel:levelFile];
            break;
    }
}

-(void) initLevel: (NSString*) levelFile {
    
//    stopWatchLabel =  [[CCLabelTTF alloc] init];
//    stopWatchLabel.fontSize = 20;
//    stopWatchLabel.position = ccp(360, 480);
    running = false;
    key.visible = false;
    hasKey = false;
    numTilesLeft = 0;
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
    
    startDate = [[NSDate alloc] init];
    startTime = [NSDate timeIntervalSinceReferenceDate];
//    [self updateTime];

}

-(void) draw
{
    int widthBlock = WIDTH_WINDOW / maxX;
    int heightBlock = HEIGHT_WINDOW / maxY;
    
    for (int row = 0; row < maxX; row += 1) {
        for (int col = 0; col < maxY; col += 1) {
            if ([gameSpace[row][col] hasPlayer] && [gameSpace[row][col] getNumSteps] > 0) {
                runner.position = ccp(row + (widthBlock * row) + (widthBlock / 2), col + (heightBlock * col) + (heightBlock / 2));
                key.position = ccp(row + (widthBlock * row) + (widthBlock - (widthBlock / 6)), col + (heightBlock * col) + (heightBlock / 2));
   
                if (hasKey) {
                    key.visible = true;
                }
            }
            if ([gameSpace[row][col] isKey] && [gameSpace[row][col] getNumSteps] > 0) {
                UIImage* image = [UIImage imageNamed:@"keyindirt.gif"];
                CGImageRef imageRef = image.CGImage;
                CCTexture2D *block = [[CCTexture2D alloc] init];
                [block initWithCGImage:imageRef resolutionType:kCCResolutioniPhone5RetinaDisplay];
                [block drawInRect:CGRectMake(row + (widthBlock * row), col + (heightBlock * col), widthBlock, heightBlock)];
            } else if ([gameSpace[row][col] isDoor] && [gameSpace[row][col] getNumSteps] > 0) {
                UIImage* image = [UIImage imageNamed:@"door.png"];
                CGImageRef imageRef = image.CGImage;
                CCTexture2D *block = [[CCTexture2D alloc] init];
                [block initWithCGImage:imageRef resolutionType:kCCResolutioniPhone5RetinaDisplay];
                [block drawInRect:CGRectMake(row + (widthBlock * row), col + (heightBlock * col), widthBlock, heightBlock)];
            } else if ([gameSpace[row][col] getNumSteps] == 2) {
                UIImage* image = [UIImage imageNamed:@"stone2.png"];
                CGImageRef imageRef = image.CGImage;
                CCTexture2D *block = [[CCTexture2D alloc] init];
                [block initWithCGImage:imageRef resolutionType:kCCResolutioniPhone5RetinaDisplay];
                [block drawInRect:CGRectMake(row + (widthBlock * row), col + (heightBlock * col), widthBlock, heightBlock)];
            } else if ([gameSpace[row][col] getNumSteps] == 3) {
                UIImage* image = [UIImage imageNamed:@"sturdystone.png"];
                CGImageRef imageRef = image.CGImage;
                CCTexture2D *block = [[CCTexture2D alloc] init];
                [block initWithCGImage:imageRef resolutionType:kCCResolutioniPhone5RetinaDisplay];
                [block drawInRect:CGRectMake(row + (widthBlock * row), col + (heightBlock * col), widthBlock, heightBlock)];
            } else if ([gameSpace[row][col] getNumSteps] <= 0) {
            } else if ([gameSpace[row][col] getNumSteps] == 1) {
                UIImage* image = [UIImage imageNamed:@"dirt2.png"];
                CGImageRef imageRef = image.CGImage;
                CCTexture2D *block = [[CCTexture2D alloc] init];
                [block initWithCGImage:imageRef resolutionType:kCCResolutioniPhone5RetinaDisplay];
                [block drawInRect:CGRectMake(row + (widthBlock * row), col + (heightBlock * col), widthBlock, heightBlock)];
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
        if ([playerTile getNumSteps] == 0) { numTilesLeft--; }
        playerTile = [[gameSpace objectAtIndex:playerLocX] objectAtIndex:playerLocY];
        if ([playerTile getNumSteps] <= 0) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Game Over!" message:@"You fell to your doom :(" delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:nil];
            [alert show];
        } else {
            if ([playerTile isKey]) { hasKey = true; }
            if ([playerTile isCheckpoint]) {
                checkpointX = playerLocX;
                checkpointY = playerLocY;
                hasCheckpoint = true;
            }
            if ([playerTile isDoor]) {
                if (hasKey && numTilesLeft == 1) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"You won!" message:@"Sweeeeet" delegate:self cancelButtonTitle:@"Replay" otherButtonTitles:@"Back to level select", nil];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:levelFile];
                    [alert show];
                } else if (hasKey && numTilesLeft > 1) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Door Locked!" message:@"You need to break all the tiles" delegate:self cancelButtonTitle:@"Hokay" otherButtonTitles:nil];
                    [alert show];
                } else {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Door Locked!" message:@"You need the key!" delegate:self cancelButtonTitle:@"Hokay" otherButtonTitles:nil];
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
