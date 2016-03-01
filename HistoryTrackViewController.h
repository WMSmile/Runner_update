//
//  HistoryTrackViewController.h
//  Runner
//
//  Created by 于恩聪 on 15/7/6.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapServices.h>
#import <MAMapKit/MAMapKit.h>
#import "Config.h"
#import "Constant.h"
@interface HistoryTrackViewController : UIViewController<MAMapViewDelegate>
{
    MAMapPoint points[100];
    int i;
    NSTimer *myTimer;
}
@property (nonatomic,strong) NSString *fenceChoice;
@property (nonatomic,strong) UIButton *dateButton;
@property MAMapView *mapView;
@end
