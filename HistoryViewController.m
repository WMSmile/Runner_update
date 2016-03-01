//
//  HistoryViewController.m
//  Runner
//
//  Created by 于恩聪 on 15/6/27.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "HistoryViewController.h"
#import "Config.h"
#import "Fence.h"
#import "Networking.h"
#import "NewFenceView.h"

@interface HistoryViewController()
{
    double pointX;
    double pointY;
    double radius;
    
    CLLocationCoordinate2D touchPoints[10];
    
    Fence *fence;
    NSString *startTime;
    NSString *endTime;
    
    UILabel *timeLabel;
    UILabel *typeLabel;
    
    NSString *shouhuan_id;
    NSString *user_id;
}

@end

@implementation HistoryViewController
@synthesize mapView,resetButton,deleteButton;
@synthesize deleteAlertView,resetAlertView;
@synthesize fencenameList,dangerFencenames;
@synthesize zoomoutButton,zoominButton;
@synthesize fenceName;
@synthesize myMapview;
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initData];
    [self initMapView];
    [self getAndDrawFence];

    [self initButton];
    [self initLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];
}

- (void)initData{
    user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
}
- (void)getAndDrawFence {
    fence = [Config getFenceWithFenceName:fenceName];
    
    if (fence.fence.length > 60) {
        
        NSScanner *scanner = [NSScanner scannerWithString:fence.fence];
        
        int pointCount = 0;
        do{
            [scanner scanDouble:&pointX];
            
            if (scanner.scanLocation < fence.fence.length) {
                scanner.scanLocation ++;
            }
            
            if (![scanner isAtEnd]) {
                [scanner scanDouble:&pointY];
                scanner.scanLocation ++;
            }
            if (pointY && pointX) {
                CLLocationCoordinate2D location= CLLocationCoordinate2DMake(pointY, pointX);
                touchPoints[pointCount] = location;
                points[pointCount] = MAMapPointMake(pointY, pointX);
                pointCount ++;
                
                MAPointAnnotation *tempAnimation = [MAPointAnnotation new];
                tempAnimation.coordinate = location;
                [mapView addAnnotation:tempAnimation];
            }
        }while (![scanner isAtEnd]);
        
        MAPolygon *polygon =[MAPolygon polygonWithCoordinates:touchPoints count:pointCount];
        [mapView setCenterCoordinate:touchPoints[0]];
        [mapView addOverlay:polygon];
    }
    if (fence.fence.length < 60) {
    
        NSScanner *scanner = [NSScanner scannerWithString:fence.fence];
        
        [scanner scanDouble:&pointX];
        
        scanner.scanLocation ++;
            
        [scanner scanDouble:&pointY];
        
        scanner.scanLocation ++;
        
        [scanner scanDouble:&radius];
        
        CLLocationCoordinate2D location= CLLocationCoordinate2DMake(pointY, pointX);
        
        MAPointAnnotation *touchAnnotation = [MAPointAnnotation new];
        touchAnnotation.coordinate = location;
        
        MACircle *pointCircle = [MACircle circleWithCenterCoordinate:location radius:radius];
        [mapView addOverlay:pointCircle];
        
        [mapView addAnnotation:touchAnnotation];
        [mapView setCenterCoordinate:location];
    }
}

- (void)initMapView{
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    myMapview = [Mymapview sharedInstance];
    [myMapview setFrame:CGRectMake(10, 70,SCREEN_WIDTH - 20,SCREEN_HEIGHT - 160)];
    
    mapView = myMapview.mapView;
    mapView.delegate = self;
    
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];
    
    [self.view addSubview:myMapview];
    
    [self.view sendSubviewToBack:myMapview];

}

