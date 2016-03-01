//
//  FirstViewController.m
//  Runner
//
//  Created by 于恩聪 on 15/6/23.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

//
//  FirstViewController.m
//  Runner
//
//  Created by 于恩聪 on 15/5/17.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "SearchViewController.h"
#import <MAMapServices.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "Networking.h"
#import "Config.h"
#import "Constant.h"
#import "Command.h"
#import "Mymapview.h"

static HomeViewController *homeView;

static CGFloat searchLatitude;
static CGFloat searchLongitude;

static NSString *pointTitle;
static NSString *pointSubTitle;
@interface HomeViewController ()<MAMapViewDelegate,AMapSearchDelegate,UIAlertViewDelegate,MAAnnotation,NSURLConnectionDelegate,NSURLConnectionDataDelegate,NetworkingDelegate>
{
    UIButton *recordButton;
    UIButton *positonButton;
    BOOL isLogin;
    
    MAPointAnnotation *locationPointAnnotation;
    
    MAPointAnnotation *searchPointAnnotation;
    
    Mymapview *myMapview;
    MAMapView *mapView;

    //逆地理编码
    CLLocation *_currentLocation;
    AMapSearchAPI *_search;
    
    double locationX;
    double locationY;
    
    //navigation
    UIView *navigationView;
    UIButton *titleButton;
    NSMutableArray *userArray;
    UIView *userView;

    //手环
    NSString *user_name;
    NSString *user_id;
    NSString *shouhuan_id;
    NSString *shouhuan_name;
    
    NSString *channel_id;
    
    NSString *batteryPower;
    NSString *online;
    NSString *locationMode;
    //信息栏
    UILabel *modeLabel;
    UILabel *messageLabel;
    //电池
    UIImageView *batteryView;
    //信号强度
    UIImageView *signalView;
}
@end

@implementation HomeViewController
@synthesize coordinate;
@synthesize zoominButton,zoomoutButton;
@synthesize titleButton;
@synthesize tableArray;
@synthesize navigationItem;
@synthesize timer;
@synthesize currentLocation;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self createChannelID];
    [self initUIView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    
    [self initMapView];

    //实时定位
    
    [self setlocation];
    
    timer =  [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(setlocation) userInfo:nil repeats:YES];
    
    //显示 搜索返回的点
    if (searchLongitude && searchLatitude) {
        mapView.centerCoordinate = CLLocationCoordinate2DMake(searchLatitude, searchLongitude);
        if (searchPointAnnotation) {
            [mapView removeAnnotation:searchPointAnnotation];
        }
        searchPointAnnotation = [[MAPointAnnotation alloc]init];
        searchPointAnnotation.coordinate = CLLocationCoordinate2DMake(searchLatitude, searchLongitude);
        
        searchPointAnnotation.title = pointTitle;
        searchPointAnnotation.subtitle = pointSubTitle;
        
        [mapView addAnnotation:searchPointAnnotation];
    }
    
    [self initData];
    [self initUsersView];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewwilldisappear");
    [super viewWillDisappear:animated];
    
    [timer invalidate];
    
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];
    
    [userView setHidden:YES];
}

- (void) initData {
    userArray = [NSMutableArray new];
    
    NSMutableArray *tempArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"allshouhuanmessage"];
    
    for (int i = 0; i < tempArray.count; i ++) {
        NSDictionary *dict = [tempArray objectAtIndex:i];
        [userArray addObject:[dict objectForKey:@"name"]];
    }
    
    NSLog(@"userarray : %@",userArray);
    
    user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    
    shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
    
    shouhuan_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_name"];
    
    channel_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel_id"];
    
    [self getWatchPortrait];
    [self createChannelID];
    [self getAdmin];
    
}

- (void)initUIView {
    [self initMessageView];
    [self initNavigation];
    [self initBattery];
    [self initSignal];
    [self getLocationDetailMessage];
    [self initUsersView];
    [self initButton];
}


