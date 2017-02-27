//
//  XYRecorderManager.m
//  录音和语音播放
//
//  Created by xiyang on 2017/2/23.
//  Copyright © 2017年 xiyang. All rights reserved.
//

#import "XYRecorderManager.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ErrorAudioRecord) {
    ErrorAudioRecordDurationTooShort = -100, //录音时间太短
    ErrorAudioRecordStoping = -101,  //录音已停止
    ErrorAudioRecordNotStarted = -102, //录音未开始
};

@interface XYRecorderManager ()<AVAudioRecorderDelegate>
{
    NSInteger _finishTime;
    NSDate *_recorderStartDate;
}

@property (nonatomic, retain) NSTimer *timer;

@end

@implementation XYRecorderManager

#pragma mark - Public
+(instancetype)sharedRecorderManager{
    
    static XYRecorderManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XYRecorderManager alloc] init];
    });
    
    return manager;
}

/**
 开始录音
 
 @param block 开始录音是否成功
 */
-(void)startRecord:(callBackBlock)block{
    
    if (![self canRecord]) {
        return;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>7.0) {
        AVAudioSession *session= [AVAudioSession sharedInstance];
        NSError *sessionError;
        
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if (session == nil) {
            NSLog(@"Error creating session: %@",[sessionError description ]);
            
        }else{
            [session setActive:YES error:nil];
        }
    }
    
    if (!self.isRecording) {
        [self.audioRecorder record];
        _recorderStartDate = [NSDate date];
        _finishTime = 0; //清空当前时间
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
        block(YES);
    }else{
        block(NO);
    }
    
}


/**
 是否开启权限录音

 */
-(BOOL)canRecord{
    
    __block BOOL bCanRecord = YES;
    
    double systemVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
    if ( systemVersion>7.0)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                
                
                if (granted) {
                    bCanRecord = YES;
                }
                else {
                    bCanRecord = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:nil
                                                    message:@"农机帮需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
                                                   delegate:nil
                                          cancelButtonTitle:@"关闭"
                                          otherButtonTitles:nil] show];
                    });
                }
                
            }];
        }
    }
    return bCanRecord;
    
}




/**
 暂停录音
 
 @param block 暂停录音是否成功
 */
-(void)pauseRecord:(callBackBlock)block{
    
    if (self.isRecording) {
        [self.audioRecorder pause];
        if (self.timer) {
            //[NSDate distantFuture]无法到达的时间
            [self.timer setFireDate:[NSDate distantFuture]];
        }
        block(YES);
    }else{
        block(NO);
    }
    
}


/**
 继续录音
 
 @param block 继续录音是否成功
 */
-(void)goonRecord:(callBackBlock)block{
    
    if (!self.isRecording) {
        [self.audioRecorder record];
        if (self.timer) {
            //从当前时间开始继续
            [self.timer setFireDate:[NSDate date]];
        }
        block(YES);
    }else{
        block(NO);
    }
}

/**
 取消录音
 @param block 取消录音是否成功
 */
-(void)cancelRecord:(callBackBlock)block{
    
    if (self.isRecording) {
        
        [self.audioRecorder stop];
        [self.audioRecorder deleteRecording];
       
        [self stopTimer];
        _finishTime = 0;
        if (self.updateRecordingTime) {
            
            self.updateRecordingTime([self timeFormatter:_finishTime]);
        }
         block(YES);
    }else{
        block(NO);
    }
}
/**
 终止录音
 
 @param block 终止录音是否成功
 */
-(void)finishRecord:(callBackBlock)block{
    
    if (self.isRecording) {
        
        [self.audioRecorder stop];
        
        [self stopTimer];
        block(YES);
        
        
    }else{
        block(NO);
    }
}


#pragma mark - Private
/**
 获取录音文件设置
 
 @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //设置录音格式
    [dic setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dic setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道，这里采用单声道
    [dic setObject:@(1) forKey:AVNumberOfChannelsKey];
    
    //每个采样点位数，分8、16、24、32 默认为16
    [dic setObject:@(8) forKey:AVLinearPCMIsFloatKey];
    
    return dic;
    
}

/**
 默认文件保存路径
 */
-(NSURL *)getSavePath{
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"AudioRecorder"];
    
    NSLog(@"file path: %@",path);
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [manager fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDir&&isDirExist)) {
        BOOL bCreateDir = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!bCreateDir) {
            NSLog(@"创建文件夹失败！");
        }
        NSLog(@"创建文件夹成功，文件路径%@",path);
    }
    
    path = [path stringByAppendingPathComponent:@"myRecord.aac"];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
    
}

-(NSString *)timeFormatter:(NSInteger)time{
    int seconds = time%60;
    int minutes = time/60;
    
    NSString *timeStr = [NSString stringWithFormat:@"%01d:%02d",minutes,seconds];
    
    return timeStr;
};

#pragma mark - TimerSelector
//更新时间
-(void)updateCurrentTime{
    
    _finishTime = [[NSDate date] timeIntervalSinceDate:_recorderStartDate];
    if (self.updateRecordingTime) {
        
        self.updateRecordingTime([self timeFormatter:_finishTime]);
    }

}

//终止时钟
-(void)stopTimer{
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    if (flag) {
        //若终止时间小于1秒，则录音失败
        NSDate *endDate = [NSDate date];
        if ([endDate timeIntervalSinceDate:_recorderStartDate]<1.0) {
            NSLog(@"录音时间较短。");
            NSError *error = [NSError errorWithDomain:@"录音时间较短。" code:ErrorAudioRecordDurationTooShort userInfo:nil];
            
            if (self.recorderFinished){
                self.recorderFinished(YES,error,nil);
            }
            return;
        }
        
        if (self.recorderFinished){
            self.recorderFinished(YES,nil,recorder.url.path);
        }
    }
    
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    
    NSLog(@"录音发生错误，错误详情:%@",error.localizedDescription);
    if (self.recorderFinished) {
        self.recorderFinished(NO, error, nil);
    }
}

#pragma mark - Getter
- (AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder) {
        
        //创建录音文件保存路径
        NSURL *url;
        if (self.filePathURL) {
            url = self.filePathURL;
        }else{
            url = [self getSavePath];
        }
  
        //创建录音配置
        NSDictionary *setting = [self getAudioSetting];
        //创建录音及
        NSError *error  = nil;
        
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES; //如果要监控声波则必须设置为yes
        [_audioRecorder prepareToRecord];
        if (error) {
            
            NSLog(@"创建录音机对像时发生错误，错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

-(BOOL)isRecording{
    
    return  [self.audioRecorder isRecording];
}

@end
