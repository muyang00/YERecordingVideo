//
//  YERecordVideoTool.m
//  YERecordingVideoDemo
//
//  Created by yongen on 17/3/17.
//  Copyright © 2017年 yongen. All rights reserved.
//

#import "YERecordVideoTool.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface YERecordVideoTool ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;//负责输入和输出设备之间的连接会话，数据流的管理控制
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;//捕获到的视频呈现的layer
@property (nonatomic, strong) AVCaptureDeviceInput *backCameraInput;//后置摄像头输入
@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraInput;//前置摄像头输入
@property (nonatomic, strong) AVCaptureDeviceInput *audioMicInput;//麦克风输入
@property (nonatomic, strong) AVCaptureConnection *videoConnection;//视频录制连接
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;//视频输出流
@end

@implementation YERecordVideoTool


//启动录制功能
- (void)startRecordFunction{
    [self.captureSession startRunning];
}

//关闭录制功能
- (void)stopRecordFunction{
    if (self.captureSession) {
         [self.captureSession stopRunning];
    }
}

//开始录制功能
- (void)startCapture{
    if (self.captureMovieFileOutput.isRecording) return;
    
    NSString *defaultPath = [self getVideoPathCache];
    NSString *outputFilePath = [defaultPath stringByAppendingPathComponent:[self getVideoNameWithType:@"mp4"]];
    NSLog(@"save path is :%@", outputFilePath);
    NSURL *fileUrl = [NSURL fileURLWithPath:outputFilePath];
    //设置录制视频流输出的路径
    [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
}

//停止录制
- (void)stopCapture{
    if ([self.captureMovieFileOutput isRecording]) {
        [self.captureMovieFileOutput stopRecording];
    }
}

//开启闪光灯
- (void)openFlashLight{
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOff) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOn;
        backCamera.flashMode = AVCaptureFlashModeOn;
        [backCamera unlockForConfiguration];
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
    [self startRecordFunction];
}

//关闭闪光灯
- (void)closeFlashLight{
    [self.captureSession beginConfiguration];
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOn) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOff;
        backCamera.flashMode = AVCaptureFlashModeOff;
        [backCamera unlockForConfiguration];
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
    [self startRecordFunction];
}

//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront{
    //改变会话的配置前一定要先开启配置，配置完成后提交配置
    [self stopRecordFunction];
    [self.captureSession beginConfiguration];
    if (isFront) {
        [self.captureSession removeInput:self.backCameraInput];
        if ([self.captureSession canAddInput:self.frontCameraInput]) {
            [self.captureSession addInput:self.frontCameraInput];
        }
    }else{
        [self.captureSession removeInput:self.frontCameraInput];
        if ([self.captureSession canAddInput:self.backCameraInput]) {
            [self.captureSession addInput:self.backCameraInput];
        }
    }
    [self.captureSession commitConfiguration];
    [self startRecordFunction];
}

#pragma mark - 视频输出代理
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制。");
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"视频录制完成。");
    //视频录入完成之后再后台将视频存储到相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
    }completionHandler:^(BOOL success, NSError *error){
        if (error) {
            NSLog(@"保存视频到相簿过程中发生错误， 错误信息: %@", error.localizedDescription);
        }
        NSLog(@"成功保存视频到相簿");
    }];
}


#pragma mark - 视频地址
- (NSString *)getVideoPathCache{
    NSString *videoCache = [NSTemporaryDirectory() stringByAppendingPathComponent:@"video"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return videoCache;
}

- (NSString *)getVideoNameWithType:(NSString *)fileType{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HHmmss"];
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"video_%@.%@", timeStr, fileType];
    return fileName;
}



#pragma mark - Device init Method
//捕获的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer = preview;
    }
    return _previewLayer;
}

- (AVCaptureSession *)captureSession{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        //设置分辨率
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        }
        //添加后置摄像头输入
        if ([_captureSession canAddInput:self.backCameraInput]) {
            [_captureSession addInput:self.backCameraInput];
        }
        //添加后置麦克风的输入
        if ([_captureSession canAddInput:self.audioMicInput]) {
            [_captureSession addInput:self.audioMicInput];
        }
        //将设备输出添加到会话中
        if ([_captureSession canAddOutput:self.captureMovieFileOutput]) {
            [_captureSession addOutput:self.captureMovieFileOutput];
        }
        self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    return _captureSession;
}

//后置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput{
    if (!_backCameraInput) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc]initWithDevice:[self backCamera] error:&error];
        if (error) {
            NSLog(@"获取后置摄像头失败~%d", [self isAvailableWithCamera]);
        }
    }
    return _backCameraInput;
}

//前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput{
    if (!_frontCameraInput) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc]initWithDevice:[self frontCamera ] error:&error];
        if (error) {
            NSLog(@"获取前置摄像头失败~");
        }
    }
    return _frontCameraInput;
}

//麦克风输入
- (AVCaptureDeviceInput *)audioMicInput{
    if (!_audioMicInput) {
        AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) {
            NSLog(@"获取麦克风失败~ %d", [self isAvailableWithMic]);
        }
    }
    return _audioMicInput;
}

//输出对象，用户获取输出数据
- (AVCaptureMovieFileOutput *)captureMovieFileOutput{
    if (!_captureMovieFileOutput) {
        _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc]init];
    }
    return _captureMovieFileOutput;
}

//视频连接
- (AVCaptureConnection *)videoConnection{
    if (!_videoConnection) {
        _videoConnection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([_videoConnection isVideoStabilizationSupported]) {
            _videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    return _videoConnection;
}

//返回前置摄像头
- (AVCaptureDevice *)frontCamera{
    return [self cameraWithPostion:AVCaptureDevicePositionFront];
}
//返回后置摄像头
- (AVCaptureDevice *)backCamera{
    return [self cameraWithPostion:AVCaptureDevicePositionBack];
}
//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPostion:(AVCaptureDevicePosition)position{
    //返回和视频录制相关的默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //遍历这些设备返回跟postion相关的设备
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

@end

@implementation YERecordVideoTool (Authorization)

- (BOOL)isAvailableWithCamera{
    return [self isAvailableWithDeviceMediaType:AVMediaTypeVideo];
}

- (BOOL)isAvailableWithMic{
    return [self isAvailableWithDeviceMediaType:AVMediaTypeAudio];
}

- (BOOL)isAvailableWithDeviceMediaType:(NSString *)mediaType{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted) {
        return NO;
    }else{
        return YES;
    }
}

@end
