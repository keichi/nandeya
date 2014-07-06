//
//  ViewController.m
//  nandeya
//
//  Created by Keichi Takahashi on 7/6/14.
//  Copyright (c) 2014 Keichi Takahashi. All rights reserved.
//

#import "ViewController.h"
#import "SocketIOPacket.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    [socketIO connectToHost:@"192.168.100.119"
                     onPort:80
    ];
    
    NSError *error;
    NSURL *furl1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nande1" ofType:@"mp3"]];
    testsound1 = [[AVAudioPlayer alloc] initWithContentsOfURL:furl1 error:&error];
    NSURL *furl2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nande2" ofType:@"mp3"]];
    testsound2 = [[AVAudioPlayer alloc] initWithContentsOfURL:furl2  error:nil];
    NSURL *furl3 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nande3" ofType:@"mp3"]];
    testsound3 = [[AVAudioPlayer alloc] initWithContentsOfURL:furl3  error:nil];
    NSURL *furl4 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nande4" ofType:@"mp3"]];
    testsound4 = [[AVAudioPlayer alloc] initWithContentsOfURL:furl4  error:nil];
    NSURL *furl5 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nande5" ofType:@"mp3"]];
    testsound5 = [[AVAudioPlayer alloc] initWithContentsOfURL:furl5  error:nil];
    
    zs = [NSMutableArray arrayWithCapacity:LENGTH];
    start = [NSDate date];
    nowState = 2;
	prevVelocity = 0;
	velocity = 0;
    
    motionManager = [[CMMotionManager alloc] init];
    
    if (motionManager.accelerometerAvailable)
    {
        // センサーの更新間隔の指定
        motionManager.accelerometerUpdateInterval = 1 / 5;
        
        // ハンドラを指定
        CMAccelerometerHandler handler = ^(CMAccelerometerData *data, NSError *error)
        {
            if (nowState == 1)
            {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@3 forKey:@"uid"];
                [socketIO sendEvent:@"tsukkomi" withData:dict];
                
                nowState = 2;
                prevVelocity = velocity = 0;
            }
            if(zs.count >=  LENGTH) {
                [zs removeObjectAtIndex:0];
            }
            [zs addObject: [NSNumber numberWithFloat: data.acceleration.z]];
            
            end = [NSDate date];
            samplingtime = [end timeIntervalSinceDate:start];
            if(samplingtime < 0.05) {
                return;
            }
            
            velocity = 0;
            for(int i = 0; i < zs.count; i++) {
                NSNumber *num = [zs objectAtIndex:i];
                float zsi = [num floatValue];
                velocity += zsi * samplingtime;
            }
            if(fabsf(velocity) > THRESHOLD) {
                nowState = 0;
            }
            if(prevVelocity * velocity <= -0.038 && nowState == 0) {
                nowState = 1;
            }
            
            start = end;
            prevVelocity = velocity;
        };
        
        // 加速度の取得開始
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"socket.io connected.");
}

// event delegate
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveEvent >>> data: %@", packet.data);
    
    if ([packet.name isEqualToString: @"tsukkomi"]) {
        NSDictionary *kvs = [packet.args objectAtIndex: 0];
        NSNumber *num = [kvs objectForKey: @"uid"];
        
        if ([num intValue] == 1) {
            [testsound1 play];
        } else if ([num intValue] == 2) {
            [testsound2 play];
        } else if ([num intValue] == 3) {
            [testsound3 play];
        } else if ([num intValue] == 4) {
            [testsound4 play];
        } else if ([num intValue] == 5) {
            [testsound5 play];
        }
    }
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"onError() %@", error);
}


- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socket.io disconnected. did error occur? %@", error);
}

@end
