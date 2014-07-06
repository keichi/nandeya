//
//  ViewController.h
//  nandeya
//
//  Created by Keichi Takahashi on 7/6/14.
//  Copyright (c) 2014 Keichi Takahashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "SocketIO.h"

#define THRESHOLD (0.3)
#define LENGTH (15)


@interface ViewController : UIViewController<SocketIODelegate>
{
    SocketIO *socketIO;
    AVAudioPlayer *testsound1;
    AVAudioPlayer *testsound2;
    AVAudioPlayer *testsound3;
    AVAudioPlayer *testsound4;
    AVAudioPlayer *testsound5;
    
    NSMutableArray *zs;
	NSDate *start;
    NSDate *end;
	int nowState;
	float samplingtime;
	float prevVelocity;
	float velocity;
    
    CMMotionManager *motionManager;
}

@end
