//
//  NewFenceViewController.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/8.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//
#import <MAMapServices.h>
#import <MAMapKit/MAMapKit.h>
#import "NewFenceView.h"
#import "Networking.h"
#import "Config.h"
#import "Constant.h"
#import "Fence.h"
#import "Mymapview.h"
#import "NewFenceMessage.h"

@interface NewFenceView()<MAMapViewDelegate,MAAnnotation,UIAlertViewDelegate,ASValueTrackingSliderDataSource>

{
    MAMapView *mapView;
    Mymapview *myMapview;
    
    UIButton *pointButton;
    UIButton *polygonButton;
    UIButton *backButton;
    UIButton *makeSureButton;
    UIButton *zoominButton;
    UIButton *zoomoutButton;

    BOOL _drawCircle;
    
    BOOL _drawPolygon;
    BOOL _resetArea;
    
    CLLocationCoordinate2D touchCoordinate;
    MAPointAnnotation *touchAnnotation;
    CLLocationCoordinate2D touchPoints[10];
    MAPointAnnotation *polygonAnnotation[10];
    MAMapPoint points[10];
    MAPolygon *polygonView;
    MACircle *pointCircle;
    int tapcount;//多边形 计数
    
    NSMutableArray *fenceNameListArray;
    //slider
    NSArray *_sliders;
    
    //围栏信息
    NSString *circleRadius;
    CGFloat _radius;
    //
    NSString *user_id;
    NSString *shouhuan_id;
}
@end

@implementation NewFenceView
@synthesize coordinate;
@synthesize slider;
@synthesize fence;
@synthesize fencesArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    if (self.fence) {
        _resetArea = YES;
    }
    [self initData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)initData{
    user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
}
- (void)initUI {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initMapView];
    [self initButton];
    [self initSlider];
}
- (void)initSlider {
    self.slider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 110, SCREEN_WIDTH / 2 - 12, 20)];
    self.slider.dataSource = self;
    self.slider.maximumValue = 1000.0;
    self.slider.popUpViewCornerRadius = 0.0;
    [self.slider setMaxFractionDigitsDisplayed:0];
    self.slider.popUpViewColor = DEFAULTCOLOR;
    self.slider.textColor = [UIColor whiteColor];
    self.slider.popUpViewWidthPaddingFactor = 1.7;
    [self.view addSubview:self.slider];
    [slider setHidden:YES];
    
    _sliders = @[slider];

    }
- (void)initMapView {
    myMapview = [Mymapview sharedInstance];
    [myMapview setFrame:CGRectMake(10, 102, SCREEN_WIDTH - 20, SCREEN_HEIGHT - 150)];
    
    mapView = myMapview.mapView;
    mapView.delegate = self;
    
    [mapView removeAnnotations:mapView.annotations];
    [mapView removeOverlays:mapView.overlays];
    
    [self.view addSubview:myMapview];
    [self.view sendSubviewToBack:myMapview];
}

