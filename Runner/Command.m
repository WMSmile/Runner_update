

//
//  Command.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/19.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "Command.h"
#import "Networking.h"

@implementation Command

+ (void)commandWithName:(NSString *)command andParameter:(NSString *)parameter{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    NSString *channel_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
    
    if (!user_id || !channel_id) {
        return;
    }
    
    NSLog(@"user_id :%@ channel_id : %@",user_id,channel_id);
    
    NSDictionary *parameters = @{
                                 @"cmd":command,
                                 @"shouhuan_id":channel_id,
                                 @"user_id":user_id,
                                 @"parameter":parameter
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/command";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"操作失败");
    }];
    
}


@end
