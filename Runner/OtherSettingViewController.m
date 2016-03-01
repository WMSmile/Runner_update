//
//  OtherSettingViewController.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/4.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "OtherSettingViewController.h"
#import "RedFlowerViewController.h"
#import "OfflineDetailViewController.h"
#import "CallPoliceViewController.h"
#import "ModeChoiceViewController.h"
#import "NoDisturbingTime.h"
#import "ChangePassword.h"
#import "Constant.h"

@interface OtherSettingViewController ()
{
    UITableView *listView;
    NSArray *listArray;
    UIView *modelChoiceView;
    UILabel *modelChoiceLabel;
    UIButton *pointButton;
    UIButton *lineButton;
    UIButton *modelSureButton;
    UIButton *modelCancelButton;
    
    UIView *circleView;
    UIView *selectedView;
    
    CGFloat heightForView;
    CGFloat widthForView;
    
    NSString *online;
    NSString *admin;
}
@end
@implementation OtherSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    online = [[NSUserDefaults standardUserDefaults] objectForKey:@"online"];
    
    admin = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminster"];
    
    NSLog(@"online : %@",online);
}

- (void) initUI {
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    
    //列表
    listView = [[UITableView alloc] initWithFrame:CGRectMake(3, -20, SCREEN_WIDTH - 6, SCREEN_HEIGHT - 30) style:UITableViewStyleGrouped];
    [listView setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    listView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    listView.showsHorizontalScrollIndicator = NO;
    listView.showsVerticalScrollIndicator = NO;
    listView.dataSource = self;
    listView.delegate = self;
    [self.view addSubview:listView];
    
    listArray = [NSArray arrayWithObjects:@"      账号设置",@"      定位设置",@"      免打扰设置",@"      轨迹显示设置",@"      报警开关设置",@"      离线地图下载",@"      红花奖励",nil];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        ChangePassword *changePassword = [ChangePassword new];
        [changePassword setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:changePassword animated:YES];
    }
    if ([indexPath row] == 1) {
        if ([online isEqualToString:@"0"]) {
            [self showAlertWatchOffLine];
            return;
        }
        if ([admin isEqualToString:@"0"]) {
            [self showAlertNoPower];
            return;
        }
        ModeChoiceViewController *modelChoice = [ModeChoiceViewController new];
        [modelChoice setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:modelChoice animated:YES];
    }
    if ([indexPath row] == 3) {
        [self showmodelChoiceView];
    }
    if ([indexPath row] == 4) {
        if ([online isEqualToString:@"0"]) {
            [self showAlertWatchOffLine];
            return;
        }
        if ([admin isEqualToString:@"0"]) {
            [self showAlertNoPower];
            return;
        }
        CallPoliceViewController *callPolice = [CallPoliceViewController new];
        [callPolice setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:callPolice animated:YES];
    }
    if ([indexPath row] == 5) {
        OfflineDetailViewController *offlineView = [OfflineDetailViewController new];
        [offlineView setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:offlineView animated:YES];
    }
    
    if ([indexPath row] == 6) {
        if ([online isEqualToString:@"0"]) {
            [self showAlertWatchOffLine];
            return;
        }
        if ([admin isEqualToString:@"0"]) {
            [self showAlertNoPower];
            return;
        }
        RedFlowerViewController *redFlower = [RedFlowerViewController new];
        [redFlower setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:redFlower animated:YES];
    }
    if ([indexPath row] == 2) {
        if ([online isEqualToString:@"0"]) {
            [self showAlertWatchOffLine];
            return;
        }
        if ([admin isEqualToString:@"0"]) {
            [self showAlertNoPower];
            return;
        }
        NoDisturbingTime *nodisturbing = [NoDisturbingTime new];
        nodisturbing.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:nodisturbing animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH - 12, 0)];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CMainCell = @"CMainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: CMainCell];
    }
    [cell.textLabel setText:[listArray objectAtIndex:[indexPath row]]];
    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSString *imageName = [NSString stringWithFormat:@"otherSetting%ld",(long)[indexPath row]];
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(10, 10, 30, 30)];
    
    [cell addSubview:imageView];
    
    [cell.layer setBorderColor:[UIColor grayColor].CGColor];
    [cell.layer setBorderWidth:0.3f];
    
    return cell;
}

