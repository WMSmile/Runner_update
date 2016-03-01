//
//  membersViewController.m
//  Runner
//
//  Created by 于恩聪 on 15/7/12.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "MembersViewController.h"
#import "Constant.h"
#import "Networking.h"
@interface MembersViewController ()<UIAlertViewDelegate>
{
    UITableView *tabView;
    NSMutableArray *messageArray;
    NSMutableArray *applyArray;
    
    NSMutableArray *nameLabelArray;
    
    
    NSString *shouhuan_id;
    NSString *user_id;
    
    NSString *adminstor;
    
    UIAlertView *deleteAlert;
}

@end

@implementation MembersViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
}

- (void)viewWillAppear:(BOOL)animated{
    [self initData];
    [self initTable];
    [self getMembersData];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initData{
    messageArray = [NSMutableArray new];
    applyArray = [NSMutableArray new];
    nameLabelArray = [NSMutableArray new];
    
    adminstor = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminster"];
}
- (void)getMembersData {
    //服务器 获取信息
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
                
                if ([[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"power"]] isEqualToString:@"9"]) {
                    [messageArray addObject:jsonDict];

                }
                if ([[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"power"]] isEqualToString:@"0"] &&[adminstor isEqualToString:@"1"]) {
                    [applyArray addObject:jsonDict];
                    
                }

                
            }
            NSLog(@"messageArray : %@",messageArray);
            [tabView reloadData];

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
        NSLog(@"error : %@",error);
    }];

}
- (void)initTable {
    tabView = [[UITableView alloc]initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    tabView.backgroundColor = DEFAULT_BACKGOUNDCOLOR;
    tabView.showsVerticalScrollIndicator = NO;
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:tabView];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{\
    
    if (section == 0) {
        return  messageArray.count;
    }
    return applyArray.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CMainCell = @"CMainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier: CMainCell];
    }
    if ([indexPath section] == 0) {
        NSDictionary *singleDict = [messageArray objectAtIndex:[indexPath row]];
        UIView *backView = [self cellBackViewWithTiTle:[singleDict objectForKey:@"relation"] andSubTitle:[singleDict objectForKey:@"user_id"] andIdentity:[[singleDict objectForKey:@"administor"] intValue] == 1?@"管理员":@"普通用户" andPortrait:@"login_logo" andTag:(int)[indexPath row]];
        [cell addSubview:backView];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 30, 100, 30)];
        [button setTitle:@"修改关系" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [button setTitleColor:DEFAULTCOLOR forState:UIControlStateHighlighted];
        [button setTag:[indexPath row]];
        [button addTarget:self action:@selector(changeRelation:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:button];
        [cell setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    }
    
    if ([indexPath section] == 1) {
        NSDictionary *singleDict = [applyArray objectAtIndex:[indexPath row]];
        
        UIView *backView = [self cellBackViewWithTiTle:[singleDict objectForKey:@"relation"] andSubTitle:[singleDict objectForKey:@"user_id"] andIdentity:[[singleDict objectForKey:@"administor"] intValue] == 1?@"管理员":@"普通用户" andPortrait:@"login_logo" andTag:(int)[indexPath row]];
        [cell addSubview:backView];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 10, 50, 30)];
        [button setTitle:@"同意" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [button setTitleColor:DEFAULTCOLOR forState:UIControlStateHighlighted];
        [button setTag:[indexPath row]];
        [button addTarget:self action:@selector(solveApplication:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:button];
        
        UIButton *disgreeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 40, 50, 30)];
        [disgreeButton setTitle:@"拒绝" forState:UIControlStateNormal];
        [disgreeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [disgreeButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [disgreeButton setTitleColor:DEFAULTCOLOR forState:UIControlStateHighlighted];
        [disgreeButton setTag:[indexPath row]];
        [disgreeButton addTarget:self action:@selector(solveApplication:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:disgreeButton];

        
        [cell setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",adminstor);
    
    if (![adminstor isEqualToString:@"1"]) {
        return;
    }
    deleteAlert = [[UIAlertView alloc] initWithTitle:@"删除该用户？" message:nil delegate:self
                                   cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [deleteAlert setTag:[indexPath row]];
    [deleteAlert show];
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *singleDict = [messageArray objectAtIndex:[indexPath row]];
    
    if (![adminstor isEqualToString:@"1"]) {
        return nil;
    }
    
    if ([[NSString stringWithFormat:@"%@",[singleDict objectForKey:@"administor"]] isEqualToString:@"1"]) {
        return nil;
    }
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return  0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UIView *)cellBackViewWithTiTle:(NSString *)title andSubTitle:(NSString *)subTitle andIdentity:(NSString *)identity andPortrait:(NSString *)portrait andTag:(int)tag{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 40, 80)];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    [view.layer setBorderWidth:0.3f];
    [view.layer setBorderColor:[UIColor whiteColor].CGColor];
    [view.layer setCornerRadius:10.f];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:portrait]];
    [imageView setFrame:CGRectMake(10, 10, 60, 60)];
    [imageView setClipsToBounds:YES];
    
    [imageView.layer setBorderColor:[UIColor grayColor].CGColor];
    [imageView.layer setBorderWidth:0.3f];
    [imageView.layer setCornerRadius:30];
    
    [view addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, 60, 20)];
    [nameLabel setTextColor:[UIColor blackColor]];
    [nameLabel setText:title];
    [nameLabel setTextAlignment:NSTextAlignmentLeft];
    [nameLabel setFont:[UIFont systemFontOfSize:14.f]];
    [nameLabelArray addObject:nameLabel];
    
    [view addSubview:nameLabel];
    
    UILabel *identityLabel = [[UILabel alloc] initWithFrame:CGRectMake(80 + 50, 20, 60, 20)];
    [identityLabel setText:identity];
    [identityLabel setTextAlignment:NSTextAlignmentCenter];
    [identityLabel setTextColor:[UIColor whiteColor]];
    [identityLabel.layer setCornerRadius:10.f];
    [identityLabel.layer setBorderWidth:0.3f];
    [identityLabel setClipsToBounds:YES];
    [identityLabel setFont:[UIFont systemFontOfSize:12.f]];
    [identityLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:255/255 alpha:0.9]];
    
    [view addSubview:identityLabel];
    
    UILabel *phoneLablel = [[UILabel alloc] initWithFrame:CGRectMake(80, 40, 100, 20)];
    [phoneLablel setTextAlignment:NSTextAlignmentLeft];
    [phoneLablel setTextColor:[UIColor grayColor]];
    [phoneLablel setText:subTitle];
    [phoneLablel setFont:[UIFont systemFontOfSize:13.f]];
    
    [view addSubview:phoneLablel];
    
    return view;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView == deleteAlert) {
        if (buttonIndex == 0) {
            
            NSDictionary *tempDict =  [messageArray objectAtIndex:alertView.tag];
            NSLog(@"tempDict : %@",tempDict);
            
            NSString *delete_id = [tempDict objectForKey:@"user_id"];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            manager.requestSerializer=[AFJSONRequestSerializer serializer];
            
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
            
            
            NSDictionary *parameters = @{
                                         @"user_id":user_id,
                                         @"shouhuan_id":shouhuan_id,
                                         @"delete_id":delete_id
                                         };
            
            NSLog(@"parammeters : %@",parameters);
            
            NSString *url=@"http://101.201.211.114:8080/APIPlatform/addrelation";
            
            [manager DELETE:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"SUCCESS JSON: %@", responseObject);
                NSDictionary *dict = (NSDictionary *)responseObject;
                
                NSString *code = [dict objectForKey:@"code"];
                
                
                if ([code isEqualToString:@"100"]) {
                    
                    NSLog(@"success");
                    
                    [messageArray removeObjectAtIndex:alertView.tag];
                    [tabView reloadData];
                    
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error);
            }];

        }
        return;
    }
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *relation = textField.text ;
        
        UILabel *label = [nameLabelArray objectAtIndex:alertView.tag];
        label.text = relation;
        
        NSString *set_id = [[messageArray objectAtIndex:alertView.tag] objectForKey:@"user_id"];
        
        NSLog(@"set_id %@",set_id);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
        
        
        NSDictionary *parameters = @{
                                     @"value":relation,
                                     @"which":@"relation",
                                     @"user_id":user_id,
                                     @"shouhuan_id":shouhuan_id,
                                     @"set_id":set_id
                                     };
        
        NSLog(@"parammeters : %@",parameters);
        
        NSString *url=@"http://101.201.211.114:8080/APIPlatform/addrelation";
        
        [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"SUCCESS JSON: %@", responseObject);
            NSDictionary *dict = (NSDictionary *)responseObject;
            
            NSString *code = [dict objectForKey:@"code"];
            
            
            if ([code isEqualToString:@"100"]) {
                
                NSLog(@"success");
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
        
    }
}

