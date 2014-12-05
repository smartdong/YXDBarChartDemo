//
//  YXDBarChart.m
//
//  Created by dd.
//  Copyright (c) 2014年 Yang Xudong. All rights reserved.
//

//动画时间
static float ANIMATION_DURATION     = 0.25;

//bar之间的间隙与bar宽度的比例
static float BAR_SPACE_WIDTH_SCALE  = 0.6;

//线、标签默认颜色
#define DEFAULT_LINE_TEXT_COLOR     [UIColor colorWithRed:88/255. green:88/255. blue:88/255. alpha:1]

//bar默认颜色
#define DEFAULT_BAR_COLOR           [UIColor colorWithRed:80/255. green:131/255. blue:189/255. alpha:1]



#import "YXDBarChart.h"
#import "YXDDataModel.h"

@interface YXDBarChart ()
{
    int                 __columnNumber;         //数据个数
    NSMutableArray      *__arr_dataArray;       //数据数组
    int                 __lineNumber;           //数值行数量
    float               __lineDifferenceValue;  //行之间的差值
    int                 __startLineValue;       //第一条数据行的数值
    int                 __benchmarkLineIndex;   //基准行位置
    
    UIColor             *__maxValueBarColor;    //最大值对应的颜色
    UIColor             *__minValueBarColor;    //最小值对应的颜色

    
    BOOL                __isSetAnimationDuration;//是否设置动画时间
    BOOL                __isSetBarSpaceWidthScale;//是否设置了宽度比例

    CGPoint             __chartOrginPoint;      //线和bar开始计算位置的原点 (实际尺寸开始计算的左下角)
    CGSize              __chartSize;            //表格实际的尺寸 （去除左侧标签 上下边距等）
    
    float               __benchmarkValue;       //基准行对应的值
    float               __rowHeight;            //每两行之间的高度差
    float               __columnWidth;          //bar宽度
    float               __columnSpace;          //bar之间的间隙
    
    NSMutableArray      *__arr_barButtonArray;  //bar数组
    NSMutableArray      *__arr_barFrameArray;   //bar frame数组
    
    NSArray             *__arr_maxValueIndexes; //最大值所在的列
    NSArray             *__arr_minValueIndexes; //最小值所在的列
}


@end


@implementation YXDBarChart

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
                        delegate:(id<YXDBarChartDelegate>)delegate {
    
    YXDBarChart *barChart   = [[YXDBarChart alloc] initWithFrame:frame];
    barChart.dataSource     = datasource;
    barChart.delegate       = delegate;
    
    return barChart;
}

/**
 *  刷新表格 重新展示数据
 *
 *  @param animated 是否显示动画效果
 *  @param delay    延迟显示时间
 */
- (void) chartReloadDataWithAnimated:(BOOL)animated
                               delay:(float)delay
                          completion:(CompletionBlock)completionBlock {
    
    if (delay < 0) {
        delay = 0;
    }
    
    //加载数据
    [self action_reloadData];
    
    //执行动画
    if (animated) {
        
        //先清除bar
        [self action_clearColumnsBar];
        
        [UIView animateWithDuration:__isSetAnimationDuration?_animationDuration:ANIMATION_DURATION
                              delay:delay
                            options:UIViewAnimationOptionCurveLinear
                         animations:^ {
                             //执行动画
                             [self action_showColumnsBar];
                         } completion:^(BOOL finished) {
                             if (completionBlock) {
                                 completionBlock();
                             }
                         }];
    } else {
        if (completionBlock) {
            completionBlock();
        }
    }
}

/**
 *  重新加载数据
 */
- (void) action_reloadData {
    
    //清除之前的控件
    [self action_clearChart];
    
    //初始化数据
    [self action_dataInit];
    
    //绘制控件
    [self action_draw];
}

/**
 *  初始化数据
 */
