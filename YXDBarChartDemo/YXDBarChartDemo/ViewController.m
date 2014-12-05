//
//  ViewController.m
//  YXDBarChartDemo
//
//  Created by dd on 14/12/2.
//  Copyright (c) 2014年 Ice-Soft. All rights reserved.
//

#import "ViewController.h"
#import "YXDDataModel.h"
#import "YXDBarChart.h"

#define mScreenWidth            ([UIScreen mainScreen].bounds.size.width)
#define mScreenHeight           ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()<YXDBarChartDataSource,YXDBarChartDelegate>

@property (nonatomic , strong) YXDBarChart *barChart;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.barChart = [YXDBarChart chartWithFrame:CGRectMake(8, 50, mScreenWidth-20, 200) dataSource:self delegate:self];
    [self.view addSubview:self.barChart];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self action_refreshData];
}

- (IBAction)action_refreshData {
    [self.barChart chartReloadDataWithAnimated:YES delay:0.5 completion:nil];
}


- (NSInteger) numbersOfColumnForBarChart:(YXDBarChart *)barChart {
    return 9;
}

- (YXDDataModel *) barChart:(YXDBarChart *)barChart columnDataForIndex:(NSInteger)index {
    return [YXDDataModel dataModelWithLable:[NSString stringWithFormat:@"%d",index] andValue:arc4random()%30];
}

- (NSInteger) numbersOfLineForBarChart:(YXDBarChart *)barChart {
    return 8;
}

- (NSInteger) differenceValueBetweenLinesForBarChart:(YXDBarChart *)barChart {
    return 5;
}

- (NSInteger) startLineValueForBarChart:(YXDBarChart *)barChart {
    return -5;
}

- (NSInteger) benchmarkLineIndexForBarChart:(YXDBarChart *)barChart {
    return 1;
}

- (UIColor *) maxValueBarColorForBarChart:(YXDBarChart *)barChart {
    return [UIColor greenColor];
}

- (UIColor *) minValueBarColorForBarChart:(YXDBarChart *)barChart {
    return [UIColor redColor];
}

-(void)barChart:(YXDBarChart *)barChart didSelectColumnIndex:(NSInteger)index {
    NSLog(@"%@ : %d",NSStringFromSelector(_cmd),index);
}

@end
