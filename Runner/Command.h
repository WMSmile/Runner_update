//
//  Command.h
//  爱之心
//
//  Created by 于恩聪 on 15/9/19.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Command : NSObject

+ (void)commandWithName:(NSString *)command andParameter:(NSString *)parameter;

@end