- (void) action_dataInit {
    
    __columnNumber          = (int)[_dataSource numbersOfColumnForBarChart:self];
    __lineNumber            = (int)[_dataSource numbersOfLineForBarChart:self];
    __lineDifferenceValue   = [_dataSource differenceValueBetweenLinesForBarChart:self];
    __startLineValue        = (int)[_dataSource startLineValueForBarChart:self];
    __benchmarkLineIndex    = (int)[_dataSource benchmarkLineIndexForBarChart:self];
    __rowHeight             = self.frame.size.height / (__lineNumber + 2);
    __columnWidth           = self.frame.size.width / ((__columnNumber + 1) * (1 + (__isSetBarSpaceWidthScale?_barSpaceWidthScale:BAR_SPACE_WIDTH_SCALE)));
    __columnSpace           = __columnWidth * (__isSetBarSpaceWidthScale?_barSpaceWidthScale:BAR_SPACE_WIDTH_SCALE);
    __chartSize             = CGSizeMake((__columnWidth + __columnSpace) * __columnNumber, (__lineNumber - 1) * __rowHeight);
    __chartOrginPoint       = CGPointMake((__columnWidth + __columnSpace), (self.frame.size.height - __rowHeight));
    __benchmarkValue        = __startLineValue + __benchmarkLineIndex * __lineDifferenceValue;
    
    __arr_dataArray         = [NSMutableArray array];
    for (int i = 0; i < __columnNumber; i++) {
        [__arr_dataArray addObject:[_dataSource barChart:self columnDataForIndex:i]];
    }
    
    if ([_dataSource respondsToSelector:@selector(maxValueBarColorForBarChart:)]) {
        __maxValueBarColor  = [_dataSource maxValueBarColorForBarChart:self];
    }
    
    if ([_dataSource respondsToSelector:@selector(minValueBarColorForBarChart:)]) {
        __minValueBarColor  = [_dataSource minValueBarColorForBarChart:self];
    }
    
    NSMutableArray *arr_valueArray = [NSMutableArray array];
    for (YXDDataModel *dataModel in __arr_dataArray) {
        [arr_valueArray addObject:@(dataModel.value)];
    }
    
    __arr_maxValueIndexes = [self action_indexesForBiggest:YES array:arr_valueArray];
    __arr_minValueIndexes = [self action_indexesForBiggest:NO array:arr_valueArray];
}

/**
 *  绘制控件
 */
- (void) action_draw {
    
    //绘制标题
    if (self.title.length) {
        UILabel *titleLable         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, __rowHeight)];
        titleLable.center           = CGPointMake(self.frame.size.width/2, __rowHeight);
        titleLable.textAlignment    = NSTextAlignmentCenter;
        titleLable.text             = self.title;
        titleLable.textColor        = _titleColor?:DEFAULT_LINE_TEXT_COLOR;
        titleLable.font             = _titleFont?:[UIFont systemFontOfSize:16];
        titleLable.backgroundColor  = [UIColor clearColor];
        [self addSubview:titleLable];
    }
    
    //绘制线
    for (int i = 0; i < __lineNumber; i++) {
        UIView *line            = [[UIView alloc] initWithFrame:CGRectMake(__chartOrginPoint.x, (__chartOrginPoint.y - (i * __rowHeight)), __chartSize.width, 1)];
        line.backgroundColor    = _lineColor?:DEFAULT_LINE_TEXT_COLOR;
        [self addSubview:line];
    }
    
    //绘制数值标签
    for (int i = 0; i < __lineNumber; i++) {
        UILabel *lable          = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (__columnWidth + __columnSpace) * 0.6, __rowHeight)];
        lable.font              = _rowLableFont?:[UIFont systemFontOfSize:12];
        lable.textColor         = _rowLableColor?:DEFAULT_LINE_TEXT_COLOR;
        lable.textAlignment     = NSTextAlignmentRight;
        lable.center            = CGPointMake(__chartOrginPoint.x/2,(__chartOrginPoint.y - (i * __rowHeight)));
        lable.text              = [NSString stringWithFormat:@"%d",(int)(__startLineValue + i * __lineDifferenceValue)];
        lable.backgroundColor   = [UIColor clearColor];
        [self addSubview:lable];
    }
    
    //绘制bar
    __arr_barButtonArray        = [NSMutableArray array];
    __arr_barFrameArray         = [NSMutableArray array];
    
    for (int i = 0; i < __columnNumber; i++) {
        
        float buttonHeight = (((YXDDataModel *)__arr_dataArray[i]).value - __benchmarkValue) / __lineDifferenceValue * __rowHeight;
        
        CGRect buttonFrame = CGRectMake((__chartOrginPoint.x + (__columnSpace * 0.5) + ((__columnWidth + __columnSpace) * i)),(__chartOrginPoint.y - (__benchmarkLineIndex * __rowHeight)) - ((buttonHeight > 0)?buttonHeight:0), __columnWidth, fabsf(buttonHeight));
        
        UIButton *bar = [UIButton buttonWithType:UIButtonTypeCustom];
        bar.frame = buttonFrame;
        bar.backgroundColor = _barColor?:DEFAULT_BAR_COLOR;
        [bar addTarget:self action:@selector(action_barTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bar];
        
        [__arr_barButtonArray addObject:bar];
        [__arr_barFrameArray addObject:NSStringFromCGRect(buttonFrame)];
    }
    
    if (__maxValueBarColor) {
        for (NSNumber *number in __arr_maxValueIndexes) {
            ((UIButton *)__arr_barButtonArray[[number intValue]]).backgroundColor = __maxValueBarColor;
        }
    }
    
    if (__minValueBarColor) {
        for (NSNumber *number in __arr_minValueIndexes) {
            ((UIButton *)__arr_barButtonArray[[number intValue]]).backgroundColor = __minValueBarColor;
        }
    }
    
    //绘制bar下面的lable
    for (int i = 0; i < __columnNumber; i++) {
        UILabel *lable          = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (__columnWidth + __columnSpace), __rowHeight)];
        lable.font              = _columnLableFont?:[UIFont systemFontOfSize:12];
        lable.textColor         = _columnLableColor?:DEFAULT_LINE_TEXT_COLOR;
        lable.textAlignment     = NSTextAlignmentCenter;
        lable.center            = CGPointMake(((__columnWidth + __columnSpace) * (i + 0.5) + __chartOrginPoint.x),(__chartOrginPoint.y - ((__benchmarkLineIndex - 0.5) * __rowHeight)));
        lable.text              = ((YXDDataModel *)__arr_dataArray[i]).lable;
        lable.backgroundColor   = [UIColor clearColor];
        [self addSubview:lable];
    }
}

