//
//  Mymapview.h
//  爱之心
//
//  Created by 于恩聪 on 15/9/21.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapServices.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface Mymapview : UIView<AMapSearchDelegate,MAMapViewDelegate>

@property (strong,nonatomic) MAMapView *mapView;
@property (strong,nonatomic) AMapSearchAPI *_search;


+ (instancetype)sharedInstance;

@end
