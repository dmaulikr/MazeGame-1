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
}

-(void) initLevel: (NSString*) levelFile;
-(void) draw;

@end