/**
 *  将各个列的bar清除
 */
- (void) action_clearColumnsBar {
    [__arr_barButtonArray enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        CGRect frame = obj.frame;
        if (frame.origin.y != (__chartOrginPoint.y - (__benchmarkLineIndex * __rowHeight))) {
            frame.origin.y += frame.size.height;
        }
        frame.size.height   = 0;
        obj.frame           = frame;
    }];
}

/**
 *  展示bar
 */
- (void) action_showColumnsBar {
    [__arr_barButtonArray enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        obj.frame = CGRectFromString(__arr_barFrameArray[idx]);
    }];
}

-(void)setAnimationDuration:(float)animationDuration {
    _animationDuration          = animationDuration;
    __isSetAnimationDuration    = YES;
}

- (void)setBarSpaceWidthScale:(float)barSpaceWidthScale {
    _barSpaceWidthScale         = barSpaceWidthScale;
    __isSetBarSpaceWidthScale   = YES;
}

#pragma mark - 点击bar产生的事件

- (void) action_barTouched:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(barChart:didSelectColumnIndex:)]) {
        [_delegate barChart:self didSelectColumnIndex:[__arr_barButtonArray indexOfObject:sender]];
    }
}

#pragma mark - 清除控件

- (void) action_clearChart {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

#pragma mark - 找出 最大/小值 所在的indexes

- (NSArray *) action_indexesForBiggest:(BOOL)isBiggest array:(NSArray *)array {
    
    //如果元素不是NSNumber 崩了活该
    
    if (!array.count) {
        return nil;
    }
    
    float mValue = [(NSNumber *)array[0] floatValue];
    
    for (int i = 0; i < array.count; i++) {
        
        float value = [(NSNumber *)array[i] floatValue];
        
        if (isBiggest) {
            if (value > mValue) {
                mValue = value;
            }
        } else {
            if (value < mValue) {
                mValue = value;
            }
        }
    }
    
    NSMutableArray *arr_indexes = [NSMutableArray array];
    
    //找到了 最 大/小 值  mValue
    
    for (int i = 0; i < array.count; i++) {
        
        if (mValue == [(NSNumber *)array[i] floatValue]) {
            [arr_indexes addObject:@(i)];
        }
    }
    
    return arr_indexes;
}

@end