- (void)initMapView{
    myMapview = [Mymapview sharedInstance];
    [myMapview setFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 100)];
    
    myMapview._search = [[AMapSearchAPI alloc] initWithSearchKey:APIKey Delegate:self];
    
    mapView = myMapview.mapView;
    
    mapView.delegate = self;
    
    _search = myMapview._search;
    
    [mapView removeAnnotations:mapView.annotations];
    [mapView removeOverlays:mapView.overlays];
    
    [self.view addSubview:myMapview];
    [self.view sendSubviewToBack:myMapview];
    
}


//获取手环头像

- (void)getWatchPortrait{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"multipart/form-data"];
    
    
    NSLog(@"%@ %@",shouhuan_id,user_id);
    
    if (!shouhuan_id || !user_id) {
        return;
    }
    NSDictionary *parameters = @{
                                 @"download_id":shouhuan_id,
                                 @"user_id":user_id,
                                 @"type" : @"0"
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/headicondownload";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //不存在头像
        if (![operation responseData]){
            NSLog(@"不存在头像");
            return ;
        }
        [[NSUserDefaults standardUserDefaults] setObject:[operation responseData] forKey:[NSString stringWithFormat:@"%@.protrait",shouhuan_id]];
        
        [self setlocation];
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"success");
            }
        if ([code isEqualToString:@"200"]) {
 
        }
        if ([code isEqualToString:@"500"]) {
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"获取头像失败" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        NSLog(@"获取头像失败:%@",error);
    }];
}
- (void)getWatchMessage {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    if (!shouhuan_id || !user_id) {
        return;
    }
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/getshouhuanlatestlocation";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"watchMessage : %@",responseObject);
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"success");
            batteryPower = [dict objectForKey:@"bat"];
            
            [batteryView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"battery_%@",batteryPower]]];
            locationMode = [dict objectForKey:@"mode"];
            
            online = [dict objectForKey:@"online"];
            
            [[NSUserDefaults standardUserDefaults] setObject:online forKey:@"online"];
            
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"step_num"] forKey:@"step_num"];
            
            NSLog(@"battery:%@ mode:%@ online:%@",batteryPower,locationMode,online);
            
            if ([locationMode isEqualToString:@"mix"]) {
                [modeLabel setText:@"基站wifi混合定位"];
            }
            if ([locationMode isEqualToString:@"gps"]) {
                [modeLabel setText:@"gps定位"];
            }
            NSString *location = [dict objectForKey:@"location"];
            
            if (location.length < 2) {
                return ;
            }
            NSScanner *scanner = [NSScanner scannerWithString:location];
            
            [scanner scanDouble:&locationX];
            
            scanner.scanLocation ++;
            
            [scanner scanDouble:&locationY];
            
            mapView.centerCoordinate = CLLocationCoordinate2DMake(locationY, locationX);
            
            if (locationPointAnnotation) {
                [mapView removeAnnotation:locationPointAnnotation];
            }
            locationPointAnnotation = [[MAPointAnnotation alloc]init];
            locationPointAnnotation.coordinate = CLLocationCoordinate2DMake(locationY, locationX);
            
            [mapView addAnnotation:locationPointAnnotation];
            
            AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
            request.searchType = AMapSearchType_PlaceAround;
            request.location = [AMapGeoPoint locationWithLatitude:locationPointAnnotation.coordinate.latitude longitude:locationPointAnnotation.coordinate.longitude];
            
            [_search AMapPlaceSearch:request];

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

- (void)getAdmin{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/json", nil];
    
    shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
    
    user_id  = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    
    
    if (!shouhuan_id) {
        return;
    }
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/addrelation";
    
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"success");
            
            NSString *tempData = [dict objectForKey:@"data"];
            
            NSRange range = {1,tempData.length - 2};
            
            NSString *data = [tempData substringWithRange:range];
            
            NSArray *fenceArray = [data componentsSeparatedByString:@"}"];
            for (int j = 0; j < fenceArray.count - 1; j ++) {
                NSString *firstFenceTemp = [fenceArray objectAtIndex:j];
                
                if (j > 0) {
                    NSRange _range = {1,firstFenceTemp.length - 1};
                    firstFenceTemp = [firstFenceTemp substringWithRange:_range];
                }
                
                NSString *fenceMessage = [NSString stringWithFormat:@"%@}",firstFenceTemp];
                
                
                NSData *jsonData = [fenceMessage dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
                
                if ([[jsonDict objectForKey:@"user_id"] isEqualToString:user_id]) {
                    NSNumber *adminnumber = [jsonDict objectForKey:@"administor"];
                    
                    NSString *admin = [NSString stringWithFormat:@"%@",adminnumber];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:admin forKey:@"adminster"];
                    
                }
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@",error);
    }];

}