- (void) initButton {
    
    zoominButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 45, SCREEN_HEIGHT - 125, 35, 35)];
    [zoominButton setBackgroundColor:[UIColor clearColor]];
    [zoominButton setBackgroundImage:[UIImage imageNamed:@"zoomin"] forState:UIControlStateNormal];
    [zoominButton setBackgroundImage:[UIImage imageNamed:@"zoominPress"] forState:UIControlStateHighlighted];
    [zoominButton addTarget:self action:@selector(zoomIn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zoominButton];
    
    zoomoutButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 45, SCREEN_HEIGHT - 160, 35, 35)];
    [zoomoutButton setBackgroundColor:[UIColor clearColor]];
    [zoomoutButton setBackgroundImage:[UIImage imageNamed:@"zoomout"] forState:UIControlStateNormal];
    [zoomoutButton setBackgroundImage:[UIImage imageNamed:@"zoomoutPress"] forState:UIControlStateHighlighted];
    [zoomoutButton addTarget:self action:@selector(zoomOut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zoomoutButton];
    
    resetButton = [UIButton new];
    [resetButton setFrame:CGRectMake(10, SCREEN_HEIGHT-83, SCREEN_WIDTH - 20, 35)];
    [resetButton setTitle:@"重新规划区域" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [resetButton setBackgroundColor:[UIColor whiteColor]];
    [resetButton.layer setBorderWidth:0.2];
    [resetButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [resetButton.layer setCornerRadius:5.0];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:resetButton];
    
    deleteButton = [UIButton new];
    [deleteButton setFrame:CGRectMake(10, SCREEN_HEIGHT-43, SCREEN_WIDTH-20, 35)];
    [deleteButton setTitle:@"删除电子围栏" forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [deleteButton setBackgroundColor:[UIColor whiteColor]];
    [deleteButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [deleteButton.layer setBorderWidth:0.2];
    [deleteButton.layer setCornerRadius:5.0];
    [self.view addSubview:deleteButton];
    
    [resetButton addTarget:self action:@selector(resetArea ) forControlEvents:UIControlEventTouchUpInside];
    
    [deleteButton addTarget:self action:@selector(deleteArea) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)initLabel{
    CGFloat basicY = 83;
    
    CGFloat basicMove = 20;
    
    NSLog(@"time : %@",fence.time);
    
    timeLabel = [self labelWithTitle:[NSString stringWithFormat:@"监护时间:%@",fence.time] andY:basicY];
    
    NSMutableArray *alarmArray = [NSMutableArray arrayWithObjects:@"进入警报",@"离开警报",@"进出警报", nil];
    
    NSString *tempStr = [alarmArray objectAtIndex:[fence.type intValue] - 1];
    
    typeLabel = [self labelWithTitle:[NSString stringWithFormat:@"警告类型:%@",tempStr] andY:basicY + basicMove];
}

- (UILabel *)labelWithTitle:(NSString *)labeltext andY:(CGFloat)y{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, y, SCREEN_WIDTH - 20, 20)];
    [label setText:labeltext];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setTextColor:DEFAULTCOLOR];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:12]];
    
    [self.view addSubview:label];
    
    return label;
}
- (void)zoomIn {
    mapView.zoomLevel = mapView.zoomLevel * 0.8;
}
- (void)zoomOut {
    mapView.zoomLevel = mapView.zoomLevel * 1.2;
}
- (void)resetArea {
    NewFenceView *newFenceView = [NewFenceView new];
    newFenceView.fence = fence;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newFenceView animated:YES];
}
- (void)deleteArea {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    NSDictionary *parameters = @{
                                 @"fence_id":fence.fence_id,
                                 @"user_id":fence.user_id,
                                 @"shouhuan_id":shouhuan_id
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/fence";
    
    [manager DELETE:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation : %@",operation);
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"success");
            [self.navigationController popViewControllerAnimated:YES];
        }
        if ([code isEqualToString:@"200"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"200" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        if ([code isEqualToString:@"500"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"500" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        NSLog(@"操作失败");
    }];
}

//画annotation的回调函数
- (MAAnnotationView *)mapView:(MAMapView *)_mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.pinColor = MAPinAnnotationColorGreen;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = NO;
        
        annotationView.image = [UIImage imageNamed:@"animationView"];
        
        [annotationView setFrame:CGRectMake(0, 0, 10, 10)];
        [annotationView setClipsToBounds:YES];
        
        return annotationView;
    }
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        static NSString *userLocationStyleReuseIndentifier = @"userLocationStyleReuseIndentifier";
        MAAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:userLocationStyleReuseIndentifier];
        }
        return annotationView;
    }
    return nil;
}

//画多边形的回调函数
- (MAOverlayView *)mapView:(MAMapView *)_mapView viewForOverlay:(id <MAOverlay>)overlay
{
    //自定义精度圈
    if (overlay == _mapView.userLocationAccuracyCircle) {
        MACircleView *accuracyCircleView = [[MACircleView alloc]initWithCircle:overlay];
        accuracyCircleView.lineWidth = 2.f;
        accuracyCircleView.strokeColor = [UIColor lightGrayColor];
        accuracyCircleView.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0];
        return accuracyCircleView;
    }
    //画圆的回调函数
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleView *circleView = [[MACircleView alloc] initWithCircle:overlay];
        
        circleView.lineWidth = 5.f;
        circleView.strokeColor = DEFAULTCOLOR;
        circleView.fillColor = [UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:0.5];
        circleView.lineJoinType = kMALineJoinRound;
        circleView.lineDash = YES;
        
        return circleView;
    }
    //画折线的回调函数
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth = 5.f;
        polylineView.strokeColor = DEFAULTCOLOR;
        polylineView.lineJoinType = kMALineJoinRound;//连接类型
        polylineView.lineCapType = kMALineCapRound;//端点类型
        
        return polylineView;
    }
    //多边形的回调函数
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygonView *_polygonView = [[MAPolygonView alloc] initWithPolygon:overlay];
        
        _polygonView.lineWidth = 2.f;
        _polygonView.strokeColor = DEFAULTCOLOR;
        _polygonView.fillColor = [UIColor whiteColor];
        _polygonView.lineJoinType = kMALineJoinMiter;//连接类型
        
        return _polygonView;
    }
    
    
    return nil;
}
//alert 的回调函数
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == deleteAlertView) {
        if (buttonIndex == 1) {
            NSLog(@"取消删除");
        }
        if (buttonIndex == 0) {
            NSLog(@"确定删除");
        }
        deleteButton.backgroundColor = [UIColor whiteColor];
        [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    if (alertView == resetAlertView) {
        if (buttonIndex == 0) {
            NSLog(@"reset");
        }
        if (buttonIndex == 1) {
            NSLog(@"cancel reset");
        }
        resetButton.backgroundColor = [UIColor whiteColor];
        [resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

@end
