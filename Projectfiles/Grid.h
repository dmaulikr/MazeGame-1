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

-(id) initWidth:(int)w initHeight:(int)h;

@end
