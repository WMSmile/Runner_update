//
//  HistoryViewController.h
//  Runner
//
//  Created by 于恩聪 on 15/6/27.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapServices.h>
#import <MAMapKit/MAMapKit.h>
#import "Config.h"
#import "Constant.h"
#import "Mymapview.h"

@interface HistoryViewController : UIViewController<MAMapViewDelegate>
{
    MAMapPoint points[100];
}
@property (nonatomic,strong) UIButton *resetButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UIAlertView *deleteAlertView;
@property (nonatomic,strong) UIAlertView *resetAlertView;
@property (nonatomic,strong) NSMutableArray *fencenameList;
@property (nonatomic,strong) NSMutableArray *dangerFencenames;

@property MAMapView *mapView;
@property (nonatomic,strong) UIButton *zoominButton;
@property (nonatomic,strong) UIButton *zoomoutButton;

@property (nonatomic,strong) NSString *fenceName;

@property (nonatomic,strong) Mymapview *myMapview;
@end
