//
//  XYRecordPlayerManager.m
//  录音和语音播放
//
//  Created by xiyang on 2017/2/23.
//  Copyright © 2017年 xiyang. All rights reserved.
//

#import "XYRecordPlayerManager.h"
#import "EMVoiceConverter.h"
@interface XYRecordPlayerManager ()<AVAudioPlayerDelegate>
{
    NSInteger _duration;
}
@property (nonatomic, retain) AVAudioPlayer *player;

@end

@implementation XYRecordPlayerManager

+(instancetype)sharedRecordPlayerManager{
    
    static XYRecordPlayerManager *manager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[XYRecordPlayerManager alloc] init];
    });
    
    return manager;
}


-(void)playVoiceWithPath:(NSString *)filePath{
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.delegate = self;
    [self.player prepareToPlay];
    _duration = [self getVoiceDuration:url];
    
}


-(NSInteger)getVoiceDuration:(NSURL *)fileURL{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    CMTime duration = asset.duration;
    NSInteger seconds = CMTimeGetSeconds(duration);

    return seconds;
}

-(void)playAudioWithURL:(NSURL *)url{
    
    if ([url.absoluteString hasPrefix:@"http://"]||[url.absoluteString hasPrefix:@"https://"]) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        
        NSArray *pathArr = [url.absoluteString componentsSeparatedByString:@"/"];
        NSString *wavPath = [NSString stringWithFormat:@"%@/%@.wav",docDirPath,pathArr.lastObject];
        
        if (![fileManager fileExistsAtPath:wavPath]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               
                NSData *audioData = [NSData dataWithContentsOfURL:url];
                NSString *filePath = [NSString stringWithFormat:@"%@/%@.acc",docDirPath,@"temp"];
                [audioData writeToFile:filePath atomically:YES];
                //转格式
                [EMVoiceConverter amrToWav:filePath wavSavePath:wavPath];
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                
                [self playVoiceWithPath:wavPath];
            });
            
        }
        
        
        
    }
    
    
    
}


-(void)play{
    
    [self.player play];
}

-(BOOL)isPlaying{
    
    return [self.player isPlaying];
}

-(void)stop{
    
    [self.player stop];
    
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    if ([self.delegate respondsToSelector:@selector(audioPlayerFinished:successfully:)]) {
        [self.delegate  audioPlayerFinished:player successfully:flag];
    }
    
}





@end
