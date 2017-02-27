//
//  XYRecordPlayerManager.h
//  录音和语音播放
//
//  Created by xiyang on 2017/2/23.
//  Copyright © 2017年 xiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol XYRecordPlayerDelegate <NSObject>

-(void)audioPlayerFinished:(AVAudioPlayer *)player successfully:(BOOL)flag;


@end

@interface XYRecordPlayerManager : NSObject

/**
 音频时间
 */
@property (nonatomic, assign,readonly) NSInteger duration;


@property (nonatomic, assign) id <XYRecordPlayerDelegate> delegate;

+(instancetype)sharedRecordPlayerManager;




/**
 播放音频

 @param filePath 音频路径
 */
-(void)playVoiceWithPath:(NSString *)filePath;


/**
 播放网络语音

 @param url 网络语音url
 */
-(void)playAudioWithURL:(NSURL *)url;


/**
 播放语音
 */
-(void)play;

/**
 是否正在播放
 */
-(BOOL)isPlaying;

/**
 停止播放
 */
-(void)stop;

@end
