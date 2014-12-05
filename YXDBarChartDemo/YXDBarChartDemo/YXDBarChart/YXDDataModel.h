//
//  YXDDataModel.h
//
//  Created by dd.
//  Copyright (c) 2014年 Yang Xudong. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  数据元素
 */
@interface YXDDataModel : NSObject

/**
 *  下方显示的标签
 */
@property (nonatomic, copy) NSString *lable;

/**
 *  具体数值
 */
@property (nonatomic, assign) float value;

/**
 *  返回数据的类方法
 *
 *  @param lable 下方显示的标签
 *  @param value 具体数值
 *
 *  @return 数据对象
 */
+ (YXDDataModel *) dataModelWithLable:(NSString *)lable andValue:(float)value;

@end