- (void)showmodelChoiceView {
    if (modelChoiceView.hidden == YES) {
        modelChoiceView.hidden = NO;
        return;
    }
    
    
    heightForView = 100;
    widthForView = SCREEN_WIDTH / 2;
    
    if (!modelChoiceView) {
        modelChoiceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthForView, heightForView + 12)];
        [modelChoiceView setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:0.9]];
        modelChoiceView.center = self.view.center;
        
        [modelChoiceView.layer setBorderColor:[UIColor grayColor].CGColor];
        [modelChoiceView.layer setBorderWidth:0.3f];
        [modelChoiceView.layer setCornerRadius:6.f];
        
        [self.view addSubview:modelChoiceView];
    }
    if (!modelChoiceLabel) {
        modelChoiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, widthForView, heightForView / 4)];
        [modelChoiceLabel setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:0.9]];
        [modelChoiceLabel setText:@"选择轨迹显示模式"];
        [modelChoiceLabel setTextAlignment:NSTextAlignmentCenter];
        [modelChoiceLabel setTextColor:[UIColor blackColor]];
        [modelChoiceLabel setFont:[UIFont systemFontOfSize:15]];
        
        [modelChoiceView addSubview:modelChoiceLabel];
    }
    if (!pointButton) {
        pointButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 6 + heightForView / 4, widthForView, heightForView / 4)];
        [pointButton setBackgroundColor:[UIColor whiteColor]];
        
        [pointButton setTitle:@"点模式" forState:UIControlStateNormal];
        [pointButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pointButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [pointButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        
        circleView = [[UIView alloc] initWithFrame:CGRectMake(5 + 25, 5, heightForView / 4 - 10, heightForView / 4 - 10)];
        [circleView setBackgroundColor:[UIColor whiteColor]];
        [circleView.layer setBorderColor:[UIColor grayColor].CGColor];
        [circleView.layer setBorderWidth:0.3f];
        [circleView.layer setCornerRadius:(heightForView / 4 - 10) / 2];
        [circleView setClipsToBounds:YES];
        [circleView setUserInteractionEnabled:NO];
        
        selectedView = [[UIView alloc] initWithFrame:CGRectMake(32, 7, heightForView / 4 - 14, heightForView / 4 - 14)];
        [selectedView setBackgroundColor:DEFAULTCOLOR];
        [selectedView.layer setCornerRadius:(heightForView / 4 - 14)/2];
        [selectedView.layer setBorderWidth:0.3f];
        [selectedView.layer setBorderColor:[UIColor grayColor].CGColor];
        [selectedView setUserInteractionEnabled:NO];
        
        [pointButton addSubview:circleView];
        
        [pointButton addSubview:selectedView];
        
        [pointButton addTarget:self action:@selector(changeModelChoice:) forControlEvents:UIControlEventTouchUpInside];
        [modelChoiceView addSubview:pointButton];
    }
    if (!lineButton) {
        lineButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 6 + heightForView / 2, widthForView, heightForView / 4)];
        [lineButton setBackgroundColor:[UIColor whiteColor]];
        
        [lineButton setTitle:@"点线模式" forState:UIControlStateNormal];
        [lineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [lineButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [lineButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        
        circleView = [[UIView alloc] initWithFrame:CGRectMake(30, 5, heightForView / 4 - 10, heightForView / 4 - 10)];
        [circleView setBackgroundColor:[UIColor whiteColor]];
        [circleView.layer setBorderColor:[UIColor grayColor].CGColor];
        [circleView.layer setBorderWidth:0.3f];
        [circleView.layer setCornerRadius:(heightForView / 4 - 10) / 2];
        [circleView setClipsToBounds:YES];
        [circleView setUserInteractionEnabled:NO];
        
        [lineButton addSubview:circleView];
        
        [modelChoiceView addSubview:lineButton];
    }
    if (!modelCancelButton || !modelSureButton) {
        modelSureButton = [[UIButton alloc] initWithFrame:CGRectMake(widthForView / 2, heightForView / 4 * 3 + 6, widthForView / 2, heightForView / 4)];
        [modelSureButton setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:0.9]];
        [modelSureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [modelSureButton setTitle:@"确定" forState:UIControlStateNormal];
        [modelSureButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [modelSureButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        
        [modelSureButton addTarget:self action:@selector(makeSureModeChoice:) forControlEvents:UIControlEventTouchUpInside];
        [modelSureButton setTag:1];
        
        [modelChoiceView addSubview:modelSureButton];
        
        modelCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, heightForView / 4 * 3 + 6, widthForView / 2, heightForView / 4)];
        [modelCancelButton setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:0.9]];
        [modelCancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [modelCancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];;
        [modelCancelButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [modelCancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [modelCancelButton addTarget:self action:@selector(makeSureModeChoice:) forControlEvents:UIControlEventTouchUpInside];
        [modelCancelButton setTag:2];
        
        [lineButton addTarget:self action:@selector(changeModelChoice:) forControlEvents:UIControlEventTouchUpInside];
        [modelChoiceView addSubview:modelCancelButton];
    }
}

- (void)changeModelChoice:(UIButton *)sender{
    NSLog(@"changeModel:%@",sender.titleLabel.text);
    if(sender == pointButton) {
        NSLog(@"clickPointButotn");
        [selectedView removeFromSuperview];
        [pointButton addSubview:selectedView];
        [pointButton setTag:10];
    }
    if (sender == lineButton) {
        [selectedView removeFromSuperview];
        [lineButton addSubview:selectedView];
        [lineButton setTag:10];
    }
}
- (void)makeSureModeChoice:(UIButton *)btn {
    if (btn.tag == 1) {
        [modelChoiceView setHidden:YES];
    }
    if (btn.tag == 2) {
        [modelChoiceView setHidden:YES];
        if (pointButton.tag == 20) {
            [[NSUserDefaults standardUserDefaults] setObject:@"point" forKey:@"historyTrackShowWay"];
        }
        if (lineButton.tag == 20) {
            [[NSUserDefaults standardUserDefaults] setObject:@"line" forKey:@"historyTrackShowWay"];
        }
    }
}

- (void)showAlertWatchOffLine{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"手环不在线" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
             
             - (void)showAlertNoPower{
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您不是管理员，没有权限" message:nil delegate:self
                                                           cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                 [alertView show];
             }

@end
