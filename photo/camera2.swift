//
//  camera2.swift
//  audioceshi
//
//  Created by sunkai on 16/9/1.
//  Copyright © 2016年 imo. All rights reserved.
//

import Cocoa


//实时获取预览图像
class camera2: NSViewController {
    
    //TODO:-1.1这里是测试的
    @IBOutlet weak var ceshiImage: NSImageView!
    var ceshiview : HollowStringView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:-1.这里是测试的
        ceshiview = HollowStringView(content: "123", frame: NSRect(x: 0, y: 0, width: 100, height: 40))
        self.view.addSubview(ceshiview)
        self.ceshiview.delegete = self
       
    }
    
    
    
    @IBAction func closewindow(sender: AnyObject) {
        //停止播放音乐，同时把播放器置为nil
        PlaySoundManager.shareManager.stopSound()
        PlaySoundManager.shareManager.audioPlayer = nil
        self.view.window?.close()
    }
    
    var capturesession : AVCaptureSession?//输入设备和输出之前的数据传输
    var capturedeviceInput : AVCaptureDeviceInput?//输入数据从device
    var capturestillImageOutput : AVCaptureStillImageOutput?//静态照片输出流
    var capturePreviewLayer : AVCaptureVideoPreviewLayer?  //图像预览层

    var capturedevice : AVCaptureDevice?//默认设备，相机
    var captureImageUrl : NSURL?//用于保存当前获取的截图,暂时保留
    var captureCount : NSInteger = 0 //保留拍照次数，用于给图片名称命名,存储在cache中
    @IBOutlet weak var viewContainer: NSView! //视图容器
    var backgroundView : BackGroundView? //背景视图动画
    let BackViewWidth : CGFloat = 163
    let BackViewHeight : CGFloat = 25
    var bottomView : BottomView?
    
    typealias  PropertyChangeClosures = (device : AVCaptureDevice)->()
    //修改属性的闭包，类似于block一样，暂时没有用到
    
    
    //拍照按钮
    @IBAction func takePhoto(sender: AnyObject) {
        
        //执行动画,这里或者不允许按钮继续按下去，或者直接进行返回
        if self.ceshiview.isAnimation == false{
           self.ceshiview.runAnimation()
        }else{
            return
        }
    }
    
    //给设备添加通知
    func addNotificationsToDevice(device:AVCaptureDevice){
        //注意添加区域发生改变捕获通知必须首先设置允许捕获
        self.changeDeviceProperty { (device) in
          //TODO:-1.暂且保留，不知道这里什么功能实现
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deviceConnected(_:)), name: AVCaptureDeviceWasConnectedNotification, object: self.capturedevice!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deviceDisconnected(_:)), name: AVCaptureDeviceWasDisconnectedNotification, object: self.capturedevice!)
    }
    
    //移除所有通知
    func removeAllNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //给某个会话添加通知,主要针对会话出错的问题
    func addNotificationToCaptureSession(captureSession:AVCaptureSession){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionRuntimeError(_:)), name: AVCaptureSessionRuntimeErrorNotification, object: self.capturesession!)
    }
    
    //会话出错
    func sessionRuntimeError(notification:NSNotification){
        Swift.print("会话出错")
        //TODO:-4.这里还是要弹出一个提示框
    }
    
    //FIXME:-7.设备已经连接通知
    func deviceConnected(notification:NSNotification){
        Swift.print("设备连接")
        self.removeBackgroundView()
    }
    
    //FIXME:-8.设备已经断开通知
    func deviceDisconnected(notification:NSNotification){
        Swift.print("设备断开")
        self.settingOfBackgroundView(self.backgroundView)
    }
    
    //MARK:-9.修改设备属性
    func changeDeviceProperty(property:PropertyChangeClosures){
        let capturedevice1 = self.capturedeviceInput?.device
        //这里和上边的设备是指的同一个
        //获取输入的设备
        //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
        do{
            if ((try capturedevice1?.lockForConfiguration()) != nil) {
                property(device: capturedevice1!)
                capturedevice1?.unlockForConfiguration()
            }
            
        }catch let error as NSError{
            Swift.print("修改过程中发生错误\(error.description)")
        }
        
    }
    
    
    //视图将要出现的时候，进行的初始化操作
    override func viewWillAppear() {
        super.viewWillAppear()
        
        //设置容器视图
        self.settingOfContainerView(self.viewContainer)
        
        //FIXME:-1.设置背景的动画视图
        self.settingOfBackgroundView(self.backgroundView)
        
        //初始化会话
        if self.capturesession == nil {
            self.capturesession = AVCaptureSession()
        }
        
        //FIXME:-2.设置分辨率,如果可以的话，自己这里设置为可以选择的
        if self.capturesession?.canSetSessionPreset(AVCaptureSessionPreset1280x720) == true {
            self.capturesession?.sessionPreset = AVCaptureSessionPreset1280x720
        }
        
        //获取默认相机
        if self.capturedevice == nil {
            self.capturedevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            //FIXME:-3.一直是连接着，从来没断开，只要创建成功了
            Swift.print("当前连接的状态是\(self.capturedevice!.connected)")
        }
    
        
        if self.capturedevice == nil {
            //按照理论，这里也是可能出现错误的，需要直接返回
            Swift.print("出现错误了，摄像头设备故障")
            return
        }
        
        //获取输入设备
        do {
            self.capturedeviceInput = try AVCaptureDeviceInput(device: self.capturedevice!)
        }catch let error as NSError{
            Swift.print("出现错误了,可能您的摄像头有问题\(error.description)")
            //这里是要弹出错误提示，摄像头有问题的！！！,然后直接返回
            return
        }
        
        //获取输出设备
        if self.capturestillImageOutput == nil {
            self.capturestillImageOutput = AVCaptureStillImageOutput()
        }
        
        //输出设备的配置
        let outputSetting = [AVVideoCodecKey:AVVideoCodecJPEG]
        self.capturestillImageOutput?.outputSettings = outputSetting
        
        //将设备添加到会话中
        if self.capturesession?.canAddInput(self.capturedeviceInput!) == true {
            self.capturesession?.addInput(self.capturedeviceInput)
        }
        if self.capturesession?.canAddOutput(self.capturestillImageOutput!) == true {
            self.capturesession?.addOutput(self.capturestillImageOutput!)
        }
        
        //创建视屏预览层，用于实时展示摄像头状态,这是第一种状态
        if self.capturePreviewLayer == nil {
            self.capturePreviewLayer = AVCaptureVideoPreviewLayer(session: self.capturesession!)
        }
        
        self.capturePreviewLayer?.frame = (self.viewContainer.layer?.bounds)!
        
        self.capturePreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
         //填充模式
        self.capturePreviewLayer?.autoresizingMask = [CAAutoresizingMask.LayerWidthSizable,CAAutoresizingMask.LayerHeightSizable]
        
        self.viewContainer.layer!.insertSublayer(self.capturePreviewLayer!, atIndex: 0)
        
        //给获取的device添加通知
        self.addNotificationsToDevice(self.capturedevice!)
        //给当前的会话添加通知
        self.addNotificationToCaptureSession(self.capturesession!)
        
    }
    
    func settingOfBackgroundView(view:BackGroundView?){
        if view == nil {
            let rect = NSRect(x: 0, y: 0, width: BackViewWidth, height: BackViewHeight)
            let view = BackGroundView(frame: rect)
            self.backgroundView = view
             self.backgroundView?.setFrameOrigin(NSPoint(x: self.viewContainer.bounds.size.width / 2 - BackViewWidth / 2, y: self.viewContainer.bounds.size.height / 2 - BackViewHeight / 2))
            self.backgroundView?.animationView.imagegroundcolor = NSColor.whiteColor().CGColor
            self.backgroundView?.animationView.margin = 10
        }
        self.viewContainer.addSubview(self.backgroundView!)
    }
    
    func removeBackgroundView(){
        if self.backgroundView == nil {
            return
        }else{
            self.backgroundView?.removeFromSuperview()
            self.backgroundView = nil
        }
    }
    
    func settingOfContainerView(view:NSView){
        view.wantsLayer = true
        view.layer?.backgroundColor = CGColorGetConstantColor(kCGColorBlack)
        view.layer?.masksToBounds = true
        view.layer?.cornerRadius = 2
    }
    
    //视图出现的时候，启动会话
    override func viewDidAppear() {
        super.viewDidAppear()
        //TODO:-6.在启动会话之前，要把连接的背景图片去除
        self.removeBackgroundView()
        //启动会话，进行捕获当前图片
        //最好开启线程，以免影响主进程
        let sessionQueue = dispatch_queue_create("capture_session", DISPATCH_QUEUE_SERIAL)
        dispatch_async(sessionQueue) { 
             self.capturesession?.startRunning()
        }
    }
    
    //视图消失的时候，关闭会话，以及一些必要的操作
    override func viewDidDisappear() {
        super.viewDidDisappear()
        //停止会话
        self.capturesession?.stopRunning()
        //拍照计数清零
        self.captureCount = 0
        //移除所有通知
        self.removeAllNotifications()
    }

}


