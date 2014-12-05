//
//  YXDDataModel.m
//
//  Created by dd.
//  Copyright (c) 2014年 Yang Xudong. All rights reserved.
//

#import "YXDDataModel.h"

@implementation YXDDataModel

+(YXDDataModel *)dataModelWithLable:(NSString *)lable andValue:(float)value {
    
    YXDDataModel *dm = [YXDDataModel new];
    
    dm.lable = lable;
    dm.value = value;
    
    return dm;
}

@end
