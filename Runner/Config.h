//
//  Config.h
//  Runner
//
//  Created by 于恩聪 on 15/6/23.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneList.h"
#import "PhoneCanMake.h"
#import "SosphoneList.h"
#import "Fence.h"
@interface Config : NSObject

+ (BOOL)setInteger:(NSInteger)value forKey:(NSString *)key;
+ (NSInteger)getIntegerForKey:(NSString *)key;
+ (BOOL)setBool:(BOOL)value forKey:(NSString *)key;
+ (BOOL)getBoolForKey:(NSString *)key;
+ (BOOL)setObject:(id)value forKey:(NSString *)key;
+ (id)getObjectForKey:(NSString *)key;
+ (void) removeObjectForKey :(NSString *)key;

+ (BOOL)saveFence:(Fence *)fence;
+ (Fence *)getFenceWithFenceName:(NSString *)name;
+ (void)removeFenceWithFenceName:(NSString *)name;

+ (BOOL)savePhonelist:(PhoneList *)phoneList;
+ (PhoneList *)getPhoneListByUserid:(NSString *)userid;

+ (BOOL)savePhoneCanMake:(PhoneCanMake *)phoneList;
+ (PhoneCanMake *)getPhoneCanMakeByUserID:(NSString *)userid;

+ (BOOL)saveSosphoneList:(SosphoneList *)phoneList;
+ (SosphoneList *)getSosphoneListByuserID:(NSString *)userid;
@end
