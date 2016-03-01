//
//  ModeChoiceViewController.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/7.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "ModeChoiceViewController.h"
#import "Constant.h"
#import "IQActionSheetPickerView.h"

@interface ModeChoiceViewController()<UITableViewDataSource,UITableViewDelegate,IQActionSheetPickerViewDelegate>

{
    UIImageView *selectedView;
    UIView *customView;
    
    UITableView *listView;
    NSArray *dataSource;
    
    NSInteger numbers;
    
    IQActionSheetPickerView *picker;
    
    UIButton *selectedButton;
    
    NSString *paramater;
}

@end


@implementation ModeChoiceViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self initSelectedView];
    
    [self initDatePicker];
    numbers = 0;
}

- (void)initDatePicker{
    picker = [[IQActionSheetPickerView alloc] initWithTitle:@"选择时间" delegate:self];
    [picker setTag:8];
    [picker setActionSheetPickerStyle:IQActionSheetPickerStyleTimePicker];

}

- (void)initSelectedView{
    selectedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected"]];
    [selectedView setFrame:CGRectMake(SCREEN_WIDTH - 32, 7, 26, 26)];
    [selectedView setClipsToBounds:YES];
}

- (void)initTableView{
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    
    listView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [listView setFrame:CGRectMake(6, 10, SCREEN_WIDTH - 12, SCREEN_HEIGHT - 30)];
    
    [listView setBackgroundColor:[UIColor blackColor]];
    
    listView.delegate = self;
    listView.dataSource = self;
    
    listView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    listView.showsVerticalScrollIndicator = NO;
    listView.backgroundColor = DEFAULT_BACKGOUNDCOLOR;
    listView.delaysContentTouches = NO;

    [self.view addSubview:listView];
    
    dataSource = [NSArray arrayWithObjects:@"跟随模式:(约1分钟定位一次)",@"标准模式:(约10分钟定位一次)",@"省电模式:(约30分钟定位一次)", @"自定义模式",nil];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 5;
    }
    if (section == 1) {
        return numbers;
    }
    if (section == 2) {
        return 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CMainCell = @"CMainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: CMainCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }
    //section 1
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH  - 12, 50)];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setText:@"定位模式"];
            [label setTextColor:[UIColor blackColor]];
            
            [label setUserInteractionEnabled:YES];
            
            [cell addSubview:label];
        }
        if ([indexPath row] != 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 40, 50)];
            [label setTextAlignment:NSTextAlignmentLeft];
            [label setText:[dataSource objectAtIndex:[indexPath row] - 1]];
            [label setTextColor:[UIColor blackColor]];
            [label setFont:[UIFont systemFontOfSize:15.f]];
            
            [cell addSubview:label];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
    }
    //section 2
    if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 12, 50)];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setText:@"自定义模式设置"];
            [label setTextColor:[UIColor blackColor]];
            [label setFont:[UIFont systemFontOfSize:15.f]];
            
            [cell addSubview:label];
        }
        if ([indexPath row] != 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2 - 6, 40)];
            
            
            [label setTextColor:[UIColor blackColor]];
            [label setText:@":"];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setUserInteractionEnabled:YES];
            //开始时间
            UIButton *startTime = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 4 - 4, 40)];
            [startTime setTitle:@"00:00" forState:UIControlStateNormal];
            [startTime setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [startTime.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [startTime setUserInteractionEnabled:YES];
            //结束时间
            UIButton *endTime = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 4 - 2, 0 , SCREEN_WIDTH / 4 - 4, 40)];
            [endTime setTitle:@"00:00" forState:UIControlStateNormal];
            [endTime setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [endTime.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            [label addSubview:startTime];
            [label addSubview:endTime];
            //定位模式
            UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 6, 0, SCREEN_WIDTH / 4 - 3, 40)];
            [secondLabel setText:@"定位模式 :"];
            [secondLabel setTextAlignment:NSTextAlignmentRight];
            [secondLabel setTextColor:[UIColor blackColor]];
            
            [cell addSubview:secondLabel];
            
            //定位模式 详细
            
            UIButton *modeButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH / 4 - 3) * 3, 0, SCREEN_WIDTH / 4 - 3, 40)];
            [modeButton setTitle:@"跟随模式" forState:UIControlStateNormal];
            [modeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [modeButton.titleLabel setTextAlignment:NSTextAlignmentLeft ];

            [cell addSubview:modeButton];
            
            
            [startTime.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
            [endTime.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
            [secondLabel setFont:[UIFont systemFontOfSize:15.f]];
            [modeButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
            
            [startTime addTarget:self action:@selector(showTimeChoose:) forControlEvents:UIControlEventTouchUpInside];
            [endTime addTarget:self action:@selector(showTimeChoose:) forControlEvents:UIControlEventTouchUpInside];
            [modeButton addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell addSubview:label];
        }
    }
    
    //section 3
    if ([indexPath section] == 2) {
        NSLog(@"section 3");
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 12, 50)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:@"确认修改"];
        [label setTextColor:[UIColor blackColor]];
        
        [cell addSubview:label];
    }
    
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell.textLabel setFont:[UIFont systemFontOfSize:15.f]];
    [cell setClipsToBounds:YES];
    
    
    [cell.layer setBorderColor:[UIColor grayColor].CGColor];
    [cell.layer setBorderWidth:0.3f];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row] < 4 && [indexPath section] == 0) {
        paramater = [NSString stringWithFormat:@"%d",[indexPath row] - 1];
        
        NSLog(@"%@",paramater);
    }
    
    if ([indexPath row] == 4 && [indexPath section] == 0) {
        numbers = 8;
        [listView reloadData];
    }
    if ([indexPath section] == 0 && [indexPath row] != 4) {
        if (numbers == 8) {
            numbers = 0;
            [listView reloadData];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row] == 0 && [indexPath section] == 2) {
        return 40;
    }
    if ([indexPath row] == 0) {
        return 50;
    }
    return 40;
}


//picker

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    formatter.dateFormat = @"HH:mm";
    [selectedButton setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];
    [selectedButton setTitleColor:DEFAULTCOLOR forState:UIControlStateNormal];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}



//点击事件

- (void)showTimeChoose:(UIButton *)sender{
    NSLog(@"showTimeChoose");
    selectedButton = sender;
    [picker show];
}

- (void)changeMode:(UIButton *)sender{
    NSLog(@"sender.text : %@",sender.titleLabel.text);
    
    if ([sender.titleLabel.text isEqualToString:@"跟随模式"]) {
        [sender setTitle:@"标准模式" forState:UIControlStateNormal];
        [sender setTitleColor:DEFAULTCOLOR forState:UIControlStateNormal];
        return;
    }
    if ([sender.titleLabel.text isEqualToString:@"标准模式"]) {
        [sender setTitle:@"省电模式" forState:UIControlStateNormal];
        [sender setTitleColor:DEFAULTCOLOR forState:UIControlStateNormal];
        return;
    }
    if ([sender.titleLabel.text isEqualToString:@"省电模式"]) {
        [sender setTitle:@"跟随模式" forState:UIControlStateNormal];
        [sender setTitleColor:DEFAULTCOLOR forState:UIControlStateNormal];
        return;
    }
}


@end