- (void)createChannelID{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    if (!user_id || !channel_id) {
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"channel_id":channel_id,
                                 @"user_id":user_id,
                                 @"device_type":@"4"
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/addchannelid";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"add channnelid success");
        }
        if ([code isEqualToString:@"200"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"用户名或密码错误" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        if ([code isEqualToString:@"500"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"系统内部错误" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];

}

- (void)getLocationDetailMessage {
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    request.searchType = AMapSearchType_PlaceAround;
    request.location = [AMapGeoPoint locationWithLatitude:locationPointAnnotation.coordinate.latitude longitude:locationPointAnnotation.coordinate.longitude];
    
    [_search AMapPlaceSearch:request];
}

- (void)initNavigation {
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1]];
    navigationItem = [[UINavigationItem alloc] initWithTitle:@"首页"];
    
    UIButton *usernameButton = [[UIButton alloc] initWithFrame:CGRectZero];
    
    navigationItem.titleView = usernameButton;
    
    [self.navigationController.navigationBar pushNavigationItem:navigationItem animated:NO];
    
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1]];
    [self.navigationController setNavigationBarHidden:YES];
    //创建一个navigation
    navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    [navigationView setBackgroundColor:DEFAULTCOLOR];
    
    [self.view addSubview:navigationView];
    
    titleButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 50, 30, 100, 30)];
    
    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    NSLog(@"shouhuan_name : %@",shouhuan_name);
    
    [titleButton setTitle: shouhuan_name forState:UIControlStateNormal];
    [titleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [titleButton addTarget:self action:@selector(showUsersView) forControlEvents:UIControlEventTouchUpInside];
    
    [navigationView addSubview:titleButton];
}

- (void)initUsersView {
    
    CGFloat basicHeight = 20;
    
    userView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 50, 64, 100, basicHeight * userArray.count + 12)];
    
    [userView setBackgroundColor:DEFAULTCOLOR];
    
    [userView.layer setBorderWidth:0.3f];
    [userView.layer setBorderColor:[UIColor grayColor].CGColor];
    [userView.layer setCornerRadius:6.f];
    [userView setHidden:YES];
    [self.view addSubview:userView];
    if (!userArray) {
        return;
    }
    for (int i = 0; i < userArray.count; i++) {
        UIButton *userChoiceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 6 + basicHeight * i, 100, basicHeight)];
        [userChoiceButton setTitle:[userArray objectAtIndex:i] forState:UIControlStateNormal];
        [userChoiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [userChoiceButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [userChoiceButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [userChoiceButton setTag:i];
        [userChoiceButton addTarget:self action:@selector(changeWatch:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [userChoiceButton setBackgroundColor:DEFAULTCOLOR];
        [userView addSubview:userChoiceButton];
    }
}

- (void)changeWatch:(UIButton *)sender{
    NSMutableArray *tempArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"allshouhuanmessage"];
    NSDictionary *dict = [tempArray objectAtIndex:sender.tag];
    
    if ([[dict objectForKey:@"name"] isEqualToString:titleButton.titleLabel.text]) {
        return;
    }
    
    [titleButton setTitle:[userArray objectAtIndex:sender.tag] forState:UIControlStateNormal];
    [userView setHidden:YES];

    
    NSLog(@"dict : %@",dict);
    
    shouhuan_id = [dict objectForKey:@"shouhuan_id"];
    
    shouhuan_name = [dict objectForKey:@"name"];
    
    [[NSUserDefaults standardUserDefaults] setObject:shouhuan_name forKey:@"shouhuan_name"];
    [[NSUserDefaults standardUserDefaults] setObject:shouhuan_id forKey:@"shouhuan_id"];
    
    
    [self getWatchPortrait];
    [self getWatchMessage];
    [self createChannelID];
    [self getAdmin];
    
    [Command commandWithName:@"CR" andParameter:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hasChangeWatch"];
}

- (void) initBattery {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 42, 22, 36, 36)];
    view.backgroundColor = [UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1];
    view.layer.cornerRadius = 18.f;
    view.opaque = NO;
    batteryView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 24, 15)];
    
    [view addSubview:batteryView];
    [navigationView addSubview:view];
}

