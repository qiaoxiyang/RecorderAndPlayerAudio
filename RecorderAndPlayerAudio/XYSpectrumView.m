//
//  SpectrumView.m
//  录音和语音播放
//
//  Created by xiyang on 2017/2/22.
//  Copyright © 2017年 xiyang. All rights reserved.
//

#import "XYSpectrumView.h"

@interface XYSpectrumView ()

@property (nonatomic, retain) NSMutableArray *levelArray;
@property (nonatomic, retain) NSMutableArray *itemArray;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) CGFloat itemWidth;

@end

@implementation XYSpectrumView


-(instancetype)init{
    self =[super init];
    if (self) {
        [self setup];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame ];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}


-(void)setup{
    
    self.itemArray = [NSMutableArray array];
    self.numberOfItems = 20;
    
    self.itemColor = [UIColor colorWithRed:241/255.f green:60/255.f blue:57/255.f alpha:1.0];
    
    self.itemHeight = CGRectGetHeight(self.bounds);
    self.itemWidth = CGRectGetWidth(self.bounds);
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.itemWidth*0.4, 0, self.itemWidth*0.2, self.itemHeight)];
    
    self.timeLabel.text = @"";
    [self.timeLabel setTextColor:[UIColor grayColor]];
    [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.timeLabel];
    
    self.levelArray = [NSMutableArray array];
    for (int i=0; i<self.numberOfItems/2; i++) {
        [self.levelArray addObject:@(1)];
    }
    
}

-(void)setText:(NSString *)text{
    _text = text;
    self.timeLabel.text =text;
}


-(void)setItemLevelCallback:(void (^)())itemLevelCallback{
    _itemLevelCallback = itemLevelCallback;
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:_itemLevelCallback selector:@selector(invoke)];
    //iOS设备的屏幕刷新频率(FPS)是60Hz，因此CADisplayLink的selector 默认调用周期是每秒60次，这个周期可以通过frameInterval属性设置， CADisplayLink的selector每秒调用次数=60/ frameInterval。比如当 frameInterval设为2，每秒调用就变成30次。因此， CADisplayLink 周期的设置方式略显不便。
    displaylink.frameInterval = 6;
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    for (int i=0; i<self.numberOfItems; i++) {
        
        CAShapeLayer *itemline = [CAShapeLayer layer];
        itemline.lineCap = kCALineCapButt;
        itemline.lineJoin = kCALineJoinRound;
        itemline.strokeColor = [[UIColor clearColor] CGColor];
        itemline.fillColor   = [[UIColor clearColor] CGColor];
        [itemline setLineWidth:self.itemWidth * 0.4/self.numberOfItems];
        itemline.strokeColor = [self.itemColor CGColor];
        
        [self.layer addSublayer:itemline];
        [self.itemArray addObject:itemline];
        
    }
    
    /*
     
     CADisplayLink 使用场合相对专一， 适合做界面的不停重绘，比如视频播放的时候需要不停地获取下一帧用于界面渲染。
     
     NSTimer的使用范围要广泛的多，各种需要单次或者循环定时处理的任务都可以使用。
     */
}



-(void)setLevel:(CGFloat)level{
    level = (level + 37.5)*3.2;
    if (level<0) {
        level = 0;
    }
    [self.levelArray removeObjectAtIndex:self.numberOfItems/2-1];
    [self.levelArray insertObject:@((level/6)<1?1:level/6) atIndex:0];
    [self updateItems];
    
}



-(void)updateItems{
    
    UIGraphicsBeginImageContext(self.frame.size);
    
    int x = self.itemWidth*0.8/self.numberOfItems;
    int z = self.itemWidth*0.2/self.numberOfItems;
    int y = self.itemWidth*0.6-z;
    
    for (int i=0; i<(self.numberOfItems / 2); i++) {
        UIBezierPath *itemLinePath = [UIBezierPath bezierPath];
        
        y+=x;
        
        [itemLinePath moveToPoint:CGPointMake(y, self.itemHeight/2+([[self.levelArray objectAtIndex:i] intValue]+1)*z/2)];
        [itemLinePath addLineToPoint:CGPointMake(y, self.itemHeight/2-([[self.levelArray objectAtIndex:i] intValue]+1)*z/2)];
        CAShapeLayer *itemLine = [self.itemArray objectAtIndex:i];
        itemLine.path = [itemLinePath CGPath];
    }
    
    y = self.itemWidth*0.4 + z;
    for (int i=(int)self.numberOfItems/2; i<self.numberOfItems; i++) {
        
        UIBezierPath *itemLinePath = [UIBezierPath bezierPath];
        y-=x;
        [itemLinePath moveToPoint:CGPointMake(y, self.itemHeight/2+([[self.levelArray objectAtIndex:i-self.numberOfItems/2] intValue]+1)*z/2)];
        
        [itemLinePath addLineToPoint:CGPointMake(y, self.itemHeight/2-([[self.levelArray objectAtIndex:i-self.numberOfItems/2] intValue]+1)*z/2)];
        
        CAShapeLayer *itemLine = [self.itemArray objectAtIndex:i];
        
        itemLine.path = [itemLinePath CGPath];
    }
    
    UIGraphicsEndImageContext();
    
}







@end
