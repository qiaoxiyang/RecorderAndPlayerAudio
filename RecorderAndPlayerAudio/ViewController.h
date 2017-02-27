//
//  ViewController.h
//  录音和语音播放
//
//  Created by xiyang on 2017/2/22.
//  Copyright © 2017年 xiyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPlayVioceButton.h"
@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet XYPlayVioceButton *playVioceBtn;

- (IBAction)recorderBtnAction:(UIButton *)sender;


@end

