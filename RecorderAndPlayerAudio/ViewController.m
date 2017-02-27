//
//  ViewController.m
//  录音和语音播放
//
//  Created by xiyang on 2017/2/22.
//  Copyright © 2017年 xiyang. All rights reserved.
//

#import "ViewController.h"
#import "XYSpectrumView.h"
#import "XYRecorderManager.h"
#import "XYRecordPlayerManager.h"
@interface ViewController ()

@property (nonatomic, retain)XYRecorderManager *recorderManager;

@property (nonatomic, retain) UILabel *tipLabel;

@property (nonatomic, retain) XYSpectrumView *spectrumView;

/**
 录制成功语音路径
 */
@property (nonatomic, copy) NSString *filePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initSubViews];
    
}

-(void)initSubViews{
    
    _spectrumView = [[XYSpectrumView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-100, 180, 200, 50.0)];
    
    _spectrumView.text = @"0";
    __weak ViewController *weakSelf = self;
    
    _spectrumView.itemLevelCallback = ^(){
        
        [weakSelf.recorderManager.audioRecorder updateMeters];
        //取得第一个通道的音频，音频强度范围是-160到0
        float power = [weakSelf.recorderManager.audioRecorder averagePowerForChannel:0];
        weakSelf.spectrumView.level = power;
    };
    
    [self.view addSubview:_spectrumView];
    
    //录音管家
    self.recorderManager = [XYRecorderManager sharedRecorderManager];
    self.recorderManager.updateRecordingTime = ^(NSString *time){
        weakSelf.spectrumView.text = time;
    };
    self.recorderManager.recorderFinished = ^(BOOL success,NSError *error,NSString *filePath){
        
        if (error) {
            weakSelf.tipLabel.text = error.domain;
        }
        if (success) {
            if (filePath) {
                weakSelf.tipLabel.text = filePath;
                //                weakSelf.filePath = filePath;
                [weakSelf.playVioceBtn playerWithFilePath:filePath];
            }
        }
    };
}

#pragma mark - 录制语音方法

- (IBAction)recorderBtnAction:(UIButton *)sender {
    
    switch (sender.tag) {
        case 100: //开始录音
            [self recordStart:sender];
            break;
        case 101: //暂停录音
            [self recordPause:sender];
            break;
        case 102: //结束录音
            [self recordFinish:sender];
            break;
        case 103: //取消录音
            [self recordCancel:sender];
            break;
        default:
            break;
    }
    
}

-(void)recordStart:(UIButton *)btn{
    
    [self.recorderManager startRecord:^(BOOL success) {
        if (success) {
            self.tipLabel.text= @"开始录音";
            btn.enabled = NO;
        }
    }];
}

-(void)recordPause:(UIButton *)btn{
    if (btn.isSelected) {
        [self.recorderManager goonRecord:^(BOOL success) {
            if (success) {
                self.tipLabel.text = @"正在录音";
                btn.selected = NO;
            }
        }];
    }else{
        [self.recorderManager pauseRecord:^(BOOL success) {
            if (success) {
                self.tipLabel.text = @"录音已暂停";
                btn.selected = YES;
            }
        }];
    }
    
}

-(void)recordFinish:(UIButton *)btn{
    
    [self.recorderManager finishRecord:^(BOOL success) {
        if (success) {
            _tipLabel.text = @"";
            
            self.startBtn.enabled = YES;
        }
    }];
    
}

-(void)recordCancel:(UIButton *)btn{
    NSLog(@"取消");
    [self.recorderManager cancelRecord:^(BOOL success) {
        _tipLabel.text = @"录音已取消";
        self.startBtn.enabled = YES;
    }];
}

-(void)recordTouchDragExit:(UIButton *)btn{
    if (self.recorderManager.isRecording) {
        _tipLabel.text =@"松开取消";
    }
    
}

-(void)recordTouchDragEnter:(UIButton *)btn{
    
    if (self.recorderManager.isRecording) {
        _tipLabel.text = @"正在录音";
    }
}

#pragma mark - Getter

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)-240, CGRectGetMaxX(self.view.frame),30)];
        _tipLabel.textColor = [UIColor lightGrayColor];
        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_tipLabel];
    }
    return _tipLabel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
