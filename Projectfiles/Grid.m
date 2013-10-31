//
//  Grid.m
//  MazeGame
//
//  Created by Jerry Jei-Rui Bao on 10/30/13.
//
//

#import "Grid.h"
#import "Tile.h"

@implementation Grid

-(id) initWidth:(int)w initHeight:(int)h {
    if ((self = [super init])) {
        gameSpace = [[NSMutableArray alloc] init];
        for (int width = 0; width < initWidth; width++) {
            NSMutableArray* subArr = [[NSMutableArray alloc] init];
            for (int height = 0; height < initHeight; height++) {
                [subArr addObject: [[Tile alloc] initDoor:false initKey:false initCheckpoint:false initNumOfSteps:0]];
            }
            [gameSpace addObject: subArr];
        }
    }
}

@end