- (void)initSignal{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(6, 22, 36, 36)];
    view.backgroundColor = [UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1];
    view.layer.cornerRadius = 18.f;
    view.opaque =NO;
    
    signalView = [[ UIImageView alloc] initWithFrame:CGRectMake(5, 5, 24, 15)];
    [view addSubview:signalView];
    
    [navigationView addSubview:view];
                     
}
- (void)initMessageView {
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 44 - 40, SCREEN_WIDTH, 40)];
    [backView.layer setBorderColor:[UIColor grayColor].CGColor];
    [backView.layer setBorderWidth:0.5];

    messageLabel = [UILabel new];
    messageLabel.font = [UIFont systemFontOfSize:13];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.frame = CGRectMake(0, 6, [UIScreen mainScreen].bounds.size.width,35);
    [messageLabel setTextColor:[UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1]];
    messageLabel.backgroundColor = [UIColor whiteColor];
    [backView addSubview:messageLabel];
    
    modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, SCREEN_WIDTH, 10)];
    [modeLabel setFont:[UIFont systemFontOfSize:10]];
    [modeLabel setTextAlignment:NSTextAlignmentLeft];
    [modeLabel setTextColor:DEFAULTCOLOR];
    [modeLabel setBackgroundColor:[UIColor whiteColor]];
    
    if ([locationMode isEqualToString:@"mix"]) {
        [modeLabel setText:@"基站wifi混合定位"];
    }
    if ([locationMode isEqualToString:@"gps"]) {
        [modeLabel setText:@"gps定位"];
    }
    [backView addSubview:modeLabel];
    
    [self.view addSubview:backView];
}


