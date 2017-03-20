//
//  ViewController.m
//  YERecordingVideoDemo
//
//  Created by yongen on 17/3/17.
//  Copyright © 2017年 yongen. All rights reserved.
//

#import "ViewController.h"
#import "YERecordVideoTool.h"
#import "YERecordProcessView.h"

#define kVideoMaxTime 15.0

@interface ViewController ()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *recordingButton;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreViewLayer;//相机拍摄预览图层
@property (nonatomic, strong) YERecordProcessView *progress;
@property (nonatomic, strong) YERecordVideoTool *videoTool;
@property (nonatomic, assign) CGFloat timeCount;
@property (nonatomic, assign) CGFloat timeMargin;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    [self setupSubview];
    [self setupCaptureSession];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    self.topView.frame = CGRectMake(0, 0, width, 80);
    self.recordingButton.center = CGPointMake(width * 0.5, height - self.recordingButton.bounds.size.height);
    self.progress.center = self.recordingButton.center;
    CGFloat margin = (width - (self.topView.subviews.count * self.cameraButton.bounds.size.width)) / self.topView.subviews.count;
    for (NSInteger i = 0; i < self.topView.subviews.count; i ++) {
        UIButton *button = self.topView.subviews[i];
        CGPoint center = button.center;
        center.y = self.topView.bounds.size.height * 0.5;
        center.x = margin + i * (self.cameraButton.bounds.size.width + margin);
        button.center = center;
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.videoTool stopCapture];
    [self.videoTool stopRecordFunction];
}

- (void)setupSubview{
    
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.closeButton];
    [self.topView addSubview:self.flashButton];
    [self.topView addSubview:self.cameraButton];
    [self.view addSubview:self.progress];
    [self.view addSubview:self.recordingButton];
}

- (void)setupCaptureSession{
    self.captureVideoPreViewLayer = [self.videoTool previewLayer];
    CALayer *layer = self.containerView.layer;
    layer.masksToBounds = YES;
    self.captureVideoPreViewLayer.frame = layer.bounds;
    [layer addSublayer:self.captureVideoPreViewLayer];
    //开启录制功能
    [self.videoTool startRecordFunction];
}

#pragma mark - 定时器

- (void)startTimer{
    self.progress.hidden = NO;
    CGFloat signleTime = kVideoMaxTime / 360;
    self.timeCount = 0;
    self.timeMargin = signleTime;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:signleTime target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer{
    self.progress.progress = 0;
    [self.timer invalidate];
    self.timer = nil;
}
- (void)updateProgress{
    if (self.timeCount >= kVideoMaxTime) {
        [self stopTimer];
        [self endRecordingVideo];
        return;
    }
    self.timeCount += self.timeMargin;
    CGFloat progress = self.timeCount / kVideoMaxTime;
    NSLog(@"progress ---- %f, self.timeMargin --- %f, self.timeCount ---- %f", progress, self.timeMargin, self.timeCount);
    self.progress.progress = progress;
}

#pragma mark - Action

- (void)closeButtonClick{
    [self endRecordingVideo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)flashButtonClick:(UIButton *)flashButton{
    flashButton.selected = !flashButton.isSelected;
    if (flashButton.selected) {
        [self.videoTool openFlashLight];
    }else{
        [self.videoTool closeFlashLight];
    }
}

- (void)cameraButtonClick:(UIButton *)cameraButton{
    cameraButton.selected = !cameraButton.isSelected;
    if (cameraButton.selected) {
        [self.videoTool closeFlashLight];
        [self.videoTool changeCameraInputDeviceisFront:YES];
    }else{
        [self.videoTool changeCameraInputDeviceisFront:NO];
    }
}

- (void)startRecordingVideo{
    [self startTimer];
    [self.videoTool startCapture];
}
- (void)endRecordingVideo{
    [self stopTimer];
    [self.videoTool stopCapture];
}

#pragma mark - lazy

- (UIView *)topView{
    if (!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    }
    return _topView;
}
- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc]initWithFrame:self.view.bounds];
        _containerView.backgroundColor = [UIColor greenColor];
    }
    return _containerView;
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"shortvideo_button_close"] forState:UIControlStateNormal];
        _closeButton.bounds = CGRectMake(0, 0, 50, 50);
        _closeButton.layer.cornerRadius = _closeButton.bounds.size.width * 0.5;
        _closeButton.layer.masksToBounds = YES;
        [_closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _closeButton;
}
- (UIButton *)flashButton{
    if (!_flashButton) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashButton setImage:[UIImage imageNamed:@"room_pop_up_lamp"] forState:UIControlStateNormal];
        _flashButton.bounds = CGRectMake(0, 0, 50, 50);
        _flashButton.layer.cornerRadius = _flashButton.bounds.size.width * 0.5;
        _flashButton.layer.masksToBounds = YES;
        [_flashButton addTarget:self action:@selector(flashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _flashButton;
}
- (UIButton *)cameraButton{
    if (!_cameraButton) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setImage:[UIImage imageNamed:@"shortvideo_download_5_refresh"] forState:UIControlStateNormal];
        _cameraButton.bounds = CGRectMake(0, 0, 50, 50);
        _cameraButton.layer.cornerRadius = _cameraButton.bounds.size.width * 0.5;
        _cameraButton.layer.masksToBounds = YES;
        [_cameraButton addTarget:self action:@selector(cameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _cameraButton;
}

- (UIButton *)recordingButton{
    if (!_recordingButton) {
        _recordingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordingButton setImage:[UIImage imageNamed:@"room_task_video_start_fold"] forState:UIControlStateNormal];
        _recordingButton.bounds = CGRectMake(0, 0, 50, 50);
        _recordingButton.layer.cornerRadius = _recordingButton.bounds.size.width * 0.5;
        _recordingButton.layer.masksToBounds = YES;
        [_recordingButton addTarget:self action:@selector(startRecordingVideo) forControlEvents:UIControlEventTouchDown];
        [_recordingButton addTarget:self action:@selector(endRecordingVideo) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _recordingButton;
}

- (YERecordVideoTool *)videoTool{
    if (!_videoTool) {
        _videoTool = [[YERecordVideoTool alloc]init];
    }
    return _videoTool;
}

- (YERecordProcessView *)progress{
    if (!_progress) {
        CGFloat WH = self.recordingButton.bounds.size.width + 2 * lineWith;
        _progress  = [[YERecordProcessView alloc]initWithCenter:CGPointMake(WH * 0.5, WH * 0.5) radius:(WH - lineWith) * 0.5];
        _progress.bounds = CGRectMake(0, 0, WH, WH);
        _progress.hidden = YES;
    }
    return _progress;
}

@end
