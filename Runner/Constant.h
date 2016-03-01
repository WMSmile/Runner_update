//
//  Constant.h
//  Runner
//
//  Created by 于恩聪 on 15/6/23.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APIKey @"f328f5a236476245ea06d0c86476cb64"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define DEFAULTCOLOR [UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1]

#define DEFAULT_BACKGOUNDCOLOR [UIColor colorWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1]

#define NAVIGATION_COLOR [UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1]

#define ICON_BACKGROUND [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1]

#define ICON_WIDTH 36
@interface Constant : NSObject

//电子围栏的模式选择
enum railChoices{
    POINTMODEL = 1,
    LINEMODE,
    POLYGONMODE
};

@end