extension camera2 : AnimationCompletionDelegate{
    func animationCompletion() {
        //更换资源的话，需要重新创建么
        PlaySoundManager.shareManager.changeSoundResourceIndex(1)
        PlaySoundManager.shareManager.playSound()
        //定义拍照功能，就是获取链接，从获取的链接中拿到数据然后进行保存
        self.captureCount += 1
        //根据设备输出获取链接
        let captureConnection = self.capturestillImageOutput?.connectionWithMediaType(AVMediaTypeVideo)
        //根据链接取得设备输出的数据
        self.capturestillImageOutput?.captureStillImageAsynchronouslyFromConnection(captureConnection!, completionHandler: { (imageDataBuffer : CMSampleBuffer!, error : NSError!) in
            if imageDataBuffer != nil {
                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
                let img = NSImage(data: data)
                //保存到cache中,名字是根据点击的次数
                let result =  img?.saveToCache(data, tag: self.captureCount)
                if result?.1 == true && result?.0 != nil {
                    self.captureImageUrl = result!.0 //单张照片处理
                    self.bottomView?.delegate?.displayImages(self.bottomView!, imageUrl: self.captureImageUrl!)
                }
            }
            
            if error != nil {
                Swift.print("获取照片出现错误\(error.description)")
                return
            }
        })
        Swift.print("测试拍照了，注意！")
    }
}

extension camera2 : disPlayImagesAsyncDelegate {
    func displayImages(view: BottomView, imageUrl: NSURL) {
        //查找图片
        view.addAnImageWithUrl(imageUrl)
        //纯粹测试
        let bottom = BottomView(frame: NSRect(x: 0, y: 35, width: self.viewContainer.bounds.size.width, height: 60))
        bottom.delegate = self
        self.bottomView = bottom
        self.view.addSubview(self.bottomView!)

        dispatch_async(dispatch_get_main_queue(), {
            view.updataDatasource()
            //更新图片显示
        })
     }
}


