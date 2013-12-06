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
    CCLabelTTF* titleLabel = [CCLabelTTF labelWithString:@"MazeRunner" fontName:@"Courier" fontSize:32];
    titleLabel.position = ccp(160, 260);
    CCLabelTTF* playLabel = [CCLabelTTF labelWithString:@"Play Game" fontName:@"Courier" fontSize:20];
    CCMenuItemLabel* play = [CCMenuItemLabel itemWithLabel:playLabel target:self selector:@selector(selectLevel:)];
    
    CCMenu* mainMenu = [CCMenu menuWithItems: play, nil];
    [self addChild: titleLabel];
    [self addChild: mainMenu];
}

-(void) selectLevel: (id) sender {
    //[[CCDirector sharedDirector] replaceScene: [LevelSelectLayer levelSelect]];
}

@end