- (void)changeRelation:(UIButton *)btn{
    NSLog(@"changeRelation");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入关系" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert setTag:btn.tag];
    [alert show];
}

- (void)solveApplication:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"同意"]) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
        
        NSString *set_id = [[applyArray objectAtIndex:sender.tag] objectForKey:@"user_id"];

        
        
        NSDictionary *parameters = @{
                                     @"value":[NSNumber numberWithInt:9],
                                     @"which":@"power",
                                     @"user_id":user_id,
                                     @"shouhuan_id":shouhuan_id,
                                     @"set_id":set_id
                                     };
        
        NSLog(@"parammeters : %@",parameters);
        
        NSString *url=@"http://101.201.211.114:8080/APIPlatform/addrelation";
        
        [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"SUCCESS JSON: %@", responseObject);
            NSDictionary *dict = (NSDictionary *)responseObject;
            
            NSString *code = [dict objectForKey:@"code"];
            
            
            if ([code isEqualToString:@"100"]) {
                
                NSLog(@"success");
                
                [messageArray addObject:[applyArray objectAtIndex:sender.tag]];

                [applyArray removeObjectAtIndex:sender.tag];
                
                [tabView reloadData];

            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];

    }
    
    if ([sender.titleLabel.text isEqualToString:@"拒绝"]) {
        
        NSDictionary *tempDict =  [applyArray objectAtIndex:sender.tag];
        NSLog(@"tempDict : %@",tempDict);
        
        NSString *delete_id = [tempDict objectForKey:@"user_id"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
        
        
        NSDictionary *parameters = @{
                                     @"user_id":user_id,
                                     @"shouhuan_id":shouhuan_id,
                                     @"delete_id":delete_id
                                     };
        
        NSLog(@"parammeters : %@",parameters);
        
        NSString *url=@"http://101.201.211.114:8080/APIPlatform/addrelation";
        
        [manager DELETE:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"SUCCESS JSON: %@", responseObject);
            NSDictionary *dict = (NSDictionary *)responseObject;
            
            NSString *code = [dict objectForKey:@"code"];
            
            
            if ([code isEqualToString:@"100"]) {
                
                NSLog(@"success");
                
                [applyArray removeObjectAtIndex:sender.tag];
                
                [tabView reloadData];
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];

    }

}
@end
