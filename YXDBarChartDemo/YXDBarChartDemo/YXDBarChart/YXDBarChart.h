//
//  YXDBarChart.h
//
//  Created by dd.
//  Copyright (c) 2014年 Yang Xudong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(void);

@class YXDBarChart;
@class YXDDataModel;

@protocol YXDBarChartDataSource <NSObject>

@required

/**
 *  表格的数据个数
 *
 *  @param barChart 表格对象
 *
 *  @return 个数
 */
- (NSInteger) numbersOfColumnForBarChart:(YXDBarChart *)barChart;

/**
 *  每一列数据显示的对象
 *
 *  @param barChart 表格对象
 *  @param index    列数
 *
 *  @return 数据对象
 */
- (YXDDataModel *) barChart:(YXDBarChart *)barChart columnDataForIndex:(NSInteger)index;

/**
 *  数值行数量
 *
 *  @param barChart 表格对象
 *
 *  @return 数量
 */
- (NSInteger) numbersOfLineForBarChart:(YXDBarChart *)barChart;

/**
 *  两条横线之间的差值
 *
 *  @param barChart 表格对象
 *
 *  @return 差值
 */
- (NSInteger) differenceValueBetweenLinesForBarChart:(YXDBarChart *)barChart;

/**
 *  第一条横线的数值
 *
 *  @param barChart 表格对象
 *
 *  @return 数值
 */
- (NSInteger) startLineValueForBarChart:(YXDBarChart *)barChart;

/**
 *  基准线位置  每一列的标签会显示在基准线下方  如果某一列数据值小于基准列对应的值  则bar向下显示
 *
 *  @param barChart
 *
 *  @return 位置
 */
- (NSInteger) benchmarkLineIndexForBarChart:(YXDBarChart *)barChart;

@optional

/**
 *  最大值所在的bar颜色
 *
 *  @param barChart 表格对象
 *
 *  @return 颜色
 */
- (UIColor *) maxValueBarColorForBarChart:(YXDBarChart *)barChart;

/**
 *  最小值所在的bar颜色
 *
 *  @param barChart 表格对象
 *
 *  @return 颜色
 */
- (UIColor *) minValueBarColorForBarChart:(YXDBarChart *)barChart;

@end

@protocol YXDBarChartDelegate <NSObject>

/**
 *  bar被点击产生的事件
 *
 *  @param barChart 表格对象
 *  @param index    bar的位置
 */
- (void) barChart:(YXDBarChart *)barChart didSelectColumnIndex:(NSInteger)index;

@end


@interface YXDBarChart : UIView

@property (nonatomic , copy)    NSString    *title;                 //表格标题
@property (nonatomic , strong)  UIColor     *titleColor;            //标题颜色
@property (nonatomic , strong)  UIFont      *titleFont;             //标题字体
@property (nonatomic , strong)  UIColor     *columnLableColor;      //列标签颜色
@property (nonatomic , strong)  UIFont      *columnLableFont;       //列标签字体
@property (nonatomic , strong)  UIColor     *rowLableColor;         //数值标签颜色
@property (nonatomic , strong)  UIFont      *rowLableFont;          //数值标签字体
@property (nonatomic , strong)  UIColor     *lineColor;             //线颜色
@property (nonatomic , strong)  UIColor     *barColor;              //bar颜色

@property (nonatomic , assign)  float       animationDuration;      //动画时间
@property (nonatomic , assign)  float       barSpaceWidthScale;     //bar间隙宽度与bar宽度的比例

@property (nonatomic , weak) id<YXDBarChartDataSource> dataSource;
@property (nonatomic , weak) id<YXDBarChartDelegate> delegate;

/**
 *  生成表格
 *
 *  @param frame       frame
 *  @param datasource  数据源
 *  @param delegate    事件代理
 *
 *  @return 表格对象
 */
+ (YXDBarChart *) chartWithFrame:(CGRect)frame
                      dataSource:(id<YXDBarChartDataSource>)datasource
                        delegate:(id<YXDBarChartDelegate>)delegate;

/**
 *  刷新表格 重新展示数据
 *
 *  @param animated 是否显示动画效果
 *  @param delay    延迟显示时间
 *  @param completionBlock 动画结束以后执行的内容
 */
- (void) chartReloadDataWithAnimated:(BOOL)animated
                               delay:(float)delay
                          completion:(CompletionBlock)completionBlock;

@end
