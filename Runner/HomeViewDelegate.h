//
//  HomeViewDelegate.h
//  爱之心
//
//  Created by 于恩聪 on 15/9/1.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeViewDelegate <NSObject>

-(void) passLatitude:(NSString *)latitude andLongitude:(NSString *)longitude;

@end

@interface HomeViewDelegate : UIViewController
{
    id<HomeViewDelegate> delegate;
}
@property (assign,nonatomic) HomeViewDelegate *delegate;

@end