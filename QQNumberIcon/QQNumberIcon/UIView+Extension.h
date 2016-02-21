//
//  UIView+Extension.h
//  QQNumberIcon
//
//  Created by 余亮 on 16/2/21.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)


// @property在分类中功能只是帮你生成get,set方法的声明,不会帮你生成get,set方法的实现和下划线成员属性
@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat x;

@property (nonatomic, assign) CGFloat y;

@property (nonatomic, assign) CGFloat height;

@end
