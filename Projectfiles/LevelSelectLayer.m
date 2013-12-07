//
//  LevelSelectLayer.m
//  MazeGame
//
//  Created by Jerry Jei-Rui Bao on 12/5/13.
//
//

#import "LevelSelectLayer.h"
#import "Grid.h"

@implementation LevelSelectLayer

-(id) init {
    if ((self = [super init])) {
        [self setUpLevelSelect];
    }
    return self;
}

+(id) scene {
    CCScene* levelSelect = [CCScene node];
    LevelSelectLayer* layer = [LevelSelectLayer node];
    [levelSelect addChild: layer];
    return levelSelect;
}

-(void) setUpLevelSelect {
    NSDictionary* levelsCompleted = [NSDictionary dictionaryWithContentsOfFile:@"levelsCompleted.plist"];
    
    CCLabelTTF* selectALevelLabel = [CCLabelTTF labelWithString:@"Select A Level" fontName:@"Verdana" fontSize:32];
    selectALevelLabel.position = ccp(160, 380);
    CCLabelTTF* level1 = [CCLabelTTF labelWithString:@"Level 1" fontName:@"Verdana" fontSize:20];
    CCMenuItemLabel* level1label = [CCMenuItemLabel itemWithLabel:level1 target:self selector:@selector(selectLevel:)];
    level1label.tag = 1;
    if ([levelsCompleted objectForKey:@"level1"]) { }
    CCLabelTTF* level2 = [CCLabelTTF labelWithString:@"Level 2" fontName:@"Verdana" fontSize:20];
    CCMenuItemLabel* level2label = [CCMenuItemLabel itemWithLabel:level2 target:self selector:@selector(selectLevel:)];
    level2label.tag = 2;
    CCLabelTTF* level3 = [CCLabelTTF labelWithString:@"Level 3" fontName:@"Verdana" fontSize:20];
    CCMenuItemLabel* level3label = [CCMenuItemLabel itemWithLabel:level3 target:self selector:@selector(selectLevel:)];
    level3label.tag = 3;
    CCLabelTTF* level4 = [CCLabelTTF labelWithString:@"Level 4" fontName:@"Verdana" fontSize:20];
    CCMenuItemLabel* level4label = [CCMenuItemLabel itemWithLabel:level4 target:self selector:@selector(selectLevel:)];
    level4label.tag = 4;

    CCMenu* levels = [CCMenu menuWithItems: level1label, level2label, level3label, level4label, nil];
    [levels alignItemsVertically];
    [self addChild: selectALevelLabel];
    [self addChild: levels];
}

-(void) selectLevel: (CCMenu*) level {
    int levelSelect = level.tag;
    NSString* levelName;
    switch (levelSelect) {
        case 1:
            levelName = @"level1.plist";
            break;
        case 2:
            levelName = @"level2.plist";
            break;
        case 3:
            levelName = @"level3.plist";
            break;
        case 4:
            levelName = @"level4.plist";
            break;
    }
    
    [[CCDirector sharedDirector] replaceScene: [Grid scene:levelName]];
}

@end