- (void)initButton {
    pointButton = [UIButton new];
    [pointButton setFrame:CGRectMake(10,69, SCREEN_WIDTH/2-10, 30)];//44+20+x
    [pointButton setTitle:@"圆形围栏" forState:UIControlStateNormal];
    [pointButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pointButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    pointButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [pointButton setBackgroundImage:[UIImage imageNamed:@"leftBtn.png"] forState:UIControlStateNormal];
    [pointButton setBackgroundImage:[UIImage imageNamed:@"leftBtnSelected.png"] forState:UIControlStateSelected];
    [self.view addSubview:pointButton];
    
    polygonButton = [UIButton new];
    [polygonButton setFrame:CGRectMake(SCREEN_WIDTH/2, 69, SCREEN_WIDTH/2-10, 30)];
    [polygonButton setTitle:@"多边形围栏" forState:UIControlStateNormal];
    [polygonButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [polygonButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    polygonButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [polygonButton setBackgroundImage:[UIImage imageNamed:@"rightBtn.png"] forState:UIControlStateNormal];
    [self.view addSubview:polygonButton];
    [polygonButton setBackgroundImage:[UIImage imageNamed:@"rightBtnSelected.png"] forState:UIControlStateSelected];
    
    [polygonButton addTarget:self action:@selector(clickPloygonButton) forControlEvents:UIControlEventTouchUpInside];
    [pointButton addTarget:self action:@selector(clickPointButton) forControlEvents:UIControlEventTouchUpInside];
    //返回
    backButton = [UIButton new];
    [backButton setFrame:CGRectMake(12,polygonButton.frame.size.height + polygonButton.frame.origin.y + 5,40,40)];
    
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton.layer setMasksToBounds:YES];
    [backButton setBackgroundImage:[UIImage imageNamed:@"reset.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"reset_press.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:backButton];
    [backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    //确定
    makeSureButton = [UIButton new];
    [makeSureButton setFrame:CGRectMake(10, SCREEN_HEIGHT-40, SCREEN_WIDTH - 20, 35)];
    [makeSureButton setTitle:@"划定该区域" forState:UIControlStateNormal];
    [makeSureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [makeSureButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [makeSureButton setBackgroundColor:[UIColor whiteColor]];
    [makeSureButton.layer setBorderWidth:0.2];
    [makeSureButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [makeSureButton.layer setCornerRadius:5.0];
    makeSureButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [makeSureButton addTarget:self action:@selector(clickSureButton) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:makeSureButton];
    
    zoominButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 41, SCREEN_HEIGHT - 125, 35, 35)];
    [zoominButton setBackgroundColor:[UIColor clearColor]];
    [zoominButton setBackgroundImage:[UIImage imageNamed:@"zoomin"] forState:UIControlStateNormal];
    [zoominButton setBackgroundImage:[UIImage imageNamed:@"zoominPress"] forState:UIControlStateHighlighted];
    [zoominButton addTarget:self action:@selector(zoomIn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:zoominButton];
    
    zoomoutButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 41, SCREEN_HEIGHT - 160, 35, 35)];
    [zoomoutButton setBackgroundColor:[UIColor clearColor]];
    [zoomoutButton setBackgroundImage:[UIImage imageNamed:@"zoomout"] forState:UIControlStateNormal];
    [zoomoutButton setBackgroundImage:[UIImage imageNamed:@"zoomoutPress"] forState:UIControlStateHighlighted];
    [zoomoutButton addTarget:self action:@selector(zoomOut) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:zoomoutButton];
    
    
}

- (NSString *)slider:(ASValueTrackingSlider *)slider stringForValue:(float)value;
{
    value = roundf(value);
    circleRadius = [NSString stringWithFormat:@"%f",value];
    NSString *s;
    NSLog(@"%f",value);
    
    if (pointCircle) {
        [mapView removeOverlay:pointCircle];
    }
    pointCircle = [MACircle circleWithCenterCoordinate:touchCoordinate radius:value];
    [mapView addOverlay:pointCircle];
    _radius = value;
    
    return s;
}

#pragma mark - IBActions

- (IBAction)toggleShowHide:(UIButton *)sender
{
    sender.selected = !sender.selected;
    for (ASValueTrackingSlider *_slider in _sliders) {
        sender.selected ? [_slider showPopUpViewAnimated:YES] : [_slider hidePopUpViewAnimated:YES];
    }
}


- (void)animateSlider:(ASValueTrackingSlider*)_slider toValue:(float)value
{
    [_slider setValue:value animated:YES];
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
        annotationView.canShowCallout = YES;//信息封装在maplocation
        annotationView.animatesDrop = YES;//动画显示
        
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
//按钮点击事件
- (void)clickPointButton{
    [self.slider setHidden:NO];
    while (tapcount > 0) {
        [self clickBackButton];
    }
    NSLog(@"clickPointButton");
    [pointButton setSelected:YES];
    [polygonButton setSelected:NO];
    
    _drawCircle = YES;
    _drawPolygon = NO;
    
}
- (void)clickPloygonButton {
    [self.slider setHidden:YES];
    if (touchAnnotation) {
        [mapView removeAnnotation:touchAnnotation];
    }
    if (pointCircle) {
        [mapView removeOverlay:pointCircle];
    }
    
    [polygonButton setSelected:YES];
    [pointButton setSelected:NO];
    
    _drawPolygon = YES;
    _drawCircle = NO;
    
    tapcount = 0;
}
- (void)clickSureButton {
    if(_drawPolygon) {
        NSLog(@"tapcount:%d",tapcount);
        if (tapcount <= 2) {
            [self showAlertViewWithTitle:@"完善围栏"];
            return;
        }
    }
    if(_drawCircle) {
        if (!touchAnnotation) {
            [self showAlertViewWithTitle:@"完善围栏"];
            return;
        }
    }
    if (!_drawCircle && !_drawPolygon) {
        [self showAlertViewWithTitle:@"完善围栏"];
        return;
    }

    if (!_resetArea) {
        fence = [Fence new];

    }
    fence.shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
    fence.user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];

    
    if (_drawCircle) {
        NSLog(@"alertDrawCircle");
        
        NSString *fenceData = [NSString new];
        fenceData = [NSString stringWithFormat:@"%f,%f@%f",touchAnnotation.coordinate.longitude,touchAnnotation.coordinate.latitude,_radius];
        fence.fence = fenceData;
    }
    if (_drawPolygon) {
        
        NSString *fenceData = [NSString new];
        for (int i = 0; i < tapcount; i++) {
            double pointX =  touchPoints[i].latitude;
            double pointY = touchPoints[i].longitude;
            
            NSLog(@"pointX:%f pointY:%f",pointX,pointY);
            
            NSString *tempStr = [NSString stringWithFormat:@"%f,%f#",pointY,pointX];
            fenceData = [NSString stringWithFormat:@"%@%@",fenceData,tempStr];
        }
        fence.fence = fenceData;
    }
    if (_resetArea) {
        [self deleteArea];
        
        return;
    }
    
    NewFenceMessage *fenceMessage = [NewFenceMessage new];
    
    fenceMessage.hidesBottomBarWhenPushed = YES;
    
    fenceMessage.fencesArray = self.fencesArray;
    
    fenceMessage.fence = fence;
    
    [self.navigationController pushViewController:fenceMessage animated:YES];
}

- (void)zoomIn {
    mapView.zoomLevel = mapView.zoomLevel * 0.8;
}
- (void)zoomOut {
    mapView.zoomLevel = mapView.zoomLevel * 1.2;
}
- (void)resetArea{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    NSLog(@"%@ %@ %@ %@ %@ %@",fence.fence,fence.fence_name,fence.shouhuan_id,fence.time,fence.type,fence.user_id);
    
    NSDictionary *parameters = @{
                                 @"fence":fence.fence,
                                 @"fence_name":fence.fence_name,
                                 @"shouhuan_id":fence.shouhuan_id,
                                 @"time":fence.time,
                                 @"type":fence.type,
                                 @"user_id":fence.user_id
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/fence";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"success");
            
            [Config saveFence:fence];
            
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
        NSLog(@"操作失败");
    }];

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
            [self resetArea];
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
        NSLog(@"操作失败");
    }];
}


//撤销
- (void)clickBackButton {
    NSLog(@"tapCount:%d",tapcount);
    if(tapcount <= 0){
        return ;
    }
    [mapView removeAnnotation:polygonAnnotation[tapcount - 1]];
    [mapView removeOverlay:polygonView];
    
    if (tapcount - 1 >= 3) {
        polygonView = [MAPolygon polygonWithCoordinates:touchPoints count:tapcount - 1];
        [mapView addOverlay:polygonView];
    }
    tapcount--;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];

    UITouch *touch = [[event allTouches]anyObject];
    CGPoint point = [touch locationInView:self.view];
    NSLog(@"tapcount : %d",tapcount);
    if (_drawCircle) {
        NSLog(@"_drawCircle");
        if (touchAnnotation && pointCircle) {
            [mapView removeAnnotation:touchAnnotation];
            [mapView removeOverlay:pointCircle];
        }
        touchCoordinate = [mapView convertPoint:point toCoordinateFromView:self.view];
        touchAnnotation = [MAPointAnnotation new];
        touchAnnotation.coordinate = touchCoordinate;
        
        [mapView addAnnotation:touchAnnotation];
        
        if (!_radius) {
            _radius = 0;
        }
        
        
        pointCircle = [MACircle circleWithCenterCoordinate:touchCoordinate radius:_radius];
        [mapView addOverlay:pointCircle];

    }
    
    if (_drawPolygon) {
        if (tapcount >= 10) {
            [self showAlertViewWithTitle:@"点的数目不能超过10"];
            return;
        }
        touchCoordinate = [mapView convertPoint:point toCoordinateFromView:self.view];
        touchPoints[tapcount] = touchCoordinate;
        touchAnnotation = [MAPointAnnotation new];
        touchAnnotation.coordinate = touchCoordinate;
        [mapView addAnnotation:touchAnnotation];
        
        
        MAMapPoint point =  MAMapPointForCoordinate(touchCoordinate);
        
        for (int i = 0;i< tapcount;i ++) {
            double distance = MAMetersBetweenMapPoints(points[i], point);
            
            NSLog(@"%f",distance);
        }
        
        polygonAnnotation[tapcount] = touchAnnotation;
        points[tapcount] = point;
        if (tapcount >= 2) {
            if (polygonView) {
                [mapView removeOverlay:polygonView];
            }
            polygonView = [MAPolygon polygonWithCoordinates:touchPoints count:tapcount + 1];
            
            
            [mapView addOverlay:polygonView];
        }
        tapcount ++;
        NSLog(@"tapcount:%d",tapcount);
    }
}

- (void)showAlertViewWithTitle:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
@end
