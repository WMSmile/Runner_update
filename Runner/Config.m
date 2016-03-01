//
//  Config.m
//  Runner
//
//  Created by 于恩聪 on 15/6/23.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "Config.h"

@implementation Config

+ (BOOL)setInteger:(NSInteger)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"runner"];
    [userDefaults setInteger:value forKey:key];
    return [userDefaults synchronize];
}

+ (NSInteger)getIntegerForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"runner"];
    return [userDefaults integerForKey:key];
}

+ (BOOL)setBool:(BOOL)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"runner"];
    [userDefaults setBool:value forKey:key];
    return [userDefaults synchronize];
}
+ (BOOL)getBoolForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"runner"];
    return [userDefaults boolForKey:key];
}
+ (BOOL)setObject:(id)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"runner"];
    [userDefaults setObject:value forKey:key];
    return [userDefaults synchronize];
}

+ (id)getObjectForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"runner"];
    return [userDefaults objectForKey:key];
}
+ (void) removeObjectForKey :(NSString *)key {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"runner"];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}

+ (BOOL)saveFence:(Fence *)fence{
    NSString *fenceName = fence.fence_name;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"runner"];
    [userDefaults setObject:fence.fence_name forKey:fenceName];
    [userDefaults setObject:fence.fence forKey:[NSString stringWithFormat:@"%@.fence",fenceName]];
    [userDefaults setObject:fence.fence_id forKey:[NSString stringWithFormat:@"%@.fence_id",fenceName]];
    [userDefaults setObject:fence.shouhuan_id forKey:[NSString stringWithFormat:@"%@.shouhuan_id",fenceName]];
    [userDefaults setObject:fence.time forKey:[NSString stringWithFormat:@"%@.time",fenceName]];
    [userDefaults setObject:fence.type forKey:[NSString stringWithFormat:@"%@.type",fenceName]];
    [userDefaults setObject:fence.user_id forKey:[NSString stringWithFormat:@"%@.user_id",fenceName]];

    return [userDefaults synchronize];
}
+ (Fence *)getFenceWithFenceName:(NSString *)name{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"runner"];

    Fence *fence = [[Fence alloc] init];
    fence.fence_name = name;
    fence.fence = [userDefaults objectForKey:[NSString stringWithFormat:@"%@.fence",name]];
    fence.fence_id = [userDefaults objectForKey:[NSString stringWithFormat:@"%@.fence_id",name]];
    fence.shouhuan_id = [userDefaults objectForKey:[NSString stringWithFormat:@"%@.shouhuan_id",name]];
    fence.time = [userDefaults objectForKey:[NSString stringWithFormat:@"%@.time",name]];
    fence.type = [userDefaults objectForKey:[NSString stringWithFormat:@"%@.type",name]];
    fence.user_id = [userDefaults objectForKey:[NSString stringWithFormat:@"%@.user_id",name]];
    
    return fence;
}

+ (void)removeFenceWithFenceName:(NSString *)name {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"runner"];
    
    [userDefaults removeObjectForKey:name];
    [userDefaults removeObjectForKey:[NSString stringWithFormat:@"%@.fence",name]];

    [userDefaults removeObjectForKey:[NSString stringWithFormat:@"%@.fence_id",name]];
    [userDefaults removeObjectForKey:[NSString stringWithFormat:@"%@.shouhuan_id",name]];
    [userDefaults removeObjectForKey:[NSString stringWithFormat:@"%@.time",name]];
    [userDefaults removeObjectForKey:[NSString stringWithFormat:@"%@.type",name]];
    [userDefaults removeObjectForKey:[NSString stringWithFormat:@"%@.user_id",name]];
    
    [userDefaults synchronize];
}

+ (BOOL)savePhonelist:(PhoneList *)phoneList{
    NSString *user_id = phoneList.userid;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"runner"];
    [userDefaults setObject:phoneList.nameArray forKey:[NSString stringWithFormat:@"%@.nameArray",user_id]];
    [userDefaults setObject:phoneList.phoneArray forKey:[NSString stringWithFormat:@"%@.phoneArray",user_id]];
    
    return [userDefaults synchronize];
}

+ (PhoneList *)getPhoneListByUserid:(NSString *)userid {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"runner"];

    PhoneList *phoneList = [[PhoneList alloc] init];
    phoneList.userid = userid;
    phoneList.nameArray = [userDefaults objectForKey:[NSString stringWithFormat:@"%@.nameArray",userid]];
    phoneList.phoneArray = [userDefaults objectForKey:[NSString stringWithFormat:@"%@.phoneArray",userid]];
    
    return phoneList;
}

+ (BOOL)savePhoneCanMake:(PhoneCanMake *)phoneList{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"runner"];
    NSString *userid = phoneList.userid;
    [userDefaults setObject:phoneList.phoneCanMake forKey:[NSString stringWithFormat:@"%@.phoneCanMakeList",userid]];
    return [userDefaults synchronize];
}

+ (PhoneCanMake *)getPhoneCanMakeByUserID:(NSString *)userid {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"runner"];
    PhoneCanMake *phoneList = [PhoneCanMake new];
    phoneList.userid = userid;
    phoneList.phoneCanMake = [userDefaults objectForKey:[NSString stringWithFormat:@"%@.phoneCanMakeList",userid]];
    
    return phoneList;
}

+ (BOOL)saveSosphoneList:(SosphoneList *)phoneList {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"runner"];

    NSString *user_id = phoneList.userid;
    [userDefaults setObject:phoneList.phoneList forKey:[NSString stringWithFormat:@"%@.sosphoneList",user_id]];
    
    return [userDefaults synchronize];
    
}

+ (SosphoneList *)getSosphoneListByuserID:(NSString *)userid{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"runner"];
    
    SosphoneList *phoneList = [SosphoneList new];
    phoneList.userid = userid;
    phoneList.phoneList = [userDefaults objectForKey:[NSString stringWithFormat:@"%@.sosphoneList",userid]];
    
    return phoneList;

}
@end
