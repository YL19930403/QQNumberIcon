//
//  BadgeViewButton.m
//  QQNumberIcon
//
//  Created by 余亮 on 16/2/21.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import "BadgeViewButton.h"
#import "UIView+Extension.h"

@interface BadgeViewButton ()

@property(nonatomic,weak) UIView * smallCircleView ;

@property(nonatomic,weak) CAShapeLayer * shapeLayer ;


@end

@implementation BadgeViewButton

#pragma mark - 懒加载
- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        CAShapeLayer * shapeLayer = [CAShapeLayer layer];
        shapeLayer.fillColor = [UIColor redColor].CGColor;
        [self.superview.layer insertSublayer:shapeLayer atIndex:0];
        _shapeLayer = shapeLayer;
    }
    return _shapeLayer ;
}


- (void)awakeFromNib
{
    [self setUp];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

//初始化
- (void) setUp
{
    CGFloat width = self.width ;
    //设置圆角
    self.layer.cornerRadius = width * 0.5 ;
    self.layer.masksToBounds = YES ;
    
    //设置字体
    [self.titleLabel setFont:[UIFont systemFontOfSize:13]] ;
    //设置字体颜色
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //添加手势
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
    
    // 添加小圆,颜色一样,圆角半径,尺寸
    // 如果一个类想使用copy,必须要遵守NSCopying
    UIView *smallCircleView = [self copy];

    //把小圆点添加到badgeViewButton父控件上
    [self.superview insertSubview:smallCircleView belowSubview:self];
    
}

- (void) panAction:(UIPanGestureRecognizer *)pan
{
  //获取手指的偏移量
    CGPoint offSetP = [pan translationInView:self];
    // 设置形变
    // 修改形变不会修改center
    CGPoint center = self.center ;
    center.x += offSetP.x ;
    center.y += offSetP.y ;
    self.center = center ;
    
    //复位
    [pan  setTranslation:CGPointZero inView:self];
    
    //计算两个圆的圆心距离
    CGFloat centerDistance = [self distanceWithSmallCircleView:_smallCircleView bigCircleView:self];
    
    //计算小圆的半径
    CGFloat smallRadius = self.bounds.size.width *0.5 -  centerDistance/ 10.0 ;
    
    //给小圆赋值
    _smallCircleView.bounds = CGRectMake(0, 0, smallRadius*2, smallRadius*2);
    _smallCircleView.layer.cornerRadius = smallRadius ;
    
    //设置不规则的矩形路径
    if (_smallCircleView.hidden == NO ) {   // 小圆显示的时候才需要描述不规则矩形
        self.shapeLayer.path = [self pathWithSmallCircleView:_smallCircleView bigCircleView:self].CGPath ;
        
    }
    
     // 拖动的时候判断下圆心距离是否大于60
    if (centerDistance > 60) {
          //隐藏小圆
        _smallCircleView.hidden = YES ;
        // 从父层中移除,就有吸附效果
        [self.shapeLayer removeFromSuperlayer];
        
    }
    
    // 手指抬起的业务逻辑
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (centerDistance > 60) {
             //播放gif动画
            UIImageView * imageV = [[UIImageView alloc] initWithFrame:self.bounds];
            NSMutableArray * mutArrs = [NSMutableArray array];
            if (_images == nil) {
                for (int i=1 ; i<=8; i++) {
                    NSString * imageName = [NSString stringWithFormat:@"%d",i];
                    UIImage * image = [UIImage imageNamed:imageName];
                    [mutArrs addObject:image];
                }
            }else{
                mutArrs = _images ;
            }
            imageV.animationImages =  mutArrs ;
            imageV.animationDuration = 1.0 ;
            [imageV startAnimating];
            [self addSubview:imageV];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });
        }else{   // 两个圆心距离没有超过范围
            //弹簧效果
            [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
                // badgeView还原到之前的位置,设置中心点为原来位置
                self.center = _smallCircleView.center ;
            } completion:^(BOOL finished) {
                
            }];
            //小圆重新显示
            _smallCircleView.hidden = NO ;
            // 不规则的矩形形状也需要移除
            [self.shapeLayer removeFromSuperlayer];
        }
    }
}

//只要调用copy就会调用该方法
- (id) copyWithZone:(NSZone *)zone
{
    UIView * smallCircleView = [[UIView alloc] initWithFrame:self.frame];
    smallCircleView.backgroundColor = self.backgroundColor ;
    smallCircleView.layer.cornerRadius = self.layer.cornerRadius ;
    smallCircleView.layer.masksToBounds = YES ;
    _smallCircleView = smallCircleView ;
    return _smallCircleView ;
}


//获取两个控件之间的圆心距离
- (CGFloat) distanceWithSmallCircleView:(UIView *)smallCircleView bigCircleView:(UIView *)bigCircle
{
    //获取x轴偏移量
    CGFloat offsetX = bigCircle.center.x - smallCircleView.center.x ;
    
     //获取y轴偏移量
    CGFloat offsetY = bigCircle.center.y - smallCircleView.center.y ;
    
    //获取两个圆心的距离
    CGFloat distance = sqrtf((offsetX * offsetX + offsetY * offsetY));
    
    return distance ;
}


// 根据两个控件描述不规则的路径
- (UIBezierPath *)pathWithSmallCircleView:(UIView *)smallCircleView  bigCircleView:(UIView *)bigCircleView
{
    // 小圆,x1,y1,r1
    CGFloat x1 = smallCircleView.center.x;
    CGFloat y1 = smallCircleView.center.y;
    CGFloat r1 = smallCircleView.bounds.size.width * 0.5;
    
    // 大圆,x2,y2,r2
    CGFloat x2 = bigCircleView.center.x;
    CGFloat y2 = bigCircleView.center.y;
    CGFloat r2 = bigCircleView.bounds.size.width * 0.5;
    
    // 计算两个圆心距离
    CGFloat d = [self distanceWithSmallCircleView:smallCircleView bigCircleView:bigCircleView];
    
    if (d <= 0)  return nil;
    
    // cosθ
    CGFloat cosθ = (y2 - y1) / d;
    
    // sinθ
    CGFloat sinθ = (x2 - x1) / d;
    
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ, y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ, y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ, y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ, y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d * 0.5 * sinθ, pointA.y + d * 0.5 * cosθ);
    CGPoint pointP = CGPointMake(pointB.x + d * 0.5 * sinθ, pointB.y + d * 0.5 * cosθ);
    
    // 描述路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 设置起点
    [path moveToPoint:pointA];
    
    // AB
    [path addLineToPoint:pointB];
    
    // BC
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    
    // CD
    [path addLineToPoint:pointD];
    
    // DA
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}

//取消按钮高亮状态系统的内部操作
- (void) setHighlighted:(BOOL)highlighted
{

}
@end



























