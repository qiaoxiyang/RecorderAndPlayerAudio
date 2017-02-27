//
//  SpectrumView.h
//  录音和语音播放
//
//  Created by xiyang on 2017/2/22.
//  Copyright © 2017年 xiyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYSpectrumView : UIView


@property (nonatomic, copy) void(^itemLevelCallback)();

/**
 条数
 */
@property (nonatomic, assign) NSInteger numberOfItems;

@property (nonatomic, retain) UIColor *itemColor;

@property (nonatomic, assign) CGFloat level;

@property (nonatomic, retain) UILabel *timeLabel;

@property (nonatomic, retain) NSString *text;


@end
