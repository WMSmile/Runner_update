//
//  ViewController.m
//  HelloAmap
//
//  Created by xiaoming han on 14-10-21.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "SearchViewController.h"
#import "HomeViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "Constant.h"

#define kDefaultLocationZoomLevel       16.1
#define kDefaultControlMargin           22

@interface SearchViewController ()<MAMapViewDelegate, AMapSearchDelegate, UITableViewDataSource, UITableViewDelegate>
{
    AMapSearchAPI *_search;
    
    CLLocation *_currentLocation;
    UIButton *_locationButton;
    
    UITableView *_tableView;
    NSArray *_pois;
    
    NSString *keywords;
    
    UITextField *keywordsTextField;
}
@end

@implementation SearchViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSearch];
    [self initTableView];
    [self initAttributes];
    [self initTitleView];
}
- (void) initTitleView {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    titleView.backgroundColor = NAVIGATION_COLOR;
    
    [self.view addSubview:titleView];
    
    UIButton *returnButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 27, 40, 25)];
    [returnButton setBackgroundImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    
    [returnButton addTarget:self action:@selector(returnHomeView) forControlEvents:UIControlEventTouchUpInside];
    
    [titleView addSubview:returnButton];
    
    keywordsTextField = [[UITextField alloc] initWithFrame: CGRectMake(40, 25, SCREEN_WIDTH - 80, 30)];
    [keywordsTextField setBackgroundColor:[UIColor whiteColor]];
    [keywordsTextField.layer setBorderColor:[UIColor grayColor].CGColor];
    [keywordsTextField.layer setBorderWidth:1.f];
    [keywordsTextField.layer setCornerRadius:3.f];
    
    [keywordsTextField setClearsOnBeginEditing:YES];
    [keywordsTextField setKeyboardType:UIKeyboardTypeDefault];
    
    [keywordsTextField.layer setCornerRadius:15.f];
    
    [keywordsTextField setLeftView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]]];
    [titleView addSubview:keywordsTextField];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    searchButton.frame = CGRectMake(SCREEN_WIDTH - 40, 25, 30, 30);
    searchButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    searchButton.backgroundColor = NAVIGATION_COLOR;
    [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    
    [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    
    [titleView addSubview:searchButton];
    
}
- (void) returnHomeView {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)initSearch
{
    _search = [[AMapSearchAPI alloc] initWithSearchKey:APIKey Delegate:self];
}

- (void)initAttributes
{
    _pois = nil;
}

- (void)initTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.hidden = YES;
    [self.view addSubview:_tableView];
}

- (void)searchAction
{
    if (_search == nil)
    {
        NSLog(@"search failed");
        return;
    }
    _tableView.hidden = NO;
    [keywordsTextField resignFirstResponder];
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    request.searchType = AMapSearchType_PlaceKeyword;
    request.location = [AMapGeoPoint locationWithLatitude:39.931694 longitude:116.381060];
    
    request.keywords = keywordsTextField.text;
    
    NSLog(@"request.keywords:%@",request.keywords);
    
    [_search AMapPlaceSearch:request];
}
- (void)reGeoAction
{
    if (_currentLocation)
    {
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
        
        request.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
        
        [_search AMapReGoecodeSearch:request];
    }
}

#pragma mark - AMapSearchDelegate

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"request :%@, error :%@", request, error);
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
    NSLog(@"request: %@", request);
    NSLog(@"response: %@", response);
    
    if (response.pois.count > 0)
    {
        _pois = response.pois;
        
        [_tableView reloadData];
        
        // 清空标注
    }
}

#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.canShowCallout = YES;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    // 修改定位按钮状态
    if (mode == MAUserTrackingModeNone)
    {
        [_locationButton setImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
    }
    else
    {
        [_locationButton setImage:[UIImage imageNamed:@"location_yes"] forState:UIControlStateNormal];
    }
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    NSLog(@"userLocation: %@", userLocation.location);
    _currentLocation = [userLocation.location copy];
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    // 选中定位annotation的时候进行逆地理编码查询
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        [self reGeoAction];
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    AMapPOI *poi = _pois[indexPath.row];
    
    cell.textLabel.text = poi.name;
    cell.detailTextLabel.text = poi.address;
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _pois.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 为点击的poi点添加标注
    AMapPOI *poi = _pois[indexPath.row];
    
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
    
    annotation.title = poi.name;
    annotation.subtitle = poi.address;
    
    HomeViewController *homeViewController = [HomeViewController new];
    
    self.trendDelegate=homeViewController; //设置代理
    [self.trendDelegate passLatitude:poi.location.latitude andLongitude:poi.location.longitude];
    [self.trendDelegate passTilte:annotation.title andSubTitle:annotation.subtitle];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    keywords = textField.text;
}
@end
