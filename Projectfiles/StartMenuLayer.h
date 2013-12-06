//
//  StartMenuLayer.h
//  MazeGame
//
//  Created by JonKalfayan on 11/6/13.
//
//

#import "CCLayer.h"

@interface StartMenuLayer : CCLayer
{
}

+(id) scene;
-(void) setUpMainMenu;
-(void) selectLevelMenu: (id) sender;

@end
