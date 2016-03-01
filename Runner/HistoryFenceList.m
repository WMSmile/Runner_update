//
//  HistoryFenceList.m
//  Runner
//
//  Created by 于恩聪 on 15/7/9.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "HistoryFenceList.h"
#import "HistoryViewController.h"
#import "NewFenceView.h"
#import "Networking.h"
#import "Fence.h"
@interface HistoryFenceList ()
{
    //
    NSMutableArray *fencesArray;
    NSString *fenceName;
    
    NSString *user_id;
    NSString *shouhuan_id;
    
}
@end

@implementation HistoryFenceList

@synthesize sections,section0,section1,fencenameList;
@synthesize table;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initData];
    [self initSection];
    [self initTable];
    [self initNavigation];
}

- (void)initData{
    user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
}
- (void)initNavigation {
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"电子围栏";
    self.navigationItem.titleView= titleLabel;
    self.title = @"电子围栏";
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getWatchMessage];
    [self initSection];
    [self initTable];
}
- (void)initSection {
    fencenameList = [[NSUserDefaults standardUserDefaults] objectForKey:@"fencenameList"];
    fencesArray = [NSMutableArray new];
    if (!fencenameList) {
        fencenameList = [NSMutableArray new];
    } else{
        fencenameList = [NSMutableArray arrayWithArray:fencenameList];
    }
    section1 = fencenameList;
    
    section0 = [NSMutableArray arrayWithObject:@" 创建围栏"];
    sections = [NSMutableArray arrayWithObjects:section0,fencesArray, nil];
    
}
- (void)initTable {
    table = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    table.backgroundColor = [UIColor whiteColor];
    table.showsVerticalScrollIndicator = NO;
    table.delegate = self;
    table.dataSource = self;
    table.frame = CGRectMake(10, 40, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height - 100);
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    [self.view addSubview:table];
    
}

- (void)getWatchMessage {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    if (!shouhuan_id) {
        return;
    }
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/getshouhuanlatestinfo";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"success");
            
            NSString *allFenceMessageTemp = [dict objectForKey:@"fence"];
            
            NSRange range = {1,allFenceMessageTemp.length - 2};
            NSString *allFenceMessage = [allFenceMessageTemp substringWithRange:range];
            
            NSLog(@"fence:%@",allFenceMessage);
            
            NSArray *fenceArray = [allFenceMessage componentsSeparatedByString:@"}"];
            for (int i = 0; i < fenceArray.count - 1; i ++) {
                NSString *firstFenceTemp = [fenceArray objectAtIndex:i];
                
                if (i > 0) {
                    NSRange _range = {1,firstFenceTemp.length - 1};
                    firstFenceTemp = [firstFenceTemp substringWithRange:_range];
                }
                
                NSString *fenceMessage = [NSString stringWithFormat:@"%@}",firstFenceTemp];
                
                
                NSData *jsonData = [fenceMessage dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
                
                fenceName = [jsonDict objectForKey:@"fence_name"];
                
                [fencesArray addObject:fenceName];
                
                Fence *fence = [Fence new];
                fence.fence = [jsonDict objectForKey:@"fence"];
                fence.fence_id = [jsonDict objectForKey:@"fence_id"];
                fence.fence_name = [jsonDict objectForKey:@"fence_name"];
                fence.shouhuan_id = [jsonDict objectForKey:@"shouhuan_id"];
                fence.time = [jsonDict objectForKey:@"time"];
                fence.type = [jsonDict objectForKey:@"type"];
                fence.user_id = [jsonDict objectForKey:@"user_id"];
                
                BOOL success = [Config saveFence:fence];
                if (success) {
                    NSLog(@"save success");
                }
                
                NSLog(@"fenceName : %@",fenceName);
                
                NSLog(@"fenceMessage : %@",fenceMessage);
                
                NSLog(@"fenceMessageDict : %@",jsonDict);

            }
            NSLog(@"fencesArray:%@",fencesArray);
            [self initTable];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==1) {
        return [[sections objectAtIndex:section] count] + 1;
    }
    return [[sections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CMainCell = @"CMainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: CMainCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([indexPath section] == 0) {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"createFenceBackView.jpg"]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if ([indexPath row] == 0 &&[indexPath section] == 1) {
        cell.textLabel.text = @"围栏列表";
        cell.textLabel.textColor = DEFAULTCOLOR;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellCorner"]];
        [cell setBackgroundView:imageView];
        [cell setUserInteractionEnabled:NO];
    }
    if ([indexPath row] > 0) {
        cell.textLabel.text = [[sections objectAtIndex:[indexPath section]]objectAtIndex:[indexPath row] - 1];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellnoCorner"]];
        [imageView.layer setBorderColor:[UIColor grayColor].CGColor];
        [imageView.layer setBorderWidth:0.3f];
        [imageView.layer setCornerRadius:3.f];
        [cell setBackgroundView:imageView];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        NewFenceView *createFence = [NewFenceView new];
        createFence.hidesBottomBarWhenPushed = YES;
        createFence.fencesArray = fencesArray;
        [self.navigationController pushViewController:createFence animated:YES];
        return;
    }
    NSString *selectedFenceName = [[sections objectAtIndex:[indexPath section]]objectAtIndex:[indexPath row] - 1];
    HistoryViewController *history = [HistoryViewController new];
    history.fenceName = selectedFenceName;
    history.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:history animated:YES];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        return 50;
    }
    return 40;
}

@end
