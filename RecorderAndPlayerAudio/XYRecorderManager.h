//
//  XYRecorderManager.h
//  录音和语音播放
//
//  Created by xiyang on 2017/2/23.
//  Copyright © 2017年 xiyang. All rights reserved.
//


/*
    还缺少总共录音时间限制功能
 */


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef  void (^callBackBlock)(BOOL success);

@interface XYRecorderManager : NSObject

+(instancetype)sharedRecorderManager;


@property (nonatomic, retain) AVAudioRecorder *audioRecorder;

/**
 存放录音位置
 */
@property (nonatomic, retain) NSURL *filePathURL;


/**
 录制音频最大时间
 */
@property (nonatomic, assign) NSInteger maxRecordTime;

/**
 录音完成时间
 */
@property (nonatomic, assign,readonly) NSInteger finishTime;

/**
 是否正在录音
 */
@property (nonatomic, assign,readonly) BOOL isRecording;


/**
 录制成功回调
 */
@property (nonatomic, copy) void (^recorderFinished)(BOOL success, NSError *error, NSString *filePath);

/**
 更新当前录音时间
 */
@property (nonatomic, copy) void (^updateRecordingTime)(NSString *curTime);


/**
 开始录音

 @param block 开始录音是否成功
 */
-(void)startRecord:(callBackBlock)block;


/**
 暂停录音

 @param block 暂停录音是否成功
 */
-(void)pauseRecord:(callBackBlock)block;


/**
 继续录音

 @param block 继续录音是否成功
 */
-(void)goonRecord:(callBackBlock)block;


/**
 取消录音

 @param block 取消录音是否成功
 */
-(void)cancelRecord:(callBackBlock)block;


/**
 终止录音

 @param block 终止录音是否成功
 */
-(void)finishRecord:(callBackBlock)block;






@end
