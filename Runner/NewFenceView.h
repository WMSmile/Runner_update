//
//  NewFenceView.h
//  爱之心
//
//  Created by 于恩聪 on 15/9/8.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASValueTrackingSlider.h"
#import "Fence.h"
@interface NewFenceView : UIViewController

@property (strong, nonatomic) ASValueTrackingSlider *slider;

@property (strong,nonatomic) Fence *fence;
@property (strong,nonatomic) NSMutableArray *fencesArray;

@end
