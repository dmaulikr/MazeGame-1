//
//  LevelSelectLayer.h
//  MazeGame
//
//  Created by Jerry Jei-Rui Bao on 12/5/13.
//
//

#import "CCLayer.h"

@interface LevelSelectLayer : CCLayer
{
}

+(id) scene;
-(void) setUpLevelSelect;
-(void) selectLevel: (id) sender;

@end
