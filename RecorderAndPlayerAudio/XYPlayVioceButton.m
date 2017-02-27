

//
//  XYPlayVioceButton.m
//  录音和语音播放
//
//  Created by xiyang on 2017/2/24.
//  Copyright © 2017年 xiyang. All rights reserved.
//

#import "XYPlayVioceButton.h"
#import "XYRecordPlayerManager.h"

static CGFloat titleFont = 14;
#define XYImageSrcName(file)               [[UIImage imageNamed:[@"Settings.bundle/playerIcon" stringByAppendingPathComponent:file]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
@interface XYPlayVioceButton ()<XYRecordPlayerDelegate>

@property(nonatomic, retain) XYRecordPlayerManager *playerManager;

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, retain) NSArray *imageArr;


@end

@implementation XYPlayVioceButton

-(instancetype)init{
    self = [super init];
    if (self) {
        
        [self setup];
        
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    UIImage *img3 = XYImageSrcName(@"icon_wave_2");
    CGFloat h = img3.size.height;
    CGFloat x = [self imageX:contentRect];
    CGFloat y = (contentRect.size.height-h)/2.0;
    CGFloat w = img3.size.width;
    
    
    return CGRectMake(x, y, w, h);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    
    UIImage *img3 = XYImageSrcName(@"icon_wave_2");
    CGSize size = [self.currentTitle boundingRectWithSize:contentRect.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
                                                                                                                                      NSFontAttributeName:[UIFont systemFontOfSize:titleFont]
                                                                                                                                      }context:nil].size;
    
    CGFloat h = contentRect.size.height;
    CGFloat w = size.width;
    CGFloat x = [self imageX:contentRect]+img3.size.width;
    
    return CGRectMake(x, 0, w, h);
}


-(CGFloat)imageX:(CGRect)contentRect{
    
    CGSize titleSize = [self.currentTitle boundingRectWithSize:contentRect.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
                                                                                                        NSFontAttributeName:[UIFont systemFontOfSize:titleFont]
                                                                                                                                          } context:nil].size;
    UIImage *img3 = XYImageSrcName(@"icon_wave_2");
    CGSize imgSize = img3.size;
    CGFloat contentW = titleSize.width+imgSize.width;
    CGFloat x = 0;
    if (contentW<self.frame.size.width) {
         x = (self.frame.size.width-contentW)/2.0;
    }
    return x;
}


-(void)setup{
    
    self.playerManager = [XYRecordPlayerManager sharedRecordPlayerManager];
    self.playerManager.delegate = self;
    [self setBackgroundImage:XYImageSrcName(@"chat_bubble") forState:UIControlStateNormal];
    
    [self setImage:XYImageSrcName(@"icon_wave_2") forState:UIControlStateNormal];
    
    [self addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    self.contentMode = UIViewContentModeCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:titleFont];
    
    UIImage *img1 = XYImageSrcName(@"icon_wave_0");
    UIImage *img2 = XYImageSrcName(@"icon_wave_1");
    UIImage *img3 = XYImageSrcName(@"icon_wave_2");
    self.imageArr = @[img1,img2,img3];
    
}

-(void)playerWithFilePath:(NSString *)filePath{
    
    self.filePath = filePath;
    if (self.playerManager) {
        [self.playerManager playVoiceWithPath:filePath];
        [self setTimeTitle];
    }
}

-(void)setTimeTitle{

    NSString *durationStr = [NSString stringWithFormat:@"%.2zd''",self.playerManager.duration];
    [self setTitle:durationStr forState:UIControlStateNormal];
}

-(void)play{
    
    if (self.playerManager) {
        if ([self.playerManager isPlaying]) {
            [self.playerManager stop];
            if ([self.imageView isAnimating]) {
                [self.imageView stopAnimating];
            }
            [self setTimeTitle];
            
        }else{
            if (self.filePath) {
                [self.playerManager play];

                if (self.imageArr) {
                    self.imageView.animationImages = self.imageArr;
                    self.imageView.animationDuration = 2;
                    self.imageView.animationRepeatCount = 0;
                    [self.imageView startAnimating];
                }
            }else{
                NSLog(@"没有播放语音的路径");
            }
        }
    }
}




#pragma mark - XYRecordPlayerDelegate
-(void)audioPlayerFinished:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    if (flag) {
        [self.imageView stopAnimating];
    }
    
}





@end
