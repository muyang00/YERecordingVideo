//
//  YERecordVideoTool.h
//  YERecordingVideoDemo
//
//  Created by yongen on 17/3/17.
//  Copyright © 2017年 yongen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface YERecordVideoTool : NSObject

@property (nonatomic, strong) NSString *videoPath;//视频路径

//捕获视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer;

//启动录制功能
- (void)startRecordFunction;
//关闭录制功能
- (void)stopRecordFunction;

//开始录制
- (void)startCapture;
//停止录制
- (void)stopCapture;

//开启闪光灯
- (void)openFlashLight;
//关闭闪光灯
- (void)closeFlashLight;

//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront;

@end

@interface YERecordVideoTool (Authorization)

//相机是否可用
- (BOOL)isAvailableWithCamera;

//麦克风是否可用
- (BOOL)isAvailableWithMic;

@end