- (void)initButton {
    //搜索
    UIButton *SearchButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 75, 36, 36)];
    
    [SearchButton setBackgroundImage:[UIImage imageNamed:@"map_search"] forState:UIControlStateNormal];
    [SearchButton setBackgroundImage:[UIImage imageNamed:@"map_search_press"] forState:UIControlStateSelected];
    
    [SearchButton.layer setCornerRadius:18];
    [SearchButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [SearchButton.layer setBorderWidth:1.f];
    
    [SearchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:SearchButton];
    //地图模式
    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 115, 36, 36)];
    [changeButton setBackgroundImage:[UIImage imageNamed:@"map_mode_map"] forState:UIControlStateNormal];
    [changeButton setClipsToBounds:YES];
    
    [changeButton.layer setCornerRadius:18];
    [changeButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [changeButton.layer setBorderWidth:1.f];
    
    [changeButton addTarget:self action:@selector(changeModel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:changeButton];
    
    //录音
    recordButton = [UIButton new];
    recordButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [recordButton setFrame:CGRectMake(6, SCREEN_HEIGHT - 150,35 ,35)];
    [recordButton setBackgroundColor:[UIColor clearColor]];
    [recordButton.layer setMasksToBounds:YES];
    [recordButton setBackgroundImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
    [recordButton setBackgroundImage:[UIImage imageNamed:@"mic_press"] forState:UIControlStateHighlighted];
    [self.view addSubview:recordButton];
    [recordButton addTarget:self action:@selector(beginRecord) forControlEvents:UIControlEventTouchUpInside];
    
    //定位
    positonButton = [UIButton new];
    [positonButton setFrame:CGRectMake(6,[UIScreen mainScreen].bounds.size.height - 195
                                       ,35,35)];
    [positonButton setBackgroundColor:[UIColor clearColor]];
    [positonButton.layer setMasksToBounds:YES];
    [positonButton setBackgroundImage:[UIImage imageNamed:@"getlocation.png"] forState:UIControlStateNormal];
    [positonButton setBackgroundImage:[UIImage imageNamed:@"getlocation_press.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:positonButton];
    [positonButton addTarget:self action:@selector(clickLocationButton) forControlEvents:UIControlEventTouchUpInside];
    //地图缩放
    zoominButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 41, SCREEN_HEIGHT - 120, 35, 35)];
    [zoominButton setBackgroundColor:[UIColor clearColor]];
    [zoominButton setBackgroundImage:[UIImage imageNamed:@"zoomin"] forState:UIControlStateNormal];
    [zoominButton setBackgroundImage:[UIImage imageNamed:@"zoominPress"] forState:UIControlStateHighlighted];
    [zoominButton addTarget:self action:@selector(zoomIn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zoominButton];

    zoomoutButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 41, SCREEN_HEIGHT - 155, 35, 35)];
    [zoomoutButton setBackgroundColor:[UIColor clearColor]];
    [zoomoutButton setBackgroundImage:[UIImage imageNamed:@"zoomout"] forState:UIControlStateNormal];
    [zoomoutButton setBackgroundImage:[UIImage imageNamed:@"zoomoutPress"] forState:UIControlStateHighlighted];
    [zoomoutButton addTarget:self action:@selector(zoomOut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zoomoutButton];
    
}

//点击事件
- (void) search {
    SearchViewController *searchView = [SearchViewController new];
    searchView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchView animated:YES];
}
//改变地图模式
- (void) changeModel:(UIButton *)sender{
    if (mapView.mapType == MAMapTypeSatellite) {
        [mapView setMapType:MAMapTypeStandard];
        [sender setBackgroundImage:[UIImage imageNamed:@"map_mode_map"] forState:UIControlStateNormal];
    } else{
        [mapView setMapType:MAMapTypeSatellite];
        [sender setBackgroundImage:[UIImage imageNamed:@"map_mode_real"] forState:UIControlStateNormal];
    }
}
- (void) showUsersView {
    if (userView.hidden) {
        userView.hidden = NO;
    }else {
        userView.hidden = YES;
    }
}
- (void)beginRecord{
    NSLog(@"开始录音");
    [Command commandWithName:@"MONITOR" andParameter:@""];
    
    [messageLabel setText:@"录音中 ..."];
    
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    
    [modeLabel setText:@" "];
    
}

- (void)clickLocationButton{
    [messageLabel setText:@"开始定位..."];
    
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    
    [modeLabel setText:@" "];
    
    [self setlocation];
}

- (void)setlocation {
    NSLog(@"setlocation");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    if (!shouhuan_id || !user_id) {
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/getshouhuanlatestlocation";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"jsonSuccess : %@",responseObject);
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        NSString *location = [dict objectForKey:@"location"];
        
        NSNumber *battery = [dict objectForKeyedSubscript:@"bat"];
        
        int i = [battery intValue];
        
        int j = i / 20;
        
        int tempBattery = j *20;
        
        
        NSNumber *gprs = [dict objectForKey:@"gprs"];
        
        int tempGprs = [gprs intValue] / 20 * 20;
        
        locationMode = [dict objectForKeyedSubscript:@"mode"];
        
        online = [dict objectForKey:@"online"];
        
        [[NSUserDefaults standardUserDefaults] setObject:online forKey:@"online"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"step_num"] forKey:@"step_num"];
        
        
        if ([[NSString stringWithFormat:@"%@",battery] isEqualToString:@"10"]) {
            
        }
        if ([[NSString stringWithFormat:@"%@",gprs] isEqualToString:@"10"]) {

        }
        [batteryView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"battery_%@",[NSString stringWithFormat:@"%d",tempBattery]]]];
        
        [signalView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"signal_%@",[NSString stringWithFormat:@"%d",tempGprs]]]];
        
        if ([locationMode isEqualToString:@"mix"]) {
            [modeLabel setText:@"基站wifi混合定位"];
        }
        if ([locationMode isEqualToString:@"gps"]) {
            [modeLabel setText:@"gps定位"];
        }
        if (location.length < 2) {
            return ;
        }
        
        if ([code isEqualToString:@"100"]) {
            
            NSScanner *scanner = [NSScanner scannerWithString:location];
            
            [scanner scanDouble:&locationX];
            
            scanner.scanLocation ++;
            
            [scanner scanDouble:&locationY];
            
            mapView.centerCoordinate = CLLocationCoordinate2DMake(locationY, locationX);

            if(!locationPointAnnotation){
                locationPointAnnotation = [[MAPointAnnotation alloc]init];
            }
            locationPointAnnotation.coordinate = CLLocationCoordinate2DMake(locationY, locationX);
            
            [mapView addAnnotation:locationPointAnnotation];
            
            AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
            request.searchType = AMapSearchType_PlaceAround;
            request.location = [AMapGeoPoint locationWithLatitude:locationPointAnnotation.coordinate.latitude longitude:locationPointAnnotation.coordinate.longitude];
            
            [_search AMapPlaceSearch:request];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@",error);
    }];

}
- (void)zoomIn {
    mapView.zoomLevel = mapView.zoomLevel * 0.8;
}
- (void)zoomOut {
    mapView.zoomLevel = mapView.zoomLevel * 1.2;
}


- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    NSString *title = response.regeocode.addressComponent.city;
    if (title.length == 0)
    {
        // 直辖市的city为空，取province
        title = response.regeocode.addressComponent.province;
    }
}

- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    if (response.pois.count > 0)
    {
        AMapPOI *poi = response.pois[0];
        self.currentLocation = [NSString stringWithFormat:@"%@%@",poi.address,poi.name];
        
    
        
        NSString *labelText = [NSString stringWithFormat:@"用户当前位置:%@",self.currentLocation];
        
        [messageLabel setTextAlignment:NSTextAlignmentLeft];
        [messageLabel setText:labelText];

    }
}


- (MAOverlayView *)mapView:(MAMapView *)_mapView viewForOverlay:(id <MAOverlay>)overlay
{
    //画圆的回调函数
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleView *circleView = [[MACircleView alloc] initWithCircle:overlay];
        
        circleView.lineWidth = 2.f;
        circleView.strokeColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.8];
        circleView.fillColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.8];
        [circleView setOpaque:YES];
        circleView.lineDash = YES;
        
        return circleView;
    }
    return nil;
}
//画annotation的回调函数
- (MAAnnotationView *)mapView:(MAMapView *)_mapView viewForAnnotation:(id<MAAnnotation>)_annotation{
    if ([_annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:_annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.pinColor = MAPinAnnotationColorGreen;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        
        
        annotationView.image = [UIImage imageNamed:@"signIcon"];
        [annotationView setFrame:CGRectMake(0, 0, 30, 30)];
        
        if (_annotation == locationPointAnnotation) {
            NSLog(@"annotation 回调");
            NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.protrait",shouhuan_id]];
            if (imageData) {
                UIImage *portraitImage = [UIImage imageWithData:imageData];
                
                [annotationView setImage:portraitImage];
                [annotationView setFrame:CGRectMake(0, 0, 30, 30)];
                [annotationView.layer setCornerRadius:15.f];
                [annotationView setClipsToBounds:YES];
            }
        }
        return annotationView;
    }
    return nil;
}


//搜索代理 
- (void)passLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude{
    searchLatitude =  latitude;
    searchLongitude = longitude;
    
    NSLog(@"%f %f",latitude,longitude);
}
- (void)passTilte:(NSString *)title andSubTitle:(NSString *)subtitle {
    pointTitle = title;
    pointSubTitle = subtitle;
}

@end
