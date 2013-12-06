//
//  StartMenuLayer.m
//  MazeGame
//
//  Created by JonKalfayan on 11/6/13.
//
//

#import "StartMenuLayer.h"
#import "LevelSelectLayer.h"

@implementation StartMenuLayer

-(id) init {
    if ((self = [super init])) {
        [self setUpMainMenu];
    }
    return self;
}

+(id) scene {
    CCScene* mainMenu = [CCScene node];
    StartMenuLayer* layer = [StartMenuLayer node];
    [mainMenu addChild: layer];
    return mainMenu;
}

-(void) setUpMainMenu {
    CCLabelTTF* titleLabel = [CCLabelTTF labelWithString:@"MazeRunner" fontName:@"Verdana" fontSize:32];
    titleLabel.position = ccp(160, 280);
    CCLabelTTF* playLabel = [CCLabelTTF labelWithString:@"Play Game" fontName:@"Verdana" fontSize:20];
    CCMenuItemLabel* play = [CCMenuItemLabel itemWithLabel:playLabel target:self selector:@selector(selectLevelMenu:)];
    
    CCMenu* mainMenu = [CCMenu menuWithItems: play, nil];
    [self addChild: titleLabel];
    [self addChild: mainMenu];
}

-(void) selectLevelMenu: (id) sender {
    [[CCDirector sharedDirector] replaceScene: [LevelSelectLayer scene]];
}

@end
